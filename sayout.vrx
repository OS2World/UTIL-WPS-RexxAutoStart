/*:VRX         Sayout
Usage:  sayout(msg, <indent>)
Where:     msg = message to be displayed and/or logged
           indent = number of spaces to indent message
Result:    number of spaces indented (can be used for
           relative indentation of subsequent messages)
*/
Sayout: Procedure Expose verbose log_out log_file
/* console and log file output */
save_trace = Trace('N')
/* test exposed parameters */
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
Parse Arg msg, level
If \Datatype(level, 'W') Then
   level = 0
msg = Copies(' ', level) || msg
If verbose Then
   Say msg
If log_out Then
   Call Lineout log_file, Date() Time() msg
Trace (save_trace)
Return level
