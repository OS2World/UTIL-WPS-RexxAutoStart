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

/*:VRX         _autoexec
*/
_autoexec:
/* launch startup folder objects */
Say '_Autoexec entered'

/* query our startup folder */
If WPToolsFolderContent(startupfolder, 'list.', 'F') Then
   Do
      Call _sayout sleepsec "seconds of delay between objects will be inserted.", 2
      If enablexstart Then
         Do
            xstart_num = list.0 + 1
            If WPToolsFolderContent(xstartupname, 'x_list.', 'F') Then
               Do
                  Do x = 1 To x_list.0
                     y = list.0 + 1
                     list.y = x_list.x
                     list.0 = y
                  End
                  If WPToolsQueryObject('#' || xstartupfolder, , , 'szSetupString') Then
                     Do
                        Parse Value '.' szsetupstring With . 'OBJECTID=' xstartupname ';' .
                        xstartupname = Strip(xstartupname)
                     End
               End
         End

      /* open objects in startup folders */
      open_parm = 'OPEN=DEFAULT;CCVIEW=NO;'
      list_total = list.0
      list_open = 0
      list_start = 1
      list_end = list.0
      list_incr = 1
      If wseb Then
         Do
            list_start = list.0
            list_end = 1
            list_incr = -1
         End
      Call _sayout "Starting objects in startup folder" startupfolder".", 1
      Do i = 1 To list.0
         Call Checkforevent
         If i = xstart_num Then
            Call _sayout "Starting objects in startup folder" xstartupname".", 1
         If list.i = '<WP_WARPCENTER>' & xc_wait Then
            Iterate i
         If list.i = '<XWP_XCENTER>' & xc_wait Then
            Iterate i
         If WPToolsQueryObject(list.i, 'szclass', 'sztitle') Then
            Do
               title = _objtitle(sztitle)
               success = 0
               Do x = 1 To retries Until success
                  Call _sleepanimated sleepsec
                  success = WPToolsSetObjectData(list.i, open_parm)
                  Say 'WPToolsSetObjectData('list.i',' open_parm')'
               End
               If success Then
                  open_msg = title 'has opened after' x 'attempt(s) of' retries || '.'
               Else
                  open_msg = title 'failed to open after' retries 'attempts.'
               list_open = list_open + 1
               ok = VRSet("SL_Progress","Percentile",Trunc(list_open * 100 / list_total))
               Call _playsoundevent(sound_open)
               Call _sayout open_msg, 3
            End
         Else
            Call _sayout 'Could not locate object' list.i || '.', 2
         Call _playpicture
      End
      If list_total = 0 Then
         Call _sayout 'No objects found in startup folder(s).', 2
   End
Else
   Do
      Call _sayout 'Failure:' startupfolder 'could not be queried. Continuing...', 1
   End
Say '_Autoexec done'
Return 0
/*:VRX         _cleanup
*/
_cleanup:
Parse Arg one
Say '_CleanUp 'one
Call _iniwrite
/* call beep 880, 20 */
Return 0

/*:VRX         _delayswitch
*/
_delayswitch:
/* /D (delay) switch logic */
Say '_delayswitch'
Call _sayout 'Delay further execution by' delay_wait 'seconds.', 1
Call _sleepanimated delay_wait
Call _sayout delay_wait' seconds have passed. Continuing...', 2
Return 0
/*:VRX         _doneobj
*/
_doneobj:
Procedure Expose verbose log_out log_file sub_trace sound sleepsec
/* wait for object to complete */
save_trace = Trace(sub_trace)
Parse Arg title, sleep, od_tries
rc_task = 1
attempts = 0
If \Rxfuncquery('SysQuerySwitchList') Then
   Do i = 1 To od_tries While rc_task
      attempts = attempts + 1
      Call SysQuerySwitchList 'tasks.', 'IGN'
      Do j = 1 To tasks.0 Until rc_task
         rc_task = (Pos(title, tasks.j) <> 0)
      End
      If rc_task Then
         Do
            Call _sleepanimated sleep
            Call Checkforevent
         End
   End
Else
   Call _sayout 'SysQuerySwitchList not available, returning...', 2
Trace (save_trace)
Return rc_task attempts

/*:VRX         _GetEventSound
*/
_geteventsound:
Parse Arg eventcode
soundfileentry = VRGetIni( "MMPM2_AlarmSounds", eventcode, SysBootDrive()"\MMOS2\MMPM.INI" )
Say 'SoundFileEntry  = !!!'soundfileentry'!!!'
If soundfileentry \= '' Then
   Do                                                /* Sound defined */
      Parse Var soundfileentry soundfile '#' .
   End
Else
   soundfile = ''
