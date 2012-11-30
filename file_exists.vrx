/*:VRX         File_exists
Usage:  file_exists(file_name)
Where:     file_name = name of file or path to be tested
Result:    1 if file or path exists, 0 otherwise
*/
File_exists: Procedure Expose verbose log_out log_file
save_trace = Trace('N')
Parse Arg file_name
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
xrc = SysFileTree(file_name, 'test.', 'fo')
If xrc = 0 & test.0 <> 0 Then
   exists = 1
Else
   Do
      /* may be a directory */
      xrc = SysFileTree(file_name, 'test.', 'do')
      If xrc = 0 & test.0 <> 0 Then
         exists = 1
      Else
         exists = 0
   End
Trace(save_trace)
Return exists

