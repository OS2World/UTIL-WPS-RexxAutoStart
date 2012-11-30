/*:VRX         Rx_readlines
Usage:  rx_readlines(input_file, <flag>)
Where:     input_file = a fully qualified file to be read into an
           exposed stem, "file_lines.", with 1 additional
           stem entry if the file ended with an end-of-file
           character ('1a'x) and the "-eof" flag is set
           flag = "-e<of>" - read and preserve the eof flag ('1a'x)
Result:    1 - the file exists
           0 - the file did not exist
*/
Rx_readlines: Procedure Expose file_lines. verbose log_out log_file
save_trace = Trace('N')
Parse Arg input_file, flag
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
flag = Translate(flag)
set_eof = (Pos('E', flag) <> 0)
If Stream(input_file, 'c', 'query exists') <> '' Then
   Do
      Call Stream input_file, 'c', 'open read'
      If set_eof Then
         Do
            /* check for eof character */
            file_size = Stream(input_file, 'c', 'query size')
            If Charin(input_file, file_size, 1) = '1a'x Then
               eof = 1
            Else
               eof = 0
            Call Stream input_file, 'c', 'close'
         End
      Else
         eof = 0
      Call Stream input_file, 'c', 'open read'
      file_lines. = ''
      file_lines.0 = 0
      Do i = 1 Until Lines(input_file) = 0
         file_lines.i = Linein(input_file)
      End
      file_lines.0 = i
      If eof Then
         Do
            i = file_lines.0 + 1
            file_lines.i = '1a'x
            file_lines.0 = i
         End
      Call Stream input_file, 'c', 'close'
      xrc = 1
   End
Else
   xrc = 0
Trace(save_trace)
Return xrc
