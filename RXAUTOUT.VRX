/*:VRX         Main
*/
/*  Main
*/
Main:
/*  Process the arguments.
    Get the parent window.
*/
Parse Source . calledas .
parent = ""
argcount = Arg()
argoff = 0
If( calledas \= "COMMAND" )Then
   Do
      If argcount >= 1 Then
         Do
            parent = Arg(1)
            argcount = argcount - 1
            argoff = 1
         End
   End; Else
   Do
      Call VROptions 'ImplicitNames'
      Call VROptions 'NoEchoQuit'
   End
initargs.0 = argcount
If( argcount > 0 )Then
   Do i = 1 To argcount
      initargs.i = Arg( i + argoff )
   End
Drop calledas argcount argoff

/*  Load the windows
*/
Call VRInit
Parse Source . . spec
_vreprimarywindowpath = ,
   VRParseFileName( spec, "dpn" ) || ".VRW"
_vreprimarywindow = ,
   VRLoad( parent, _vreprimarywindowpath )
Drop parent spec
If( _vreprimarywindow == "" )Then
   Do
      Call VRMessage "", "Cannot load window:" VRError(), ,
         "Error!"
      _vrereturnvalue = 32000
      Signal _vreleavemain
   End

/*  Process events
*/
Call Init
Signal On Halt
Do While( \ VRGet( _vreprimarywindow, "Shutdown" ) )
   _vreevent = VREvent()
   Interpret _vreevent
End
_vrehalt:
_vrereturnvalue = Fini()
Call VRDestroy _vreprimarywindow
_vreleavemain:
Call VRFini
Exit _vrereturnvalue

Vrloadsecondary:
__vrlswait = Abbrev( 'WAIT', Translate(Arg(2)), 1 )
If __vrlswait Then
   Do
      Call VRFlush
   End
__vrlshwnd = VRLoad( VRWindow(), VRWindowPath(), Arg(1) )
If __vrlshwnd = '' Then
   Signal __vrlsdone
If __vrlswait \= 1 Then
   Signal __vrlsdone
Call VRSet __vrlshwnd, 'WindowMode', 'Modal'
__vrlstmp = __vrlswindows.0
If( Datatype(__vrlstmp) \= 'NUM' ) Then
   Do
      __vrlstmp = 1
   End
Else
   Do
      __vrlstmp = __vrlstmp + 1
   End
__vrlswindows.__vrlstmp = VRWindow( __vrlshwnd )
__vrlswindows.0 = __vrlstmp
Do While( VRIsValidObject( VRWindow() ) = 1 )
   __vrlsevent = VREvent()
   Interpret __vrlsevent
End
__vrlstmp = __vrlswindows.0
__vrlswindows.0 = __vrlstmp - 1
Call VRWindow __vrlswindows.__vrlstmp
__vrlshwnd = ''
__vrlsdone:
Return __vrlshwnd

/*:VRX         _INIWrite
*/
_iniwrite:
ok = VRSetIni( "workplace_shell", "wps_wait", wps_wait, our_ini, "Noclose" )
ok = VRSetIni( "workplace_shell", "sc_wait", sc_wait, our_ini, "Noclose" )
ok = VRSetIni( "workplace_shell", "sc_open", sc_open, our_ini, "Noclose" )
Call Update_autostart 'warpcenter', sc_wait, sc_open
ok = VRSetIni( "workplace_shell", "tb_wait", tb_wait, our_ini, "Noclose" )
ok = VRSetIni( "workplace_shell", "tb_open", tb_open, our_ini, "Noclose" )
Call Update_autostart 'toolbar', tb_wait, tb_open
ok = VRSetIni( "workplace_shell", "xc_wait", xc_wait, our_ini, "Noclose" )
ok = VRSetIni( "workplace_shell", "xc_open", xc_open, our_ini, "Noclose" )
ok = VRSetIni( "workplace_shell", "startup_wait", wps_wait, our_ini, "Noclose" )
ok = VRSetIni( "workplace_shell", "delay_wait", delay_wait, our_ini, "Noclose" )
ok = VRSetIni( "object_desktop", "od_wait", od_cc | od_tlp, our_ini, "Noclose" )
ok = VRSetIni( "object_desktop", "od_cc", od_cc, our_ini, "Noclose" )
ok = VRSetIni( "object_desktop", "od_tlp", od_tlp, our_ini, "NoClose" )
ok = VRSetIni( "object_desktop", "od_tries", od_tries, our_ini, "Noclose" )

ok = VRSetIni( "folders", "startupfolder", startupfolder, our_ini )
If enablexstart Then
   Do
      folder_id = VRGetIni('XWorkplace', 'XStartupFolders', 'User')
      If folder_id <> '' Then
         Do
            If VRSetIni( "folders", "XStartupFolders", folder_id, our_ini ) Then
               ok = VRDelIni('XWorkplace', 'XStartupFolders', 'User')
         End
      folder_id = VRGetIni('XWorkplace', 'XSavedStartupFolders', 'User')
      If folder_id <> '' Then
         Do
            If VRSetIni( "folders", "XSavedStartupFolders", folder_id, our_ini ) Then
               ok = VRDelIni('XWorkplace', 'XSavedStartupFolders', 'User')
         End
   End
Else
   Do
      folder_id = VRGetIni('folders', 'XStartupFolders', our_ini)
      If folder_id <> '' Then
         Do
            If VRSetIni( "XWorkplace", "XStartupFolders", folder_id, "User" ) Then
               ok = VRDelIni('folders', 'XStartupFolders', our_ini)
         End
      folder_id = VRGetIni('folders', 'XSavedStartupFolders', our_ini)
      If folder_id <> '' Then
         Do
            If VRSetIni( "XWorkplace", "XSavedStartupFolders", folder_id, "User" ) Then
               ok = VRDelIni('folders', 'XSavedStartupFolders', our_ini)
         End
   End
ok = VRSetIni( "folders", "enablexstart", enablexstart, our_ini, "Noclose" )
ok = VRSetIni( "objects", "sleepsec", sleepsec, our_ini, "Noclose" )
ok = VRSetIni( "objects", "retries", retries, our_ini, "Noclose" )
ok = VRSetIni( "folders", "enablelanstart", enablelanstart, our_ini, "Noclose" )
ok = VRSetIni( "folders", "simplelogononly", simplelogononly, our_ini, "Noclose" )
ok = VRSetIni( "folders", "lanstartupfolder", lanstartupfolder, our_ini, "Noclose" )
ok = VRSetIni( "objects", "ls_sleepsec", ls_sleepsec, our_ini, "Noclose" )
ok = VRSetIni( "objects", "ls_retries", ls_retries, our_ini, "Noclose" )

ok = VRSetIni( "debug", "log_out", log_out, our_ini, "Noclose" )
ok = VRSetIni( "debug", "verbose", verbose, our_ini, "Noclose" )
ok = VRSetIni( "RexxAutoStart", "Sound", sound, our_ini, "Noclose" )
ok = VRSetIni( "sound", "sound_open", sound_open, our_ini, "Noclose" )
ok = VRSetIni( "sound", "sound_done", sound_done, our_ini, "Noclose" )
ok = VRSetIni( "sound", "sound_abort", sound_abort, our_ini, "Noclose" )
ok = VRSetIni( "sound", "sound_start", sound_start, our_ini )
ini_changes = 0
If new_autostart <> old_autostart Then
   Do
      /* update CONFIG.SYS */
      Parse Value(_rxfindlines(old_autostart, config_sys)) ,
         With autostart_line_no autostart_line '|' autostart_line_rem
      If autostart_line_no <> 0 Then
         Do
            file_lines. = ''
            file_lines.0 = 0
            /* REM out the current SET AUTOSTART= line */
            autostart_line = 'REM' autostart_line
            xrc = _rxupdline(autostart_line_no, autostart_line, config_sys)
            /* add updated SET AUTOSTART= */
            new_autostart = 'SET AUTOSTART='||new_autostart
            xrc = _rxupdline(autostart_line_no, new_autostart, config_sys, 'insert', 'close')
         End
   End