Say "SoundFile = >>"soundfile"<<"
Return soundfile
/*:VRX         _GetObjectTitle
*/
_getobjecttitle: Procedure Expose autostrt verbose log_out log_file
Say 'GetObjTitle entered'
Parse Upper Arg object_id
xrc = WPToolsQueryObject(object_id, 'szclass', 'sztitle')
If xrc Then
   object_title = _objtitle(sztitle)
Else
   object_title = ''
Say 'GetObjTitle done'
Return object_title

/*:VRX         _helpscreen
*/
_helpscreen:

lines.1 = 'RexxAutoStart Version 'ver' ('verdate') (c) 1998-2000 by Herwig Bauernfeind and Chuck McKinnis'
lines.2 = 'This is FREE software under the terms of the GNU General Public License.'
lines.3 = ' '
lines.4 = 'Using 'rxname' Version 'rxver' ('rxdate')'
lines.5 = 'Using WPTools Version 'wptver' (c) copyright by Henk Kelder'
lines.6 = 'Using VX-REXX Version 'VRVersion('VROBJ.DLL')
lines.7 = ' '
lines.8 = '/WPS'Copies(' ',20)'Delay execution until desktop is populated.'
lines.9 = '/D:n'Copies(' ',24)'Delay execution of this program by n seconds.'
lines.10= '/OD[:n]'Copies(' ',18)'Delay execution until Object Desktop is opened or a maximum of n tries'
lines.11= Copies(' ',32)'(default = 30) delayed by /P:n seconds (default = 2). (by Chuck McKinnis)'
lines.12= '/ODC'Copies(' ',22)'Delay execution until Object Desktop Control Center is opened or a maximum of n tries'
lines.13= '/ODT'Copies(' ',22)'Delay execution until Object Desktop Tab Launchpad is opened or a maximum of n tries'
lines.14= '/P:n'Copies(' ',24)'Pause between objects should be n seconds. Default = 2.'
lines.15= '/R:n'Copies(' ',24)'Number of attempts to open an object. Default = 2.'
lines.16= '/F:"<FolderID>"  Folder which should be treated as startup folder.'
lines.17= '/V'Copies(' ',28)'Verbose. Give us some hints what we are doing right now.'
lines.18= '/L'Copies(' ',28)'Log results to' log_file || '.'
lines.19= ' '
lines.0 = 19
buttons.1 = "OK"
buttons.0 = 1
id = VRMessageStem( VRWindow(), "Lines.", "Usage help", "Information", "Buttons.", 1, 1 )



Return 0

/*:VRX         _iniread
*/
_iniread:
/* position */
main_left = VRGetIni( "RexxAutoStart", "Left", our_ini , 'NoClose')
main_top = VRGetIni( "RexxAutoStart", "Top", our_ini , 'NoClose')
ok = VRSet("RexxAutoStartMain", "Left", main_left)
ok = VRSet("RexxAutoStartMain", "Top", main_top)

/* color */
backcolor = VRGetIni( "RexxAutoStart", "BackColor", our_ini )
If backcolor = '' Then
   backcolor = VRGet("RexxAutoStartMain","BackColor")
Else
   ok = VRSet("RexxAutoStartMain","BackColor",backcolor)
ok = VRSet("RexxAutoStartMain","BackColor",backcolor)

/* some parameter defaults */
wps_wait = VRGetIni( "workplace_shell", "wps_wait", our_ini, 'Noclose')
If \Datatype(wps_wait, 'B') Then
   wps_wait = 1
sc_test = Check_startup('WARPCENTER', '<WP_WARPCENTER>', , '<WP_START>')
sc_wait = VRGetIni( "workplace_shell", "sc_wait", our_ini, 'Noclose')
If \Datatype(sc_wait, 'B') Then
   sc_wait = sc_test
sc_wait = (sc_wait & sc_test)
sc_test = Check_startup(, '<WP_WARPCENTER>', , '<WP_START>')
sc_open = VRGetIni( "workplace_shell", "sc_open", our_ini, 'Noclose')
If \Datatype(sc_open, 'B') Then
   sc_open = sc_test
sc_open = (sc_open & sc_test)
tb_test = Check_startup('TOOLBAR', '<WP_LAUNCHPAD>', , '<WP_START>')
tb_wait = VRGetIni( "workplace_shell", "tb_wait", our_ini, 'Noclose')
If \Datatype(tb_wait, 'B') Then
   tb_wait = tb_test
tb_wait = (tb_wait & tb_test)
tb_test = Check_startup(, '<WP_LAUNCHPAD>', , '<WP_START>')
tb_open = VRGetIni( "workplace_shell", "tb_open", our_ini, 'Noclose')
If \Datatype(tb_open, 'B') Then
   tb_open = tb_test
