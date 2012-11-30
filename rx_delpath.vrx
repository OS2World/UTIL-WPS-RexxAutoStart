/*:VRX         Rx_delpath
Usage:  rx_delpath(path_name, flags)
Where:     path_name = fully qualified name of path to be deleted
           flags = none defined, action is final
Result:    1 if path deleted or did not exist, 0 otherwise
*/
Rx_delpath: Procedure Expose verbose log_out log_file
save_trace = Trace('N')
Parse Upper Arg path_name
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
xrc = 0
path_name = Strip(path_name, 't', '\')
/* delete all of the files */
xrc = SysFileTree(path_name || '\*', 'files.', fso, , '**---')
if xrc = 0 & files.0 <> 0 then
   Do j = 1 To files.0 While xrc = 0
      xrc = SysFileDelete(files.j)
   End
/* delete all of the directories */
xrc = SysFileTree(path_name || '\*', 'path.', 'dso')
do while xrc = 0 & path.0 <> 0
   do i = 1 to path.0 while xrc = 0
      xrc = sysfiletree(path.i || '\*', 'test.', 'dso')
      if xrc = 0 & test.0 = 0 then do
         address cmd '@rmdir' path.i
         xrc = rc
         leave i
      end
   end
   xrc = SysFileTree(path_name || '\*', 'path.', 'dso')
End
address cmd '@rmdir' path_name
xrc = rc
Trace(save_trace)
xrc = (xrc = 0)
Return xrc