Return

/*:VRX         _RxFindLines
*/
_rxfindlines: Procedure
/* find a phrase in a file and return the line number,
   line, and all remmed out lines containing the phrase */
Parse Arg phrase, file

found_line_no = 0
found_line = ''
line_rem_no = ''
If phrase <> '' & Stream(file, 'c', 'query exists') <> '' Then
   Do
      Call Stream file, 'c', 'close'
      xrc = SysFileSearch(phrase, file, 'lines.', 'N')
      If xrc = 0 & lines.0 <> 0 Then
         Do i = 1 To lines.0
            Parse Var lines.i line_no line
            line_test = Strip(Strip(Translate(line), , "'"), , '"')
            If Abbrev(line_test, 'REM') ,
               | Abbrev(line_test, '/*') ,
               | Abbrev(line_test, ';') Then
               Do
                  line_rem_no = line_rem_no line_no
                  Iterate i
               End
            Else
               Do
                  found_line_no = line_no
                  found_line = line
               End
         End
   End

Return found_line_no found_line '|' Strip(line_rem_no)

/*:VRX         _RxReadLines
*/
_rxreadlines: Procedure Expose file_lines.
Parse Arg file
Call Stream file, 'c', 'open read'
file_lines. = ''
file_lines.0 = 0
Do i = 1 While Lines(file) > 0
   file_lines.i = Linein(file)
End
file_lines.0 = i
Call Stream file, 'c', 'close'
Return

/*:VRX         _RxUpdLine
*/
_rxupdline: Procedure Expose file_lines.
Parse Arg line_no, line, file, action, close
xrc = 1
replace = 0
insert = Abbrev(Translate(action), 'I')
If \insert Then
   replace = 1
close = Abbrev(Translate(close), 'C')
If file_lines.0 = 0 Then
   Call _rxreadlines file

If replace Then
   file_lines.line_no = line
Else                                             /* insert a new line */
   Do
      Do i = file_lines.0 To (line_no + 1) By -1
         j = i + 1
         file_lines.j = file_lines.i
      End
      j = line_no + 1
      file_lines.j = line
      file_lines.0 = file_lines.0 + 1
   End

If close Then
   Do
      xrc = 0
      save_file = SysTempFileName(VRParseFileName( file, "DPN" ) || '.???')
      buttons.1 = "OK"
      buttons.2 = "Cancel"
      buttons.0 = 2
      id = VRMessage( VRWindow(), "Ready to rewrite" file, "", "Query", "Buttons.", , )
      If id = 1 Then
         Do
            ok = VRCopyFile( file, save_file )
            If ok Then
               Do
                  ok = VRDeleteFile( file )
                  If ok Then
                     Do
                        Call _rxwritelines file
                        xrc = 1
                        lines.1 = "Updated" file
                        lines.2 = file "was saved as" save_file
                        lines.0 = 2
                        id = VRMessageStem( VRWindow(), "Lines.", "", "Information", , , )
                     End
                  Else
                     Do
                        error = VRError()
                        id = VRMessage( VRWindow(), error, "", "Information", , , )
                        xrc = 0
                        lines.1 = "Deletion of" file "failed"
                        lines.2 = file "was saved as" save_file
                        lines.0 = 2
                        id = VRMessageStem( VRWindow(), "Lines.", "", "Information", , , )
                     End
               End
            Else
               Do
                  error = VRError()
                  id = VRMessage( VRWindow(), error, "", "Information", , , )
                  xrc = 0
                  lines.1 = "Unable to copy" file
                  lines.2 = file "should be intact"
                  lines.0 = 2
                  id = VRMessageStem( VRWindow(), "Lines.", "", "Information", , , )
               End
         End
      Else
         Do
            xrc = 0
            id = VRMessage( VRWindow(), "Update of" file "aborted", "", "Information", , , )
         End
      file_lines. = ''
      file_lines.0 = 0
   End
Return xrc
/*:VRX         _RxWriteLines
*/
_rxwritelines: Procedure Expose file_lines.
Parse Arg file
Call Stream file, 'c', 'open write'
Do i = 1 To file_lines.0
   Call Lineout file, file_lines.i
End
Call Stream file, 'c', 'close'
Return

/*:VRX         AboutBox_Close
*/
Aboutbox_close:
Call Aboutbox_fini
Return

/*:VRX         AboutBox_Create
*/
Aboutbox_create:
Call Aboutbox_init
Return

/*:VRX         AboutBox_Fini
*/
Aboutbox_fini:
window = VRInfo( "Window" )
Call VRDestroy window
Drop window
Return
/*:VRX         AboutBox_Init
*/
Aboutbox_init:
window = VRInfo( "Object" )
If( \VRIsChildOf( window, "Notebook" ) ) Then
   Do
      Call VRMethod window, "CenterWindow"
      Call VRSet window, "Visible", 1
      Call VRMethod window, "Activate"
   End
Drop window
Return

/*:VRX         CB_DELAY_Click
*/
Cb_delay_click:
If VRGet("CB_DELAY","set") Then
   Do
      ok = VRSet("SPIN_delay_wait","Enabled", 1)
      delay_wait = VRGet("SPIN_delay_wait","Value")
   End
Else
   Do
      ok = VRSet("SPIN_delay_wait","Value", 0)
      ok = VRSet("SPIN_delay_wait","Enabled", 0)
   End
ini_changes = 1
Return

/*:VRX         CB_EnableLanStartUpFolder_Click
*/
Cb_enablelanstartupfolder_click:
enablelanstart = VRGet("CB_EnableLanStartUpFolder","set")
If \enablelanstart Then
   simplelogononly = 0
ok = VRSet("CB_SimpleLogonOnly","Set", simplelogononly)
ok = VRSet( "CB_SimpleLogonOnly", "Enabled", enablelanstart )
ok = VRSet("EF_LANStartupfolder","Enabled", enablelanstart )
ok = VRSet("SPIN_ls_sleepsec","Enabled", enablelanstart )
ok = VRSet("SPIN_ls_retries","Enabled", enablelanstart )
ini_changes = 1
Return

/*:VRX         CB_EnableXStartUpFolder_Click
*/
Cb_enablexstartupfolder_click:
enablexstart = VRGet("CB_EnableXStartUpFolder","Set")
xwpstartup = (VRGetIni('XWorkplace', 'XStartupFolders', 'User') <> '')
xstartup = (VRGetIni( "folders", "xstartupfolder", our_ini ) <> '')
ok = VRSet("CB_EnableXStartupfolder","Enabled", xwpstartup | xstartup )
ini_changes = 1
Return

/*:VRX         CB_log_out_Click
*/
Cb_log_out_click:
log_out = VRGet("CB_log_out","set")
ini_changes = 1
Return

