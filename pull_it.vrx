/*:VRX         Pull_it
Usage:  pull_it(<how_much>)
Where:     how_much = "all" - pull complete message without translation
           otherwise only pull first word of message in upper case
Result:    answer in upper case (not "all") or
           relative indentation of subsequent messages)
*/
Pull_it: Procedure Expose verbose log_out log_file
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
Parse Upper Arg how_much .
If \Abbrev(how_much, 'A') Then
   Do
      Parse Upper Pull ans .
      save_verbose = verbose
      verbose = 0
      Call Sayout 'Reply =' ans, 1
      verbose = save_verbose
   End
Else
   Do
      Parse Pull ans
      Call Sayout ans, 1
   End
Trace (save_trace)
Return ans
