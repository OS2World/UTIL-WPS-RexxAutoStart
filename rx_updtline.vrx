/*:VRX         Rx_updtline
Usage:  rx_updtline(line_no, output_line, output_file, action, <opts>)
Where:     line_no = the line number to be replaced or inserted
           output_line = the line to be replaced or inserted
           output_file = a fully qualified file to be updated
           action = "insert" or "replace" (default = replace)
           opts = -c close (the file will be backed up and written out,
                            otherwise, the updated file will be available
                            in the exposed stem "file_lines.")
                  -q quiet (do not confirm the writing of the output file)
Result:    1 - successful completion
           0 - update of file to disk failed
*/
Rx_updtline: Procedure Expose file_lines. test_run verbose log_out log_file
save_trace = Trace('N')
Parse Arg line_no, output_line, output_file, action, opts
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
xrc = 1
replace = 0
insert = Abbrev(Translate(action), 'I')
If \insert Then
   replace = 1
opts = Translate(opts)
close = (Pos('C', opts) <> 0)
quiet = (Pos('Q', opts) <> 0)

If file_lines.0 = 0 Then
   Call Rx_readlines output_file

xrc = 1
x = file_lines.0                           /* number of lines in file */

If replace Then
   Do                                     /* replace an existing line */
      If file_lines.x = '1a'x ,                  /* don't replace eof */
         & line_no = x Then
         xrc = 0
      If xrc Then
         file_lines.line_no = output_line
      Else
         Call Sayout 'Replacement of end-of-file marker not permitted'
   End
Else                                             /* insert a new line */
   Do
      If line_no = 0 Then                     /* insert as first line */
         line_no = 1
      If line_no > file_lines.0 Then           /* insert as last line */
         line_no = file_lines.0
      Do i = file_lines.0 To (line_no) By -1
         j = i + 1
         file_lines.j = file_lines.i
      End
      j = line_no
      file_lines.j = output_line
      file_lines.0 = file_lines.0 + 1
      xrc = 1
   End

If xrc Then
   Do
      If close Then
         Do
            xrc = 0
            save_file = SysTempFileName(Left(output_file, Lastpos('.', output_file) - 1) || '.???')
            If \quiet Then
               Do
                  Call Sayout ''
                  Call Sayout 'Ready to rewrite' output_file || ', enter OK to continue', 1
                  ans = Pull_it()
               End
            Else
               ans = 'OK'
            If test_run Then
               Do
                  Call Sayout 'This is a test run,' output_file 'will not be updated', 1
                  xrc = 1
                  ans = ''
               End
            If ans = 'OK' Then
               Do
                  Address cmd '@copy' output_file save_file '> nul'
                  If rc = 0 Then
                     Do
                        Address cmd '@erase' output_file
                        If rc = 0 Then
                           Do
                              Call Rx_writelines output_file
                              xrc = 1
                              Call Sayout 'Updated' output_file || ', was saved as' save_file, 1
                           End
                        Else
                           Do
                              xrc = 0
                              Call Sayout 'Deletion of' output_file 'failed with a return code of' rc, 1
                              Call Sayout 'File' output_file 'was saved as' save_file, 2
                           End
                     End
                  Else
                     Do
                        xrc = 0
                        Call Sayout 'Copy of' output_file 'to' save_file, 1
                        Call Sayout 'failed with a return code of' rc, 2
                        Call Sayout output_file 'should be intact', 2
                     End
               End
            Else
               Do
                  xrc = 0
                  Call Sayout 'Update of' output_file 'aborted', 1
               End
            file_lines. = ''
            file_lines.0 = 0
         End
   End

Trace(save_trace)
Return xrc