/*:VRX         CB_od_cc_Click
*/
Cb_od_cc_click:
od_cc = VRGet("CB_od_cc","set")
If (od_cc | od_tlp) & objdesk Then
   od_wait = 1
Else
   od_wait = 0
ini_changes = 1
Return

/*:VRX         CB_od_tlp_Click
*/
Cb_od_tlp_click:
od_tlp = VRGet("CB_od_tlp","set")
If (od_cc | od_tlp) & objdesk Then
   od_wait = 1
Else
   od_wait = 0
ini_changes = 1
Return

/*:VRX         CB_ODInstalled_Click
*/
Cb_odinstalled_click:
ok = SysIni('USER', 'WPTS','ALL:',appstem.)
objdesk = (appstem.0 > 0)
ok = VRSet("CB_ODInstalled","set",objdesk)
If objdesk Then
   ok = VRSet("CB_ODInstalled", "caption", "Object Desktop is installed")
Else
   ok = VRSet("CB_ODInstalled", "caption", "Object Desktop is not installed")
If (od_cc | od_tlp) & objdesk Then
   od_wait = 1
Else
   od_wait = 0
Return

/*:VRX         CB_SimpleLogonOnly_Click
*/
Cb_simplelogononly_click:
simplelogononly = VRGet("CB_SimpleLogonOnly","set")
ini_changes = 1
Return

/*:VRX         CB_Sound_Click
*/
Cb_sound_click:
sound = VRGet("CB_Sound","set")
ini_changes = 1
Return

/*:VRX         CB_startup_wait_Click
*/
Cb_startup_wait_click:
startup_wait = VRGet( "CB_startup_wait", "Set" )
ini_changes = 1
Return

/*:VRX         CB_verbose_Click
*/
Cb_verbose_click:
verbose = VRGet("CB_verbose","set")
ini_changes = 1
Return

/*:VRX         CB_wps_wait_Click
*/
Cb_wps_wait_click:
wps_wait = VRGet( "CB_wps_wait", "Set" )
ini_changes = 1
Return

/*:VRX         Check_startup
*/
Check_startup: 
Procedure Expose old_autostart
Parse Arg auto, obj, class, startup, .
If auto <> '' Then
   test_auto = (Pos(Translate(auto), Translate(old_autostart)) <> 0)
Else
   test_auto = 1
test_obj = WPToolsQueryObject(obj)
test_class = 0
test_startup = 0
If test_auto & test_obj Then
   Do
      Call SysQueryClassList 'classes.'
      Do x = 1 To classes.0
         If Abbrev(Translate(classes.x), Translate(class)),
            | class = '' Then
            Do
               test_class = 1
               If WPToolsFolderContent(startup, 'objects.') Then
               Do y = 1 To objects.0
                  If Abbrev(Translate(objects.y), Translate(obj)) Then
                     Do
                        test_startup = 1
                        Leave y
                     End
                  If WPToolsQueryObject(objects.y, , , 'szSetup') Then
                     Do
                        Parse Value('.' szSetup) With . 'SHADOWID=' shadow ';'
                        If Abbrev(Translate(Strip(shadow)), Translate(obj)) Then
                           Do
                              test_startup = 1
                              Leave y
                           End
                     End
               End
               Drop objects.
               Leave x
            End
      End
      Drop classes.
   End
Return (test_auto & test_obj & test_class & \test_startup)
/*:VRX         EF_LANStartUpFolder_Change
*/
Ef_lanstartupfolder_change:
ini_changes = (lanstartupfolder <> VRGet("EF_LANstartUpFolder","Value"))
lanstartupfolder = VRGet("EF_LANstartUpFolder","Value")
If Left(lanstartupfolder,1) \= '<' | Right(lanstartupfolder,1) \= '>' Then
   Do
      ok = VRSet("EF_LANstartUpFolder","BackColor","Red")
   End
Else
   ok = VRSet("EF_LANstartUpFolder","BackColor","<default>")
Return

/*:VRX         EF_StartUpFolder_Change
*/
Ef_startupfolder_change:
ini_changes = (startupfolder <> VRGet("EF_StartUpFolder","Value"))
startupfolder = VRGet("EF_StartUpFolder","Value")
If Left(startupfolder,1) \= '<' | Right(startupfolder,1) \= '>' Then
   Do
      ok = VRSet("EF_StartUpFolder","BackColor","Red")
   End
Else
   ok = VRSet("EF_StartUpFolder","BackColor","<default>")
Return

/*:VRX         Fini
*/
Fini:
window = VRWindow()
Call VRSet window, "Visible", 0
Drop window
Return 0

/*:VRX         GetBootDrive
*/
Getbootdrive:
/* Use SysBootDrive if possible */
If Rxfuncadd('SysBootDrive', 'RexxUtil', 'SysBootDrive') Then
   Return Left(Value('RUNWORKPLACE',,'OS2ENVIRONMENT'),2)
Else
   Return SysBootDrive()
/*:VRX         Halt
*/
Halt:
Signal _vrehalt
Return

/*:VRX         Init
*/
Init:
Call Rxfuncadd 'SysLoadFuncs','Rexxutil','SysLoadFuncs'
Call SysLoadFuncs
Call Rxfuncadd 'WPToolsLoadFuncs', 'WPTOOLS', 'WPToolsLoadFuncs'
Call WPToolsLoadFuncs
ok = VRRedirectStdIO('OFF')
bootdrive = Getbootdrive()
config_sys = bootdrive||'\config.sys'
startup_cmd = bootdrive||'\startup.cmd'
our_drive = VRCurrDrive()
our_dir = our_drive || VRCurrDir( our_drive )
our_ini = our_dir || '\RXAUTOST.INI'
our_log = our_dir || '\RXAUTOST.LOG'
startup_line = Translate('@START /MIN' our_dir||'\RXAUTOST.EXE' our_dir||'\RXAUTOST.EXE')
If VRFileExists( our_dir || '\rxautost.lvl' ) Then
   Do
      level = Strip(Linein(our_dir || '\rxautost.lvl'))
      Call Stream our_dir || '\rxautost.lvl', 'c', 'close'
      level = level Stream(our_dir || '\rxautout.exe', 'c', 'query timestamp')
   End
Else
   level = ''
caption = VRGet( "RxAutoUtMain", "Caption" )
ok = VRSet( "RxAutoUtMain", "Caption", caption level )
window = VRWindow()
Call VRMethod window, "CenterWindow"
Call VRSet window, "Visible", 1
Call VRMethod window, "Activate"
Drop window
ini_changes = Migrate_rexxautostart(our_ini, bootdrive)
Parse Value(_rxfindlines('autostart=', config_sys)) ,
   With line_no . '=' old_autostart '|' .
old_autostart = Strip(old_autostart)
new_autostart = old_autostart
Return
/*:VRX         MenuFileExit_Click
*/
Menufileexit_click:
Call Quit
Return

/*:VRX         MenuHelp_Click
*/
Menuhelp_click:

Return

/*:VRX         MenuHelpAbout_Click
*/
Menuhelpabout_click:
window = Vrloadsecondary( "AboutBox", "W" )
Return

/*:VRX         MenuHelpViewManual_Click
*/
Menuhelpviewmanual_click:
'view rxautost.inf'
Return

/*:VRX         MenuRexxAutostartActivate_Click
*/
Menurexxautostartactivate_click: Procedure Expose bootdrive file_lines. isrexx ini_changes startup_line
config_sys = bootdrive || '\config.sys'
startup_cmd = bootdrive || '\startup.cmd'
/* update CONFIG.SYS */
Parse Value(_rxfindlines('restartobjects=no', config_sys)) ,
   With restart_line_no restart_line '|' restart_line_rem
