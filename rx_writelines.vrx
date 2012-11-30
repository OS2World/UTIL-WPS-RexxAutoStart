/*:VRX         Rx_writelines
Usage:  rx_writelines(output_file)
Where:     output_file = a fully qualified file to be written from an
           exposed stem, "file_lines.".  If the last entry in the stem
           is an end-of-file character ('1a'x), the file will be
           terminated with an end-of-file character.
Result:    1 - always
*/
Rx_writelines: Procedure Expose file_lines. verbose log_out log_file
save_trace = Trace('N')
Parse Arg output_file
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
Call Stream output_file, 'c', 'open write'
x = file_lines.0
If file_lines.x = '1a'x Then
   eof = 1
Else
   eof = 0
chars_out = 0
Do i = 1 To file_lines.0
   If \eof Then
      Call Lineout output_file, file_lines.i
   Else
      Do
         If eof & i <> (file_lines.0) Then
            Do
               Call Lineout output_file, file_lines.i
               chars_out = chars_out + Length(file_lines.i) + 2
            End
         Else
            Call Charout output_file, '1a'x, (chars_out + 1)
      End
End
Call Stream output_file, 'c', 'close'
Trace(save_trace)
Return 1