tb_open = (tb_open & tb_test)
xc_test = Check_startup(,'<XWP_XCENTER>', 'XCenter', '<WP_START>')
ec_wait = VRGetIni( "workplace_shell", "ec_wait", our_ini, 'Noclose')
If ec_wait <> '' Then
   Do
      ok = VRDelIni( "workplace_shell", "ec_wait", our_ini, 'Noclose') Then
      xc_wait = (ec_wait & xc_test)
      ok = VRSetIni( "workplace_shell", "xc_wait", xc_wait, our_ini, 'Noclose' )
   End
xc_wait = VRGetIni( "workplace_shell", "xc_wait", our_ini, 'Noclose')
If \Datatype(xc_wait, 'B') Then
   xc_wait = xc_test
xc_wait = (xc_wait & xc_test)
xc_open = VRGetIni( "workplace_shell", "xc_open", our_ini, 'Noclose')
If \Datatype(xc_open, 'B') Then
   xc_open = xc_test
xc_open = (xc_open & xc_test)
startup_wait = VRGetIni( "workplace_shell", "startup_wait", our_ini, 'Noclose')
If startup_wait <> 0 & startup_wait <> 1 Then
   startup_wait = 0
delay_wait = VRGetIni( "workplace_shell", "delay_wait", our_ini, 'Noclose')
If \Datatype(delay_wait, 'B') Then
   delay_wait = 1
od_wait = VRGetIni( "object_desktop", "od_wait", our_ini, 'Noclose')
If \Datatype(od_wait, 'B') Then
   od_wait = 0
od_cc = VRGetIni( "object_desktop", "od_cc", our_ini, 'Noclose')
If \Datatype(od_cc, 'B') Then
   od_cc = 0
od_tlp = VRGetIni( "object_desktop", "od_tlp", our_ini, 'Noclose')
If \Datatype(od_tlp, 'B') Then
   od_tlp = 0
od_tries = VRGetIni( "object_desktop", "od_tries", our_ini, 'Noclose')
If \Datatype(od_tries, 'N') Then
   od_tries = 30

startupfolder = VRGetIni( "folders", "startupfolder", our_ini, 'Noclose')
If startupfolder = '' Then
   startupfolder = '<WP_START>'
xstartupfolder = Strip(VRGetIni( "folders", "XStartupFolders", our_ini, 'NoClose'), 't', '00'x)
If xstartupfolder <> '' Then
   Do
      If WPToolsQueryObject('#' || xstartupfolder, , , 'szSetupString') Then
         Do
            Parse Value '.' szsetupstring With . 'OBJECTID=' szobjectid ';' .
            xstartupname = Strip(szobjectid)
         End
      Else
         xstartupname = '<XWP_STARTUP>'
   End
Else
   xstartupname = '<XWP_STARTUP>'
enablexstart = VRGetIni( "folders", "enablexstart", our_ini, 'NoClose')
If \Datatype(enablexstart, 'B') Then
   enablexstart = 0
retries = VRGetIni( "objects", "retries", our_ini, 'Noclose')
If \Datatype(retries, 'W') Then
   retries = 2
sleepsec = VRGetIni( "objects", "sleepsec", our_ini, 'Noclose')
If \Datatype(sleepsec, 'N') Then
   sleepsec = 2
enablelanstart = VRGetIni( "folders", "enablelanstart", our_ini, 'NoClose')
If \Datatype(enablelanstart, 'B') Then
   enablelanstart = 0
simplelogononly = VRGetIni( "folders", "simplelogononly", our_ini, 'NoClose')
If \Datatype(simplelogononly, 'B') Then
   simplelogononly = 0
If \enablelanstart Then
   simplelogononly = 0
lanstartupfolder = VRGetIni( "folders", "lanstartupfolder", our_ini, 'NoClose')
If lanstartupfolder = '' Then
   lanstartupfolder = '<RexxAutoStart_LAN_Folder>'
ls_sleepsec = VRGetIni( "objects", "ls_sleepsec", our_ini, 'Noclose')
If \Datatype(ls_sleepsec, 'N') Then
   ls_sleepsec = 3
ls_retries = VRGetIni( "objects", "ls_retries", our_ini, 'Noclose')
If \Datatype(ls_retries, 'W') Then
   ls_retries = 60

log_out = VRGetIni( "debug", "log_out", our_ini, 'Noclose')
If \Datatype(log_out, 'B') Then
   log_out = 1
verbose = VRGetIni( "debug", "verbose", our_ini, 'Noclose' )
If \Datatype(verbose, 'B') Then
   verbose = 1
/* Sound */
sound = VRGetIni( "RexxAutoStart", "Sound", our_ini,'NoClose' )
If \Datatype(sound, 'B') Then
   sound = VRGet("CB_Sound","set")