If restart_line_no = 0 Then
   Do
      file_lines. = ''
      file_lines.0 = 0
      Parse Value(_rxfindlines('restartobjects=', config_sys)) ,
         With restart_line_no restart_line '|' .
      /* REM out the current SET RESTARTOBJECTS= line */
      restart_line = 'REM' restart_line
      xrc = _rxupdline(restart_line_no, restart_line, config_sys)
      /* do we have a SET RESTARTOBJECTS=NO line? */
      save_restart_line_no = restart_line_no
      If Words(restart_line_rem) \= 0 Then
         Do
            restart_line_no = Word(restart_line_rem, 1)
            restart_line = 'SET RESTARTOBJECTS=NO'
            action = 'replace'
         End
      Else
         Do
            restart_line_no = save_restart_line_no
            restart_line = 'SET RESTARTOBJECTS=NO'
            action = 'insert'
         End
      xrc = _rxupdline(restart_line_no, restart_line, config_sys, action, 'close')
   End
Else
   xrc = 1

/* update STARTUP.CMD */
If xrc Then
   Do
      file_lines. = ''
      file_lines.0 = 0
      If isrexx Then
         startup_line = 'Address cmd' '"' || startup_line || '"'
      /* do we have a startup.cmd file ? */
      If Stream(startup_cmd, 'c', 'query exists') \= '' Then
         Do
            Parse Value(_rxfindlines('rxautost.exe', startup_cmd)) With ,
               startup_line_no startup_line_current '|' startup_line_rem
            /* do we have a rxautost.exe line? */
            If startup_line_no = 0 Then
               Do
                  /* is it REMed out? */
                  If Words(startup_line_rem) \= 0 Then
                     Do
                        action = 'replace'
                        startup_line_no = Word(startup_line_rem, 1)
                     End
                  Else
                     Do
                        action = 'insert'
                        startup_line_no = 0
                     End
                  xrc = _rxupdline(startup_line_no, startup_line, startup_cmd, action, 'close')
               End
            Else
               Do
                  If Pos(startup_line, startup_line_current) = 0 Then 
                     xrc = _rxupdline(startup_line_no, startup_line, startup_cmd, 'replace', 'close')
               End
         End
      Else
         Do
            xrc = _rxupdline(0, 'REM * * * added by RxAutoUt * * *', startup_cmd, 'insert')
            xrc = _rxupdline(1, startup_line, startup_cmd, 'insert')
            xrc = _rxupdline(2, 'EXIT', startup_cmd, 'insert', 'close')
         End
   End
Else
   id = VRMessage( VRWindow(), "Update of" startup_cmd "bypassed due to failure to update" config_sys, "", "Information", "", , )
Call Page4_create 'no_init'
ini_changes = 1
Return
/*:VRX         MenuRexxAutostartDeactivate_Click
*/
Menurexxautostartdeactivate_click: Procedure Expose bootdrive file_lines. isrexx ,
   enablexstart ini_changes
config_sys = bootdrive || '\config.sys'
startup_cmd = bootdrive || '\startup.cmd'
/* update CONFIG.SYS */
Parse Value(_rxfindlines('restartobjects=no', config_sys)) With ,
   restart_line_no restart_line '|' restart_line_rem
If restart_line_no \= 0 Then
   Do
      file_lines. = ''
      file_lines.0 = 0
      /* REM out the SET RESTARTOBJECTS=NO line */
      restart_line = 'REM' restart_line
      xrc = _rxupdline(restart_line_no, restart_line, config_sys)
      save_restart_line_no = restart_line_no
      /* do we have a SET RESTARTOBJECTS=STARTUPFOLDERSONLY line? */
      Parse Value(_rxfindlines('restartobjects=startupfoldersonly',config_sys)) With ,
         restart_line_no restart_line '|' restart_line_rem
      If Words(restart_line_rem) \= 0 Then
         Do
            restart_line_no = Word(restart_line_rem, 1)
            restart_line = 'SET RESTARTOBJECTS=STARTUPFOLDERSONLY'
            action = 'replace'
         End
      Else
         Do
            restart_line_no = save_restart_line_no
            restart_line = 'SET RESTARTOBJECTS=STARTUPFOLDERSONLY'
            action = 'insert'
         End
      xrc = _rxupdline(restart_line_no, restart_line, config_sys, action, 'close')
   End
Else
   xrc = 1

/* update STARTUP.CMD */
If xrc Then
   Do
      file_lines. = ''
      file_lines.0 = 0
      Parse Value(_rxfindlines('rxautost.exe', startup_cmd)) With ,
         startup_line_no startup_line '|' startup_line_rem
      If startup_line_no \= 0 Then
         Do
            If \isrexx Then
               startup_line = 'REM' startup_line
            Else
               startup_line = '/*' startup_line '*/'
            xrc = _rxupdline(startup_line_no, startup_line, startup_cmd, , 'close')
         End
      xrc = 1
   End
Else
   id = VRMessage( VRWindow(), "Update of" startup_cmd "bypassed due to failure to update" config_sys, "", "Information", "", , )
Call Page4_create 'no_init'
If enablexstart Then
   enablexstart = 0
