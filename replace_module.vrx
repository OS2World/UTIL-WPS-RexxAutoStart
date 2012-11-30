/*:VRX         Replace_module
Usage:  replace_module(source_file, target_file, <options>)
Where:     source_file = name of source file
           target_file = name of target file
           options = -f (no date compare, force replacement)
                     -b backup_file (zip target_file to backup_file before replacement)
                     -q (quiet, bypass update if files equal in time stamp and size)
Result:    1 if target file replaced, 0 otherwise
Requires:  Sayout, Pull_it, and Dateconv
*/
Replace_module: Procedure Expose test_run verbose log_out log_file
save_trace = Trace('N')
/* test exposed parameters */
If \Datatype(test_run, 'b') Then
   test_run = 0
If \Datatype(verbose, 'b') Then
   verbose = 1
If \Datatype(log_out, 'b') Then
   Do
      xrc = SysFileTree(log_file, 'test.', 'fo')
      If xrc = 0 & test.0 <> 0 Then
         log_out = 1
      Else
         log_out = 0
   End
Parse Arg source_file, target_file, opts, .
force = 0
backup = 0
quiet = 0
If opts <> '' Then
   Do
      Parse Var opts flags backup_file .
      flags = Space(Translate(flags))
      force = (Pos('F', flags) <> 0)
      backup = (Pos('B', flags) <> 0)
      quiet = (Pos('Q', flags) <> 0)
      If backup Then
         Do
            backup_file = Space(backup_file)
            If backup_file = '' Then
               Do
                  Call Sayout 'Backup was specified, but no backup file was given'
                  Call Sayout 'No backup of' target_file 'will be made', 1
                  backup = 0
               End
         End
   End
xrc = SysFileTree(source_file, 'source.', 'f')
If xrc = 0 & source.0 <> 0 Then
   Do
      Parse Var source.1 source_date source_time source_size .
      source_stamp = Dateconv(source_date, 'u', 'i') source_time
      source_size = Space(source_size)
      target_path = Strip(Filespec('d', target_file) || Filespec('p', target_file), 't', '\')
      xrc = SysFileTree(target_path, 'target.', 'do')
      If xrc = 0 & target.0 <> 0 Then            /* found target path */
         Do
            xrc = SysFileTree(target_file, 'target.', 'f')
            If xrc = 0 & target.0 <> 0 Then
               Do
                  Parse Var target.1 target_date target_time target_size .
                  target_stamp = Dateconv(target_date, 'u', 'i') target_time
                  target_size = Space(target_size)
               End
            Else
               Do
                  target_stamp = '0000-00-00 00:00:00'
                  target_size = '0'
               End
            rep_it = 0
            ask_rep_it = 0
            ask_rep_it.5 = ''
            Select
               When force Then
                  rep_it = 1
               When (source_stamp > target_stamp) Then
                  rep_it = 1
               When (source_stamp = target_stamp) ,
                  & (source_size <> target_size) Then
                  rep_it = 1
               When (source_stamp = target_stamp) ,
                  & (source_size = target_size) Then
                  Do
                     ask_rep_it.1 = 'The time stamp and size of the target file'
                     ask_rep_it.3 = 'are equal to the time stamp and size of the source file'
                     ask_rep_it = 1
                  End
               When (source_stamp = target_stamp) ,
                  & (source_size <> target_size) Then
                  Do
                     ask_rep_it.1 = 'The time stamp of the target file'
                     ask_rep_it.3 = 'is equal to the time stamp of the source file'
                     ask_rep_it.5 = 'but the sizes do not match'
                     ask_rep_it = 1
                  End
               When (source_stamp < target_stamp) ,
                  & (source_size = target_size) Then
                  Do
                     ask_rep_it.1 = 'The time stamp of the target file'
                     ask_rep_it.3 = 'is less then to the time stamp of the source file'
                     ask_rep_it.5 = 'but the sizes are equal'
                     ask_rep_it = 1
                  End
               When (source_stamp < target_stamp) ,
                  & (source_size <> target_size) Then
                  Do
                     ask_rep_it.1 = 'The time stamp of the target file'
                     ask_rep_it.3 = 'is less then to the time stamp of the source file'
                     ask_rep_it.5 = 'and the sizes do not match'
                     ask_rep_it = 1
                  End
               Otherwise Do
                  Call Sayout 'An unexpected condition has occured while processing'
                  Call Sayout 'Target file -' target_file '-' target_stamp '-' target_size, 1
                  Call Sayout 'Source file -' source_file '-' source_stamp '-' source_size, 1
                  Call Sayout 'Update of' target_file 'bypassed'
                  rep_it = 0
                  ask_rep_it = 0
                  xrc = 0
               End
            End
            If \rep_it & ask_rep_it Then
               Do
                  If \quiet Then
                     Do
                        Call Sayout ''
                        Call Sayout ask_rep_it.1
                        Call Sayout target_file '-' target_stamp '-' target_size, 1
                        Call Sayout ask_rep_it.3
                        Call Sayout source_file '-' source_stamp '-' source_size, 1
                        If ask_rep_it.5 <> '' Then
                           Call Sayout ask_rep_it.5
                        Call Sayout 'Enter "go" to overwrite the target file'
                        Call Sayout 'or any other response to bypass the update', 1
                        ans = Pull_it()
                     End
                  Else
                     Do
                        ans = ''
                        Call Sayout ''
                     End
                  If ans = 'GO' Then
                     rep_it = 1
               End
            If rep_it Then
               Do
                  Do Queued()
                     Pull .
                  End
                  If \test_run Then
                     Do
                        If backup Then
                           Do
                              xrc = SysFileTree(target_file, 'target.', 'fo')
                              If xrc = 0 & target.0 <> 0 Then
                                 Do
                                    Call Sayout 'Backing up' target_file 'to' backup_file, 1
                                    Address cmd 'zip -oSX9' backup_file target_file '2>&1|RXQUEUE'
                                    Do Queued()
                                       Call Pull_it 'all'
                                    End
                                 End
                              Else
                                 Do
                                    Call Sayout target_file 'does not currently', 1
                                    Call Sayout 'exist and will not be backed up', 2
                                 End
                           End
                        Address cmd '@repmod' source_file target_file '2>&1|RXQUEUE'
                        xrc = (rc = 0)
                        Do Queued()
                           Call Pull_it 'all'
                        End
                     End
                  Else
                     Do
                        Call Sayout 'Address cmd' 'repmod' source_file target_file
                        xrc = 1
                     End
               End
            Else
               Do
                  Call Sayout 'Update of' target_file 'bypassed'
                  xrc = 1
               End
         End
      Else
         Do
            Call Sayout 'Target path' target_path 'not found'
            xrc = 0
         End
   End
Else
   Do
      Call Sayout 'Source' source_file 'not found'
      xrc = 0
   End
If \xrc Then
   Call Sayout 'repmod' source_file target_file 'failed.'
Trace(save_trace)
Return xrc