ok = VRSet("CB_Sound","set",sound)
sound_open = VRGetIni( "sound", "sound_open", our_ini,'NoClose' )
If \Datatype(sound_open, 'W') Then
   sound_open = '683'
sound_done = VRGetIni( "sound", "sound_done", our_ini,'NoClose' )
If \Datatype(sound_done, 'W') Then
   sound_done = '681'
sound_abort = VRGetIni( "sound", "sound_abort", our_ini,'NoClose' )
If \Datatype(sound_abort, 'W') Then
   sound_abort = '682'
sound_start = VRGetIni( "sound", "sound_start", our_ini )
If \Datatype(sound_start, 'W') Then
   sound_start = '684'

Return
/*:VRX         _Initialize
*/
_initialize:                                  /* Initialize libraries */
/* determine REXX level we are running on */
Parse Version rxname rxver rxdate

/* check operating system */
If Rxfuncquery(sysversion) = 0 Then
   Do
      Parse Value SysVersion() With op_sys op_lvl
   End
Else
   Do                                  /* older OS/2, probably Warp 3 */
      op_lvl = SysOS2Ver()
      op_sys = 'OS/2'
   End
sys_os2 = SysSearchPath('path', 'syslevel.os2')
os_base = Charin(sys_os2, 53, 7)
os_level = Charin(sys_os2, 45, 7)
os_comp = Charin(sys_os2, 141, 9)
os_name = Strip(Charin(sys_os2, 61, 80), 't', '00'x)
Call Stream sys_os2, 'c', 'close'

warp4 = (op_lvl >= 2.40)
ecs = (os_comp = '5639A6101')
wseb_uni = (os_comp = '5639A6150')
wseb_smp = (os_comp = '5639A5550')
wseb = (wseb_uni | wseb_smp) & (os_base <> 'XR04501')

/* locate the executable */
exe_file = Stream(startup_path || '\rxautost.exe', 'c', 'query exists')
If exe_file = '' Then
   Do
      exe_file = SysSearchPath('PATH', 'rxautost.exe')
      If exe_file = '' Then
         Do
            msg.title = 'Error'
            msg.type = 'E'
            msg.text = 'Unable to locate rxautost.exe'
            Call _msgok
            Call Pb_quitnow_click
         End
   End

/* locate the base directory for RxAutoSt, logfile and INIfile */
base_dir = VRParseFileName( exe_file, "DP" )
our_ini = base_dir || '\RxAutoSt.INI'
log_file = base_dir || '\RxAutoSt.LOG'

/* Read the INI file */
Call _iniread

/*  update GUI */
ok = VRSet("SPIN_SleepSec","Value",sleepsec)

/* et voila */
ok = VRSet("RexxAutoStartMain", "Visible", 1)
Call _playsoundevent sound_start

/* start new log file if logging */
If log_out & VRFileExists( log_file ) Then
   ok = VRDeleteFile( log_file )

/* Call Stream log_file, 'c', 'open write' */

/* load other function libraries */
Call _loadotherfuncs

/* are we going to execute RxAutoSt? */
autoexec = 1                               /* (Pos('/X', parms) <> 0) */
Return 1
/*:VRX         _INIWrite
*/
_iniwrite:
If our_ini = 'OUR_INI' Then
   our_ini = base_dir || '\RxAutoSt.INI'
ok = VRSet("RexxAutoStartMain","StatusText","Saving...")
ok = VRSetIni( "objects", "sleepsec", sleepsec, our_ini, 'Noclose')
ok = VRSetIni( "RexxAutoStart", "Left", VRGet("RexxAutoStartMain","Left"), our_ini, 'NoClose' )
ok = VRSetIni( "RexxAutoStart", "Top", VRGet("RexxAutoStartMain","Top"), our_ini, 'NoClose' )
ok = VRSetIni( "RexxAutoStart", "BackColor", VRGet("RexxAutoStartMain","BackColor"), our_ini, 'NoClose' )
ok = VRSetIni( "RexxAutoStart", "Sound", sound, our_ini)
Return


/*:VRX         _LanOpenStartupFolder
*/
_lanopenstartupfolder:
startupfolder = lanstartupfolder
xrc = _autoexec()
Return xrc
/*:VRX         _LanWaitForConnection
*/
_lanwaitforconnection:
/* LAN connection wait logic */
requester_started = 0
no_requester = 2138
server_started = 0
no_server = 2114
no_domain = 2453
Call _sayout 'Waiting for network startup.', 1
ok = VRSet("SL_Progress","Percentile", 0)
/* wait for the requester to start */
ls_tries = 0
Do ls_retries While \requester_started
   ls_tries = ls_tries + 1
   Parse Value LsMyInfo() With lanrc my_uid admin? my_machine my_domain my_domain_controller .
   If lanrc = no_requester Then
      Do
         Call _sayout 'Waiting for network REQUESTER to start (' || ls_tries || ').', 2
         Call SysSleep ls_sleepsec
         Call Checkforevent
      End
   If lanrc = 0 | lanrc = 2453 Then
      Do
         Call _sayout 'Network REQUESTER has started.', 2
         requester_started = 1
      End