ini_changes = 1
Return 0
/*:VRX         Migrate_rexxautostart
*/
Migrate_rexxautostart: Procedure
Parse Arg our_ini, bootdrive
ini_changes = 0
migrated = (VRGetIni( "RexxAutoStart", "migrate", our_ini ) = 1)
old_parms = ''
If \migrated Then
   Do
      /* do we have a startup.cmd file ? */
      If VRFileExists( bootdrive || '\startup.cmd' ) Then
         Do
            Parse Value _rxfindlines('rxautost', bootdrive || '\startup.cmd') With ,
               startup_line_no startup_line '|' .
            /* do we have a rxautost.exe line ? */
            If startup_line_no <> 0 Then
               Do
                  /* get any parameters */
                  exe_pos = Pos('RXAUTOST', Translate(startup_line))
                  Parse Value Substr(startup_line, exe_pos) With . old_parms
               End
         End
      old_parms = Space(old_parms Value('rxautost', , 'os2environment'))
      If old_parms = '' Then
         ok = VRSetIni( "RexxAutoStart", "migrate", '1', our_ini )
      Else
         Do
            If VRGetIni( "workplace_shell", "wps_wait", our_ini) = '' ,
               & Pos('/WPS', Translate(old_parms)) <> 0 Then
               ok = VRSetIni( "workplace_shell", "wps_wait", '1', our_ini)
            If VRGetIni( "workplace_shell", "sc_wait", our_ini) = '' ,
               & Pos('/SC', Translate(old_parms)) <> 0 ,
               & Pos('WARPCENTER', Translate(Value('AUTOSTART', , 'OS2ENVIRONMENT'))) <> 0 Then
               ok = VRSetIni( "workplace_shell", "sc_wait", '1', our_ini)
            If VRGetIni( "workplace_shell", "tb_wait", our_ini) = '' ,
               & Pos('/TB', Translate(old_parms)) <> 0 ,
               & Pos('TOOLBAR', Translate(Value('AUTOSTART', , 'OS2ENVIRONMENT'))) <> 0 Then
               ok = VRSetIni( "workplace_shell", "tb_wait", '1', our_ini)
            If VRGetIni( "workplace_shell", "delay_wait", our_ini) = '' ,
               & Pos('/D:',Translate(old_parms)) <> 0 Then
               Do
                  Parse Value Translate('.' old_parms) With . '/D:' delay_wait '/' .
                  delay_wait = Strip(delay_wait)
                  If delay_wait <> '' & Datatype(delay_wait, 'W') Then
                     ok = VRSetIni( "workplace_shell", "delay_wait", delay_wait, our_ini)
               End
            If VRGetIni( "object_desktop", "od_wait", our_ini) = '' ,
               & Pos('/OD ', Translate(old_parms)) <> 0 ,
               & VRGetIni('WPTS', 'TSMasterSetup:StartupFlags', 'User') <> '' Then
               ok = VRSetIni( "object_desktop", "od_wait", '1', our_ini )
            If VRGetIni( "object_desktop", "od_cc", our_ini) = '' ,
               & Pos('/ODC ', Translate(old_parms)) <> 0 Then
               ok = VRSetIni( "object_desktop", "od_wait", '1', our_ini )
            If VRGetIni( "object_desktop", "od_tlp", our_ini) = '' ,
               & Pos('/ODT ', Translate(old_parms)) <> 0 Then
               ok = VRSetIni( "object_desktop", "od_wait", '1', our_ini )
            If VRGetIni( "object_desktop", "od_tries", our_ini) = '' ,
               & Pos('/OD:', Translate(old_parms)) <> 0 Then
               Do
                  Parse Value Translate('.' old_parms) With . '/OD:' od_tries '/' .
                  od_tries = Strip(od_tries)
                  If od_tries <> '' & Datatype(od_tries, 'W') Then
                     ok = VRSetIni( "object_desktop", "od_tries", od_tries, our_ini)
               End
            If VRGetIni( "folders", "startupfolder", our_ini) = '' ,
               & Pos('/F:', Translate(old_parms)) <> 0 Then
               Do
                  f_pos = Pos('/F:', Translate(old_parms))
                  If f_pos <> 0 Then
                     Do
                        Parse Value '.' old_parms With . + (f_pos) + 4 startupfolder '/' .
                        startupfolder = Strip(Strip(Strip(startupfolder), , '"'), , "'")
                        ok = VRSetIni( "folders", "startupfolder", startupfolder, our_ini)
                     End
               End
            If VRGetIni( "objects", "retries", our_ini) = '' ,
               & Pos('/R:', Translate(old_parms)) <> 0 Then
               Do
                  Parse Value Translate('.' old_parms) With . '/R:' retries '/' .
                  retries = Strip(retries)
                  If retries <> '' & Datatype(retries, 'W') Then
                     ok = VRSetIni( "objects", "retries", retries, our_ini)
               End
            If VRGetIni( "objects", "sleepsec", our_ini) = '' ,
               & Pos('/P:', Translate(old_parms)) <> 0 Then
               Do
                  Parse Value Translate('.' old_parms) With . '/P:' sleepsec '/' .
                  sleepsec = Strip(sleepsec)
                  If sleepsec <> '' & Datatype(sleepsec, 'W') Then
                     ok = VRSetIni( "objects", "sleepsec", sleepsec, our_ini)
               End
            If VRGetIni( "debug", "log_out", our_ini) = '' ,
               & Pos('/L', Translate(old_parms)) <> 0 Then
               ok = VRSetIni( "debug", "log_out", '1', our_ini)
            If VRGetIni( "debug", "verbose", our_ini ) = '' ,
               & Pos('/V', Translate(old_parms)) <> 0 Then
               ok = VRSetIni( "debug", "verbose", '1', our_ini)
            ok = VRSetIni( "RexxAutoStart", "migrate", '1', our_ini )
            ini_changes = 1
         End
   End
Return ini_changes
/*:VRX         Page1_Close
*/
Page1_close:
Call Page1_fini
Return

/*:VRX         Page1_Create
*/
Page1_create:
Parse Arg no_init
p_init = (no_init = '')
startup_wait = VRGetIni( "workplace_shell", "startup_wait", our_ini, 'Noclose')
If startup_wait = '' Then
   Do
      startup_wait = VRGet("CB_startup_wait","set")
      ini_changes = 1
   End
ok = VRSet("CB_startup_wait","set", startup_wait, "Enabled", VRFileExists( bootdrive || "\startup.cmd" ) )
wps_wait = VRGetIni( "workplace_shell", "wps_wait", our_ini, 'Noclose')
If wps_wait = '' Then
   Do
      wps_wait = VRGet("CB_wps_wait","set")
      ini_changes = 1
   End
ok = VRSet("CB_wps_wait","set", wps_wait )
sc_test = Check_startup('WARPCENTER', '<WP_WARPCENTER>', , '<WP_START>')
sc_wait = VRGetIni( "workplace_shell", "sc_wait", our_ini, 'Noclose')
If sc_wait = '' Then
   Do
      sc_wait = sc_test
      ini_changes = 1
   End
sc_wait = (sc_wait & sc_test)
ok = VRSet( "RB_sc_wait","set", sc_wait, "Enabled", sc_test)
sc_test = Check_startup(, '<WP_WARPCENTER>', , '<WP_START>')
sc_open = VRGetIni( "workplace_shell", "sc_open", our_ini, 'Noclose')
If sc_open = '' Then
   Do
      sc_open = 0
      ini_changes = 1
   End
ok = VRSet("RB_sc_open","set",(sc_open & \sc_wait),"Enabled",sc_test)
tb_test = Check_startup('TOOLBAR', '<WP_LAUNCHPAD>', , '<WP_START>')
tb_wait = VRGetIni( "workplace_shell", "tb_wait", our_ini, 'Noclose')
If tb_wait = '' Then
   Do
      tb_wait = tb_test
      ini_changes = 1
   End
tb_wait = (tb_wait & tb_test)
ok = VRSet( "RB_tb_wait","set", tb_wait, "Enabled", tb_test)
tb_test = Check_startup(, '<WP_LAUNCHPAD>', , '<WP_START>')
tb_open = VRGetIni( "workplace_shell", "tb_open", our_ini, 'Noclose')
If tb_open = '' Then
   Do
      tb_open = 0
      ini_changes = 1
   End
tb_open = (tb_open & tb_test)
ok = VRSet( "RB_tb_open","set",(tb_open & \tb_wait),"Enabled",tb_test)
xc_test = Check_startup(,'<XWP_XCENTER>', 'XCenter', '<WP_START>')
ec_wait = VRGetIni( "workplace_shell", "ec_wait", our_ini, 'Noclose')
If ec_wait <> '' Then
   Do
      ok = VRDelIni( "workplace_shell", "ec_wait", our_ini, 'Noclose') Then
      xc_wait = (ec_wait & xc_test)
      ok = VRSetIni( "workplace_shell", "xc_wait", xc_wait, our_ini, 'Noclose' )
   End
xc_wait = VRGetIni( "workplace_shell", "xc_wait", our_ini, 'Noclose')
xc_wait = (xc_wait & xc_test)
ok = VRSet( "RB_xc_wait","set",xc_wait,"Enabled",xc_test)
xc_open = VRGetIni( "workplace_shell", "xc_open", our_ini, 'Noclose')
If \Datatype(xc_open, 'B') Then
   Do
      xc_open = 0
      ini_changes = 1
   End
