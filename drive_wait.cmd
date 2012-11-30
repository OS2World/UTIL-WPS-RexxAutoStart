/*:VRX */
_drivewait:
/* drive wait logic */
Parse Arg obj_id
Call Rxfuncadd 'WPToolsLoadFuncs', 'WPTOOLS', 'WPToolsLoadFuncs'
Call WPToolsLoadFuncs
If WPToolsQueryObject(obj_id, , ,szsetup) Then
   Do
      Parse Value('.' szsetup) With . 'EXENAME=' obj_exe ';'
      If obj_exe \= '' Then
         Do
            drive_exe = Stream(obj_exe, 'c', 'query exists')
            If drive_exe = '' Then
               Do
                  obj_exe = SysSearchPath('path', obj_exe)
                  If obj_exe \= '' Then
                     drive_exe = Stream(obj_exe, 'c', 'query exists')
               End
         End
      Parse Value('.' szsetup) With . 'STARTUPDIR=' obj_work ';'
      If obj_work \= '' Then
         drive_work = Stream(obj_work || '\*', 'c', 'query exists')
trace 'i'
      obj_parms. = ''
      obj_parms.0 = 0
      Parse Value('.' szsetup) With . 'PARAMETERS=' obj_parms ';'
      If obj_parms \= '' Then
         Do
            next_pos = Pos(':\', obj_parms)
            Do i = 1 While next_pos \= 0
               Parse Value('.' obj_parms) With . +(next_pos) obj_parm_found .
               j = obj_parms.0 + 1
               obj_parms.j = obj_parm_found
               obj_parms.0 = j
               next_pos = Pos(':\', obj_parms, next_pos + 1)
            End
            next_pos = Pos('\\', obj_parms)
            Do i = 1 While next_pos \= 0
               Parse Value('.' obj_parms) With . +(next_pos) obj_parm_found .
               j = obj_parms.0 + 1
               obj_parms.j = obj_parm_found
               obj_parms.0 = j
               next_pos = Pos('\\', obj_parms, next_pos + 1)
            End
            Do i = 1 To obj_parms.0
               xrc = SysFileTree(obj_parms.i, 'obj_test.', 'bo')
               If xrc = 0 & obj_test.0 \=0 Then
                  Do j = 1 To obj_test.0
                     If translate(obj_parms.i) = translate(obj_test.j) Then
                        obj_parms.i = ''
                  End
            End
         End
      If drive_exe = '' Then
         Call _sayout 'Waiting for access to' obj_exe || '.'
      Else
         drive_info = 1
      If obj_work \= '' & drive_work = '' Then
         Do
            Call _sayout 'Waiting for access to' obj_work || '.'
            drive_info = 0
         End
      Else
         drive_info = 1
      Do i = 1 To obj_parms.0
         If obj_parms.i \= '' Then
            Do
               Call _sayout 'Waiting for access to' obj_parms.i || '.'
               drive_info = 0
            End
      End
   End

Return drive_info                          /* 1 = success 0 = failure */

Checkforevent:
Return
_sayout: Procedure
Parse Arg text
Say text
Return