End
If \requester_started Then
   Do
      Call _sayout 'Wait for network REQUESTER startup timed out.', 2
      Return 0
   End

/* wait for server (peer) to start */
ls_tries = 0
If requester_started Then
   Do ls_retries While \server_started
      ls_tries = ls_tries + 1
      srvrc = NetAdmin('test.', my_machine, 'net start')
      If srvrc = no_server Then
         Do
            Call _sayout 'Waiting for network SERVER (PEER) to start (' || ls_tries || ').', 2
            Call SysSleep ls_sleepsec
            Call Checkforevent
         End
      If srvrc = 0 Then
         Do
            Call _sayout 'Network SERVER (PEER) has started.', 2
            my_services = Space(test.2)
            server_started = 1
         End
   End
If \server_started Then
   Do
      Call _sayout 'Wait for network SERVER (PEER) startup timed out.', 2
      enablelanstart = 0
   End
If \enablelanstart Then
   Return 0

If my_domain = '?' Then
   Parse Value LsDomName() With . my_domain .

/* wait for logon */
If (requester_started | server_started) ,
   & simplelogononly Then
   Do
      ls_logged = 0
      ls_tries = 0
      Call _sayout 'Waiting for network logon.', 1
      Parse Value LsMyInfo() With lanrc my_uid admin? my_machine my_domain my_domain_controller .
      If lanrc = 0 | lanrc = no_domain Then
         Do ls_retries While \ls_logged
            Select
               When my_uid <> '?' & my_domain_controller <> '?' Then
                  Do
                     Call _sayout my_uid 'is logged on to domain controller' my_domain_controller || '.', 2
                     ls_logged = 1
                  End
               When my_uid <> '?' & my_domain_controller = '?' Then
                  Do
                     Call _sayout my_uid 'is logged on to local server' my_machine || '.', 2
                     ls_logged = 1
                  End
               Otherwise
                  Do
                     Call _sayout 'Waiting for logon (' || ls_tries || ').', 2
                     Call SysSleep ls_sleepsec
                     Call Checkforevent
                     ls_tries = ls_tries + 1
                     Parse Value LsMyInfo() With lanrc my_uid admin? my_machine my_domain my_domain_controller .
                     If lanrc = 0 | lanrc = no_domain Then
                        Iterate
                     Else
                        Do
                           Call _sayout 'The logon status query failed with a return code of' lanrc || '.', 2
                           Return 0
                        End
                  End
            End
         End
      Else
         Do
            Call _sayout 'The logon status query failed with a return code of' lanrc || '.', 2
            Return 0
         End
      If \ls_logged Then
         Do
            Call _sayout 'Wait for network logon timed out.', 2
            Return 0
         End
   End
Return 1
/*:VRX         _LoadOtherFuncs
*/
_loadotherfuncs:
wptver = WPToolsVersion()
If enablelanstart Then
   Do
      Call Rxfuncadd 'LsLoadFuncs', 'NETUTIL', 'LsLoadFuncs'
      Call LsLoadFuncs
   End
Return

/*:VRX         _MsgOK
*/
_msgok:
buttons.1 = "OK"
buttons.0 = 1
If msg.title = 'MSG.TITLE' Then
   msg.title = 'BinSuk/PM ('group') message'
id = VRMessage( VRWindow(), msg.text, msg.title, msg.type, "Buttons.", buttons.1, buttons.1 )
Return

/*:VRX         _objdone
*/
_objdone:
Parse Arg wait_title
Call _sayout 'Waiting for' wait_title 'to complete.', 1
Call Checkforevent
success = 0
Parse Value(_doneobj(wait_title, sleepsec, od_tries)) With success tries .
If \success Then
   open_msg = wait_title 'has completed after' tries 'check(s).'
Else
   open_msg = wait_title 'has not completed after' tries 'check(s).'
Call _sayout open_msg, 2
Return 0
/*:VRX         _objTitle
*/
_objtitle: Procedure Expose autostrt verbose log_out log_file
/* translate out carriage control characters */
Say 'ObjTitle entered'
Parse Arg title
nlcrlf = D2c(94) || D2c(13) || D2c(10)
title = Space(Translate(title, , nlcrlf))
Say 'ObjTitle done'
Return title
/*:VRX         _objwait
*/
_objwait:
Parse Arg wait_title
Call _sayout 'Waiting for' wait_title 'to start.', 1
Call Checkforevent
success = 0
Parse Value(_waitobj(wait_title, sleepsec, od_tries)) With success tries .
If success Then
   open_msg = wait_title 'has opened after' tries 'check(s).'