ok = VRSet( "RB_xc_open","set",xc_open,"Enabled",xc_test)
delay_wait = VRGetIni( "workplace_shell", "delay_wait", our_ini, 'Noclose')
If delay_wait = '' Then
   Do
      delay_wait = VRGet("SPIN_delay_wait", "Value")
      ini_changes = 1
   End
ok = VRSet("SPIN_delay_wait", "Value", delay_wait )
ok = VRSet("CB_delay","Set", (delay_wait > 0))
od_wait = VRGetIni( "object_desktop", "od_wait", our_ini, 'Noclose')
If od_wait = '' Then
   Do
      od_wait = (VRGetIni('WPTS', 'TSMasterSetup:StartupFlags', 'User') <> '')
      ini_changes = 1
   End
objdesk = (VRGetIni( "WPTS", "InstallDir", "User" ) <> '')
ok = VRSet("CB_ODInstalled","set",objdesk)
If objdesk Then
   Do
      ok = VRSet("CB_ODInstalled", "caption", "Object Desktop is installed")
      od_cc = VRGetIni( "object_desktop", "od_cc", our_ini, 'Noclose')
      If od_cc = '' Then
         od_cc = 0
      ok = VRSet("CB_od_cc", "Set", od_cc, "Enabled", WPToolsQueryObject('<OBJD_CONTROLCENTER>'))
      od_tlp = VRGetIni( "object_desktop", "od_tlp", our_ini )
      If od_tlp = '' Then
         od_tlp = 0
      ok = VRSet("CB_od_tlp", "Set", od_tlp, "Enabled", WPToolsQueryObject('<OBJD_TABLAUNCHPAD>'))
   End
Else
   Do
      ok = VRSet("CB_ODInstalled", "caption", "Object Desktop is not installed")
      od_cc = 0
      od_tlp = 0
   End
od_tries = VRGetIni( "object_desktop", "od_tries", our_ini, 'Noclose')
If od_tries = '' Then
   Do
      od_tries = 30
      ini_changes = 1
   End
ok = VRSet("SPIN_od_tries","Value", od_tries )
If p_init Then
   Call Page1_init
Return
/*:VRX         Page1_Fini
*/
Page1_fini:
window = VRInfo( "Window" )
Call VRDestroy window
Drop window
Return
/*:VRX         Page1_Init
*/
Page1_init:
window = VRInfo( "Object" )
If( \VRIsChildOf( window, "Notebook" ) ) Then
   Do
      Call VRMethod window, "CenterWindow"
      Call VRSet window, "Visible", 1
      Call VRMethod window, "Activate"
   End
Drop window
Return

/*:VRX         Page2_Close
*/
Page2_close:
Call Page1_fini
Return

/*:VRX         Page2_Create
*/
Page2_create:
Parse Arg no_init
p_init = (no_init = '')
startupfolder = VRGetIni( "folders", "startupfolder", our_ini, 'NoClose')
If startupfolder = '' Then
   Do
      startupfolder = VRGet( "EF_Startupfolder", "Value" )
      ini_changes = 1
   End
ok = VRSet( "EF_Startupfolder", "Value", startupfolder )
xwpstartupfolder = Strip(VRGetIni('XWorkplace', 'XStartupFolders', 'User'), 't', '00'x)
xstartupfolder = Strip(VRGetIni( "folders", "XStartupFolders", our_ini, 'NoClose'), 't', '00'x)
Select
   When xwpstartupfolder <> '' Then
      Do
         If WPToolsQueryObject('#' || xwpstartupfolder, , , 'szSetupString') Then
            Do
               Parse Value '.' szsetupstring With . 'OBJECTID=' xstartupname ';' .
               xstartupname = Strip(xstartupname)
            End
      End
   When xstartupfolder <> '' Then
      Do
         If WPToolsQueryObject('#' || xstartupfolder, , , 'szSetupString') Then
            Do
               Parse Value '.' szsetupstring With . 'OBJECTID=' xstartupname ';' .
               xstartupname = Strip(xstartupname)
            End
      End
   Otherwise
      xstartupname = VRGet("EF_XStartupfolder", "Value" )
End
ok = VRSet("EF_XStartupfolder","Value", xstartupname )
enablexstart = VRGetIni( "folders", "enablexstart", our_ini, 'NoClose')
If enablexstart = '' Then
   Do
      enablexstart = 0
      ini_changes = 1
   End
ok = VRSet("CB_EnableXStartupfolder", "Set", enablexstart,"Enabled", xwpstartupfolder <> '' | xstartupfolder <> '' )
retries = VRGetIni( "objects", "retries", our_ini, 'Noclose')
If retries = '' Then
   Do
      retries = 2
      ini_changes = 1
   End
ok = VRSet("SPIN_retries","Value", retries )
sleepsec = VRGetIni( "objects", "sleepsec", our_ini, 'Noclose')
If sleepsec = '' Then
   Do
      sleepsec = VRGet("SPIN_sleepsec","Value")
      ini_changes = 1
   End
ok = VRSet("SPIN_sleepsec","Value", sleepsec )
enablelanstart = VRGetIni( "folders", "enablelanstart", our_ini, 'NoClose')
If enablelanstart = '' Then
   Do
      enablelanstart = VRGet("CB_EnableLANStartupfolder","Set")
      ini_changes = 1
   End
ok = VRSet("CB_EnableLANStartupfolder","Set", enablelanstart )
simplelogononly = VRGetIni( "folders", "simplelogononly", our_ini, 'NoClose')
If simplelogononly = '' Then
   Do
      simplelogononly = VRGet("CB_SimpleLogonOnly","Set")
      ini_changes = 1
   End
If \enablelanstart Then
   Do
      simplelogononly = 0
      ini_changes = 1
   End
ok = VRSet("CB_SimpleLogonOnly","Set", simplelogononly, "Enabled", enablelanstart )
lanstartupfolder = VRGetIni( "folders", "lanstartupfolder", our_ini, 'NoClose')
If lanstartupfolder = '' Then
   Do
      lanstartupfolder = VRGet("EF_LANStartupfolder","Value")
      ini_changes = 1
   End
ok = VRSet("EF_LANStartupfolder","Value", lanstartupfolder,"Enabled", enablelanstart )
ls_sleepsec = VRGetIni( "objects", "ls_sleepsec", our_ini, 'Noclose')
If ls_sleepsec = '' Then
   Do
      ls_sleepsec = VRGet("SPIN_ls_sleepsec","Value")
      ini_changes = 1
   End
ok = VRSet("SPIN_ls_sleepsec","Value", ls_sleepsec,"Enabled", enablelanstart )
ls_retries = VRGetIni( "objects", "ls_retries", our_ini, 'Noclose')
If ls_retries = '' Then
   Do
      ls_retries = VRGet("SPIN_ls_retries","Value")
      ini_changes = 1
   End
ok = VRSet("SPIN_ls_retries","Value", ls_retries,"Enabled", enablelanstart )
If p_init Then
   Call Page2_init
Return
/*:VRX         Page2_Fini
*/
Page2_fini:
window = VRInfo( "Window" )
Call VRDestroy window
Drop window
Return
/*:VRX         Page2_Init
*/
Page2_init:
window = VRInfo( "Object" )
If( \VRIsChildOf( window, "Notebook" ) ) Then
   Do
      Call VRMethod window, "CenterWindow"
      Call VRSet window, "Visible", 1
      Call VRMethod window, "Activate"
   End
Drop window
Return

