/*
package - build a package
Copyright 2000, 2001 by Chuck McKinnis,  Sandia Park, NM (USA)
mckinnis@attglobal.net
*/

Trace 'N'

Parse Arg package

Parse Var package package '.' .

package_file = package || '.zip'
config_file = package || '.pak'
zip_norm = '-ojX'
zip_zip = '-ojX0'
zip_path = '-oDrX'
zip_dir = '-oDX'

Call Rxfuncadd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
Call SysLoadFuncs

config_file = Stream(config_file, 'c', 'query exists')
If config_file \= '' Then
   Do i = 1 While Lines(config_file) > 0
      config.i = Linein(config_file)
   End
Else
   Signal Cleanup
config.0 = i

If Stream(package_file, 'c', 'query exists') \= '' Then
   Call SysFileDelete package_file

package_drive = Filespec('d', config_file)


Do i = 1 To config.0
   zip_parm = ''
   If config.i = '' | Abbrev(config.i, ';') Then
      Iterate i
   Parse Var config.i action from_file to_file to_options
   Select
      When Translate(action) = 'REXX2EXE' Then
         Address cmd 'rexx2exe' from_file to_file to_options
      When Translate(action) = 'ERASE' Then
         Call SysFileDelete from_file
      When Translate(action) = 'INF' Then
         Address cmd 'ipfc' to_options from_file to_file
      When Translate(action) = 'HELP' Then
         Address cmd 'ipfc' to_options from_file to_file
      When Translate(action) = 'ZIP' Then
         Do
            If Abbrev(from_file, '-') Then
               Parse Var config.i action zip_parm from_file to_file
            If to_file = '' Then
               to_file = package_file
            Select
               When zip_parm <> '' Then
                  Do
                     Address cmd 'zip' zip_parm to_file from_file
                  End
               When Abbrev(from_file, '.\*') Then
                  Do
                     zip_parm = zip_path
                     rc = SysFileTree(from_file, 'files.', 'dso')
                     If rc = 0 & files.0 > 0 Then
                        Do j = 1 To files.0
                           Address cmd 'zip' zip_parm to_file files.j || '\*'
                        End
                  End
               When Abbrev(from_file, '.\') | ,
                  Abbrev(from_file, '..\') | ,
                  Substr(from_file, 2, 1) = ':' Then
                  Do
                     zip_parm = zip_dir
                     Address cmd 'zip' zip_parm to_file from_file
                  End
               Otherwise Do
                  If Translate(Substr(from_file, Lastpos('.', from_file) + 1)) <> 'ZIP' Then
                     zip_parm = zip_norm
                  Else
                     zip_parm = zip_zip
                  If Substr(from_file, 2, 1) <> ':' Then
                     from_file = package_drive || from_file
                  Address cmd 'zip' zip_parm to_file from_file
               End
            End                                             /* select */
         End
      Otherwise Nop
   End
End

Cleanup:
Return 0