Else
   open_msg = wait_title 'has not opened after' tries 'check(s).'
Call _sayout open_msg, 2
Return 0

/*:VRX         _odwait
*/
_odwait:
Say '_odwait entered'
Call _sayout 'Waiting for Object Desktop to start.', 1
success = 0
If od_cc Then
   Do
      Call _sayout 'Waiting for [Control Center].', 2
      Parse Value(_waitobj('Control Center', sleepsec, od_tries)) With success tries .
      If success Then
         open_msg = '[Control Center] has opened after' tries 'check(s).'
      Else
         open_msg = '[Control Center] has not opened after' tries 'check(s).'
      Call _sayout open_msg, 3
   End
Else
   Call _sayout '[Control Center] has not been selected for activation.', 2
If od_tlp Then
   Do
      Call _sayout 'Waiting for [Tab LaunchPad].', 2
      Parse Value(_waitobj('Tab LaunchPad', sleepsec, od_tries)) With success tries .
      If success Then
         open_msg = '[Tab LaunchPad] has opened after' tries 'check(s).'
      Else
         open_msg = '[Tab LaunchPad] has not opened after' tries 'check(s).'
      Call _sayout open_msg, 3
   End
Else
   Call _sayout '[Tab LaunchPad] has not been selected for activation.', 2
If success Then
   open_msg = 'Object Desktop is started. Continuing...'
Else
   open_msg = 'Object Desktop has not started. Continuing...'
Call _sayout open_msg, 2
Say '_odwait done'
Return 0

/*:VRX         _PlayPicture
*/
_playpicture:
pictures = '#1:RXASTRES.DLL #2:RXASTRES.DLL #3:RXASTRES.DLL #4:RXASTRES.DLL #5:RXASTRES.DLL #6:RXASTRES.DLL #7:RXASTRES.DLL'
picturepath = VRGet( "PlayPic", "PicturePath" )
currentpicturepath = Wordpos(picturepath, pictures)
If currentpicturepath = 0 | currentpicturepath = Words(pictures) Then
   nextpicturepath = Word(pictures, 1)
Else
   nextpicturepath = Word(pictures, currentpicturepath + 1)
ok = VRSet( "PlayPic", "PicturePath", nextpicturepath )
Return

/*:VRX         _PlaySound
*/
_playsound:
Signal On Halt
Parse Arg soundfile
ok = VRRedirectStdIO("OFF")
Say soundfile
/* Load the DLL, initialize MCI REXX support */
Call Rxfuncadd 'mciRxInit', 'MCIAPI', 'mciRxInit'
Call mciRxInit
/* Open the sound file */
audiorc = mciRxSendString('open "'soundfile'" alias eventsound shareable wait', 'retstr', '0', '0')
Say 'open  AudioRC = 'audiorc
If audiorc = 0 Then
   Do
      /* no error encountered */
      audiorc = mciRxSendString('play eventsound wait', 'retstr', '0', '0')
      Say 'play  AudioRC = 'audiorc
      If audiorc = 0 Then
         Do
            audiorc = mciRxSendString('close eventsound wait', 'retstr', '0', '0')
            Say 'close AudioRC = 'audiorc
         End
      Else
         Call mciRxSendString 'close eventsound wait', 'retst', '0', '0'
   End
Call mciRxExit
Return

/*:VRX         _PlaySoundEvent
*/
_playsoundevent:
Parse Arg soundeventcode
Say '_PlaySoundEvent entered'
Say sound
Say soundeventcode
If sound Then
   Do
      soundfileentry = VRGetIni( "MMPM2_AlarmSounds", soundeventcode, Getbootdrive()"\MMOS2\MMPM.INI" )
      Say 'SoundFileEntry  = !!!'soundfileentry'!!!'
      If soundfileentry \= '' Then
         Do                                          /* Sound defined */
            Parse Var soundfileentry soundfile '#' .
         End
      Else
         soundfile = ''
      Say "SoundFile = >>"soundfile"<<"
      If VRFileExists( soundfile ) Then
         Call _playsound soundfile
      Else
         Say soundfile 'not found'
      Drop soundeventcode soundfile
   End
Else
   Say 'No Sound!'
Say '_PlaySoundEvent done'
Return 0
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
/*:VRX         _sayout
*/
_sayout: Procedure Expose verbose log_out log_file
/* console and log file output procedure */
save_trace = Trace('N')
Parse Arg msg, level
If \Datatype(level, 'W') Then
   level = 0