/*:VRX         Page3_Close
*/
Page3_close:
Call Page3_fini
Return

/*:VRX         Page3_Create
*/
Page3_create:
Parse Arg no_init
p_init = (no_init = '')
log_out = VRGetIni( "debug", "log_out", our_ini, 'Noclose')
If log_out = '' Then
   Do
      log_out = VRGet("CB_log_out","set")
      ini_changes = 1
   End
ok = VRSet("CB_log_out","set", log_out )
verbose = VRGetIni( "debug", "verbose", our_ini, 'NoClose')
If verbose = '' Then
   Do
      verbose = VRGet("CB_verbose","set")
      ini_changes = 1
   End
ok = VRSet("CB_verbose","set", verbose )
sound = VRGetIni( "RexxAutoStart", "Sound", our_ini )
If sound = '' Then
   Do
      sound = VRGet("CB_sound","set")
      ini_changes = 1
   End
ok = VRSet("CB_sound","set", sound )
sound_open = VRGetIni( "sound", "open", our_ini )
If sound_open = '' Then
   Do
      sound_open = "683"
      ini_changes = 1
   End
sound_done = VRGetIni( "sound", "done", our_ini )
If sound_done = '' Then
   Do
      sound_done = "681"
      ini_changes = 1
   End
sound_abort = VRGetIni( "sound", "abort", our_ini )
If sound_abort = '' Then
   Do
      sound_abort = "682"
      ini_changes = 1
   End
sound_start = VRGetIni( "sound", "start", our_ini )
If sound_start = '' Then
   Do
      sound_start = "684"
      ini_changes = 1
   End
If p_init Then
   Call Page3_init
Return

/*:VRX         Page3_Fini
*/
Page3_fini:
window = VRInfo( "Window" )
Call VRDestroy window
Drop window
Return
/*:VRX         Page3_Init
*/
Page3_init:
window = VRInfo( "Object" )
If( \VRIsChildOf( window, "Notebook" ) ) Then
   Do
      Call VRMethod window, "CenterWindow"
      Call VRSet window, "Visible", 1
      Call VRMethod window, "Activate"
   End
Drop window
Return

/*:VRX         Page4_Close
*/
Page4_close:
Call Page4_fini
Return

/*:VRX         Page4_Create
*/
Page4_create:
Parse Arg no_init
p_init = (no_init = '')
Parse Value(_rxfindlines('restartobjects=', config_sys)) ,
   With line_no . '=' next_restart '|' .
current_restart = Translate(Value('restartobjects', , 'os2environment'))
If line_no \= 0 Then
   Do
      ok = VRSet( "DT_RestartObjects", "Caption", next_restart )
      If next_restart = current_restart Then
         ok = VRSet( "DT_RestartObjectsCurrent", "Caption", "" )
      Else
         Do
            If current_restart = '' Then
               ok = VRSet( "DT_RestartObjectsCurrent", "Caption", "not found" )
            Else
               Do
                  ok = VRSet( "DT_RestartObjects", "Caption", next_restart "(next boot)")
                  ok = VRSet( "DT_RestartObjectsCurrent", "Caption", current_restart "(current)" )
               End
         End
   End
Else
   Do
      ok = VRSet( "DT_RestartObjects", "Caption", "not found" )
      If current_restart \= '' Then
         ok = VRSet( "DT_RestartObjectsCurrent", "Caption", current_restart "(current)" )
   End
Parse Value(_rxfindlines('autostart=', config_sys)) ,
   With line_no . '=' next_autostart '|' .
If next_autostart <> new_autostart Then
   next_autostart = new_autostart
current_autostart = Translate(Value('autostart', , 'os2environment'))
If line_no \= 0 Then
   Do
      ok = VRSet( "DT_AutoStart", "Caption", next_autostart )
      If next_autostart = current_autostart Then
         ok = VRSet( "DT_AutoStartCurrent", "Caption", "" )
      Else
         Do
            If current_autostart = '' Then
               ok = VRSet( "DT_AutoStartCurrent", "Caption", "not found" )
            Else
               Do
                  ok = VRSet( "DT_AutoStart", "Caption", next_autostart "(next boot)")
                  ok = VRSet( "DT_AutoStartCurrent", "Caption", current_autostart "(current)" )
               End
         End
   End
Else
   Do
      ok = VRSet( "DT_AutoStart", "Caption", "not found" )
      If current_line \= '' Then
         ok = VRSet( "DT_AutoStartCurrent", "Caption", current_autostart "(current)" )
   End
file_lines. = ''
file_lines.0 = 0
Parse Value(_rxfindlines('rxautost.exe', startup_cmd)) ,
   With rxautost_line_no line '|' .
If rxautost_line_no \= 0 ,
   & Pos(startup_line, line) = 0 Then
   Do
      xrc = _rxupdline(rxautost_line_no, 'REM' line, startup_cmd, 'replace', 'close')
      rxautost_line_no = 0
   End
If rxautost_line_no \= 0 Then
   ok = VRSet( "DT_StartupCmd", "Caption", line )
Else
   ok = VRSet( "DT_StartupCmd", "Caption", "Rexx Autostart not active" )
If VRFileExists(startup_cmd) Then
   Do
      isrexx = Abbrev(Charin(startup_cmd, 1, 2), '/*')
      Call Stream startup_cmd, 'c', 'close'
   End
Else
   isrexx = 0
If VRFileExists( our_log ) Then
   Do
      log_lines = 0
      Do While Lines(our_log)
         junk = Linein(our_log)
         log_lines = log_lines + 1
      End
      ok = VRSet( "DT_LogRecords", "Caption", log_lines "lines" )
   End
Else
   ok = VRSet( "DT_LogRecords", "Caption", "does not exist" )
Parse Value(_rxfindlines('restartobjects=no', config_sys)) ,
   With restart_line_no .
If rxautost_line_no \= 0 & restart_line_no \= 0 Then
   Do
      ok = VRSet( "DT_RexxAutostartStatus", "Caption", "Rexx Autostart enabled" )
      ok = VRSet( "MenuRexxAutostartActivate", "Enabled", 0 )
      ok = VRSet( "MenuRexxAutostartDeactivate", "Enabled", 1 )
   End
Else
   Do
      ok = VRSet( "DT_RexxAutostartStatus", "Caption", "Rexx Autostart disabled" )
      ok = VRSet( "MenuRexxAutostartActivate", "Enabled", 1 )
      ok = VRSet( "MenuRexxAutostartDeactivate", "Enabled", 0 )
   End
If p_init Then
   Call Page4_init
Return

/*:VRX         Page4_Fini
*/
Page4_fini:
window = VRInfo( "Window" )
Call VRDestroy window
Drop window
Return
/*:VRX         Page4_Init
*/
Page4_init:
window = VRInfo( "Object" )
If( \VRIsChildOf( window, "Notebook" ) ) Then
   Do
      Call VRMethod window, "CenterWindow"
      Call VRSet window, "Visible", 1
      Call VRMethod window, "Activate"
   End
Drop window
Return

/*:VRX         ParkingLot
*/
Parkinglot:
Say 'RxAutoSt.EXE in PATH?'
Say 'Envar RxAutoSt set?'
Say 'RESTARTOBJECTS set?'
Say 'AUTOSTART set?'
Say 'RxAutoSt.EXE in STARTUP.CMD?'
/* SET AUTOSTART=PROGRAMS,TASKLIST,FOLDERS
   SET RESTARTOBJECTS=STARTUPFOLDERSONLY
   SET RXAUTOST=/WPS /D:20 /X /E */
Return

/*:VRX         PB_AboutBox_OK_Click
*/
Pb_aboutbox_ok_click:
Call Aboutbox_close
Return

/*:VRX         PB_Cancel_Click
*/
Pb_cancel_click:
Call Quit
Return

/*:VRX         PB_InstallSound_Click
*/
Pb_installsound_click:
/* This routine is loosely based on Mr. XWPS, Ulrich M”ller's sound001.cmd */

/* enable new RexxAutoStart system sound */
mmini = SysBootDrive()||"\MMOS2\MMPM.INI"

/* these are the titles of the sounds to be created */
rexxautostart_done = "RexxAutoStart: Done"
rexxautostart_abort = "RexxAutoStart: Abort"
rexxautostart_open = "RexxAutoStart: Open object"
rexxautostart_start = "RexxAutoStart: Start"

/* Create empty sound entries */
rc = SysIni(mmini, "MMPM2_AlarmSounds", "681", "#"|| rexxautostart_done ||"#70")
rc = SysIni(mmini, "MMPM2_AlarmSounds", "682", "#"|| rexxautostart_abort||"#70")
rc = SysIni(mmini, "MMPM2_AlarmSounds", "683", "#"|| rexxautostart_open ||"#70")
rc = SysIni(mmini, "MMPM2_AlarmSounds", "684", "#"|| rexxautostart_start ||"#70")

/* open WP_SOUND */
ok = SysOpenObject("<WP_SOUND>","DEFAULT",1)
Return

/*:VRX         PB_Set_Click
*/
Pb_set_click:
Call _iniwrite
buttons.1 = "OK"
buttons.0 = 1
id = VRMessage( VRWindow(), "Saving of options to RxAutoSt.INI complete", "Saving RexxAutoStart options", "Information", "Buttons.", 1, 1 )

Return
/*:VRX         PB_SoundConfig_Click
*/
Pb_soundconfig_click:
/* open WP_SOUND */
ok = SysOpenObject("<WP_SOUND>","DEFAULT",1)
Return

/*:VRX         PB_Undo_Click
*/
Pb_undo_click:
Call Page1_create 'no_init'
Call Page2_create 'no_init'
Call Page3_create 'no_init'
Call Page4_create 'no_init'
Return
/*:VRX         PB_UnInstallSound_Click
*/
Pb_uninstallsound_click:
mmini = SysBootDrive()||"\MMOS2\MMPM.INI"
Do i = 681 To 684
   rc = SysIni(mmini, "MMPM2_AlarmSounds", i, "DELETE:")
End

/* open WP_SOUND */
ok = SysOpenObject("<WP_SOUND>","DEFAULT",1)
Return

/*:VRX         Quit
*/
Quit:
If ini_changes Then
   Do
      buttons.1 = "Yes"
      buttons.2 = "Discard"
      buttons.3 = "Cancel"
      buttons.0 = 3
      id = VRMessage( VRWindow(), "Save changes made before exiting RexxAutoStart Setup Utility?", "Save RexxAutoStart Options", "Query", "Buttons.", 1, 3 )
      If id = 1 Then
         Call _iniwrite
      If id = 3 Then
         Return
   End
window = VRWindow()
Call VRSet window, "Shutdown", 1
Drop window
Return

/*:VRX         RB_sc_open_Click
*/
RB_sc_open_Click: 
sc_wait = VRGet("RB_sc_wait", "Set")
sc_open = VRGet("RB_sc_open","Set")
Call Update_autostart 'warpcenter', sc_wait, sc_open
ini_changes = 1
return

/*:VRX         RB_sc_wait_Click
*/
RB_sc_wait_Click: 
sc_wait = VRGet("RB_sc_wait", "Set")
sc_open = VRGet("RB_sc_open","Set")
Call Update_autostart 'warpcenter', sc_wait, sc_open
ini_changes = 1
return

/*:VRX         RB_tb_open_Click
*/
RB_tb_open_Click: 
tb_wait = VRGet("RB_tb_wait", "Set")
tb_open = VRGet("RB_tb_open","Set")
Call Update_autostart 'toolbar', tb_wait, tb_open
ini_changes = 1
return

/*:VRX         RB_tb_wait_Click
*/
RB_tb_wait_Click: 
tb_wait = VRGet("RB_tb_wait", "Set")
tb_open = VRGet("RB_tb_open","Set")
Call Update_autostart 'toolbar', tb_wait, tb_open
ini_changes = 1
return

/*:VRX         RB_xc_open_Click
*/
RB_xc_open_Click: 
xc_wait = VRGet("RB_xc_wait", "Set")
xc_open = VRGet("RB_xc_open","Set")
ini_changes = 1
return

/*:VRX         RB_xc_wait_Click
*/
RB_xc_wait_Click: 
xc_wait = VRGet("RB_xc_wait","Set")
xc_open = VRGet("RB_xc_open","Set")
ini_changes = 1
return

/*:VRX         RxAutoUtMain_Close
*/
Rxautoutmain_close:
Call Quit
Return

/*:VRX         RxAutoUtMain_Create
*/
Rxautoutmain_create:
Return

/*:VRX         SPIN_delay_wait_Change
*/
Spin_delay_wait_change:
delay_wait = VRGet("SPIN_delay_wait","Value")
Return

/*:VRX         SPIN_ls_retries_Change
*/
Spin_ls_retries_change:
ls_retries = VRGet("SPIN_ls_retries","Value")
ini_changes = 1
Return

/*:VRX         SPIN_ls_sleepsec_Change
*/
Spin_ls_sleepsec_change:
ls_sleepsec = VRGet("SPIN_ls_sleepsec","Value")
ini_changes = 1
Return

/*:VRX         SPIN_od_tries_Change
*/
Spin_od_tries_change:
ini_changes = (od_tries <> VRGet("SPIN_od_tries","Value"))
od_tries = VRGet("SPIN_od_tries","Value")
Return

/*:VRX         SPIN_retries_Change
*/
Spin_retries_change:
retries = VRGet("SPIN_retries","Value")
ini_changes = 1
Return

/*:VRX         SPIN_sleepsec_Change
*/
Spin_sleepsec_change:
sleepsec = VRGet("SPIN_sleepsec","Value")
ini_changes = 1
Return

/*:VRX         Update_autostart
*/
Update_autostart:
Parse Upper Arg autostart_parm, autostart_wait, autostart_open, .
/* opened by rexxautostart, remove from new_autostart */
If autostart_open Then
   Do 
      If Pos(autostart_parm, new_autostart) <> 0 Then
         Do
            Parse Var new_autostart temp_1 (autostart_parm) temp_2 .
            new_autostart = Strip(temp_1||temp_2, 't', ',')
            double_comma = Pos(',,', new_autostart)
            If double_comma <> 0 Then
               new_autostart = Substr(new_autostart, 1, double_comma)||Substr(new_autostart, double_comma + 2)
         End
   End
/* not opened by rexxautostart, put back in new_autostart if being waited on */
Else
   Do
      If autostart_wait ,
         & Pos(autostart_parm, new_autostart) = 0 Then
         new_autostart = new_autostart||','autostart_parm
   End
If new_autostart <> next_autostart Then
   Do
      next_autostart = new_autostart
      ok = VRSet( "DT_AutoStart", "Caption", next_autostart "(next boot)")
   End
return