msg = Copies(' ', level) || msg
If verbose Then
   ok = VRSet("RexxAutostartMain" ,"StatusText", Strip(msg))
If log_out Then
   Call Lineout log_file, Date() Time() msg
Trace (save_trace)
Return level
/*:VRX         _SleepAnimated
*/
_sleepanimated:
Parse Arg seconds
Call Checkforevent
If seconds < 2 Then
   Call SysSleep seconds
Else
   Do jj = 1 To seconds
      If jj = 1 Then
         ok = VRSet("RexxAutoStartMain","WindowIcon","$2")     /* red */
      If jj = seconds - 1 & seconds > 2 Then
         ok = VRSet("RexxAutoStartMain","WindowIcon","$3")  /* yellow */
      If jj = seconds Then
         ok = VRSet("RexxAutoStartMain","WindowIcon","$1")   /* green */
      Call SysSleep 1
      Call Checkforevent
   End
Return

/*:VRX         _WaitObj
*/
_waitobj: Procedure Expose verbose log_out log_file sub_trace sound sleepsec
/* wait for object to start */
save_trace = Trace(sub_trace)
Parse Arg title, sleep, od_tries
rc_task = 0
attempts = 0
If \Rxfuncquery('SysQuerySwitchList') Then
   Do i = 1 To od_tries Until rc_task
      attempts = attempts + 1
      Call SysQuerySwitchList 'tasks.', 'IGN'
      Do j = 1 To tasks.0 Until rc_task
         rc_task = (Pos(title, tasks.j) <> 0)
      End
      If \rc_task Then
         Do
            Call _sleepanimated sleep
            Call Checkforevent
         End
   End
Else
   Call _sayout 'SysQuerySwitchList not available, returning...', 2
Trace (save_trace)
Return rc_task attempts

/*:VRX         _wpswait
*/
_wpswait:
Say '_WPSWait entered'
Call _sayout 'Waiting until the Desktop has been populated.', 1
Call Checkforevent
If warp4 Then
   Do                                               /* Warp 4 or WSeB */
      If (SysWaitForShell("DESKTOPPOPULATED", "QUERY") = 0) Then
         Do
            Call SysWaitForShell "DESKTOPPOPULATED"
         End
   End
Else
   Do              /* Warp 3, taken from RXTT28.INF by Bernd Schemmer */
      xrc = SysIni('USER', 'PM_InstallObject', 'ALL:', 'stem')
      Do While xrc \= 'ERROR:'
         Call _sleepanimated sleepsec
         xrc = SysIni('USER', 'PM_InstallObject', 'ALL:', 'stem')
      End
   End
Call _sayout 'Desktop has been populated. Continuing...', 2
Say '_WPSWait done'
Return 0

/*:VRX         CB_Sound_Click
*/
Cb_sound_click:
sound = VRGet("CB_Sound","set")
Return

/*:VRX         Check_startup
*/
Check_startup: 
Procedure
Parse Arg auto, obj, class, startup, .
If auto <> '' Then
   test_auto = (Pos(Translate(auto), Translate(Value('AUTOSTART', , 'OS2ENVIRONMENT'))) = 1)
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
/*:VRX         CheckForEvent
*/
Checkforevent:
/* check event queue */
eventstring = ''
Do Until eventstring = 'nop'
   eventstring = VREvent('N')
   If eventstring <> 'nop' Then
      Do
         Interpret eventstring
      End
End
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
Call Rxfuncadd 'SysLoadFuncs','RexxUtil','SysLoadFuncs'
Call SysLoadFuncs

bootdrive = Getbootdrive()
startup_cmd = InitArgs.1
startup_drive = VRParseFileName(startup_cmd, "D")
startup_path = VRParseFileName(startup_cmd, "DP")
ok = VRChDrive( startup_drive )
ok = VRChDir( startup_path )

Call Rxfuncadd 'WPToolsLoadFuncs', 'WPTOOLS', 'WPToolsLoadFuncs'
Call WPToolsLoadFuncs

window = VRWindow()
ok = VRRedirectStdIO('OFF')
Call VRMethod window, "Activate"
Drop window
Return
/*:VRX         MenuSettings_Click
*/
Menusettings_click:

Return

/*:VRX         PB_QuitNow_Click
*/
Pb_quitnow_click:
Say 'PB_QuitNow_Click entered/done'
ok = _playsoundevent(sound_abort)
Call _iniwrite
ok = _sayout('Aborting...')
Call SysSleep sleepsec
Call Quit
Return

/*:VRX         PB_Shell_Click
*/
Pb_shell_click:
ok = VRSet("RexxAutoStartMain","StatusText","Open a shell and halt RexxAutoStart temporarily")
shell = '"'Value('OS2_SHELL',,'OS2ENVIRONMENT')'"'
Interpret shell
Return

/*:VRX         Quit
*/
Quit:
Call _cleanup
window = VRWindow()
Call VRSet window, "Shutdown", 1
Drop window
Exit
Return

/*:VRX         RexxAutoStartMain_Close
*/
Rexxautostartmain_close:
Call Quit
Return

/*:VRX         RexxAutoStartMain_ContextMenu
*/
Rexxautostartmain_contextmenu:
/*     ok = VRMethod( "MenuSettings", "Popup"  ) */
Return

/*:VRX         RexxAutoStartMain_Create
*/
Rexxautostartmain_create:
Trace 'N'
sub_trace = 'N'

level = Strip(Linein(startup_path || '\rxautost.lvl'))
Call Stream startup_path || '\rxautost.lvl', 'c', 'close'
level = level Stream(startup_path || '\rxautost.exe', 'c', 'query timestamp')
ok = VRSet( "RexxAutoStartMain", "Caption", "Rexx AutoStart" level )

If _initialize() Then
   Do                          /* initialize parameters and variables */
      xrc = 0
      If autoexec Then
         Do                                        /* execute program */
            Call _sayout exe_file 'started, level' level || '.', 0
            Call _sayout 'Running under the' os_name, 1
            Call _sayout os_comp 'at the' os_level 'level.', 2
            If wps_wait Then
               Do                      /* wait for Desktop population */
                  xrc = _wpswait()
                  Call _playpicture
               End
            If sc_open | sc_wait Then
               Do                             /* wait for Warp Center */
                  If sc_open Then
                     xrc = WPToolsSetObjectData('<WP_WARPCENTER>', 'OPEN=DEFAULT;')
                  warpcenter_title = _getobjecttitle('<WP_WARPCENTER>')
                  xrc = _objwait(warpcenter_title)
                  Call _playpicture
               End
            If tb_open | tb_wait Then
               Do                                 /* wait for Toolbar */
                  If tb_open Then
                     xrc = WPToolsSetObjectData('<WP_LAUNCHPAD>', 'OPEN=DEFAULT;')
                  toolbar_title = _getobjecttitle('<WP_LAUNCHPAD>')
                  xrc = _objwait(toolbar_title)
                  Call _playpicture
               End
            If xc_open | xc_wait Then
               Do                                 /* wait for XCenter */
                  If xc_open Then
                     xrc = WPToolsSetObjectData('<XWP_XCENTER>', 'OPEN=DEFAULT;')
                  xcenter_title = _getobjecttitle('<XWP_XCENTER>')
                  xrc = _objwait(xcenter_title)
                  Call _playpicture
               End
            If od_wait Then
               Do                          /* wait for Object Desktop */
                  If od_cc Then
                     Do
                        controlcenter_title = _getobjecttitle('<OBJD_CONTROLCENTER>')
                        xrc = _objwait(controlcenter_title)
                        Call _playpicture
                     End
                  Else
                     Call _sayout '[' || controlcenter_title || '] has not been selected for activation.', 2
                  If od_tlp Then
                     Do
                        tablaunchpad_title = _getobjecttitle('<OBJD_TABLAUNCHPAD>')
                        xrc = _objwait(tablaunchpad_title)
                        Call _playpicture
                     End
                  Else
                     Call _sayout '[' || tablaunchpad_title || '] has not been selected for activation.', 2
               End
            If delay_wait <> 0 Then
               Do                         /* delay further processing */
                  xrc = _delayswitch()
                  Call _playpicture
               End
            If startup_wait & VRFileExists( bootdrive || "\startup.cmd" ) Then
               Do
                  startup_title = VRParseFileName( bootdrive || "\startup.cmd", "NE" )
                  xrc = _objdone(startup_title)
                  Call _playpicture
               End
            xrc = _autoexec()           /* open startupfolder objects */
            If enablelanstart Then
               Do
                  islan = _lanwaitforconnection()
                  If islan Then
                     Do
                        xrc = _lanopenstartupfolder()
                     End
                  Else
                     Call _sayout "Could not start and/or connect to the network. LAN StartupFolder not processed.", 2
               End
            Else
               Call _sayout "LAN StartupFolder disabled.", 1
            xrc = _cleanup(xrc)
         End
   End                                                  /* if init... */
Call _playsoundevent(sound_done)
Call SysSleep sleepsec
Call Quit
Return
/*:VRX         SPIN_sleepsec_Change
*/
Spin_sleepsec_change:
sleepsec = VRGet("SPIN_sleepsec","Value")
Return

