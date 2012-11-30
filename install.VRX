/*:VRX         Main
*/
/*  Main
*/
Main:
/* Recreate 'RexxAutoStart' objects.
 */

Call Rxfuncadd 'SysLoadFuncs','Rexxutil','SysLoadFuncs'
Call SysLoadFuncs
Call Rxfuncadd 'WPToolsLoadFuncs', 'WPTOOLS', 'WPToolsLoadFuncs'
Call WPToolsLoadFuncs

/* Script and icons have to reside in this directory */
basedir = Strip(Directory(),'T','\')
basedir = Translate(basedir)

level = Strip(Linein(basedir || '\rxautost.lvl'))
Call Stream basedir || '\rxautost.lvl', 'c', 'close'

Say 'Rexx Autostart Install' level
Say 'This install script does the following:'
Say
Say ' - create a folder for RexxAutoStart (named RexxAutoStart)'
Say ' - create objects for Setup Utility, Log file and manual'
Say ' - install the new sound events'
Say ' - open the sound object to configure new events'
Say ' - set the object id of your startup folder to <WP_START>, if no object id is present'
Say
Say 'Enter "go" to continue or anything else to quit.'
Parse Upper Pull ans .
If ans \= 'GO' Then
   Call Halt

Call Createobjects
Call Installsounds
Call Check_startup
ok = SysSetObjectData('<RexxAutoStart_Setup>','OPEN=DEFAULT;')
Exit

Createobject: Procedure
Parse Arg class, title, location, setup, collision
Say 'Creating ['title']'
rc = SysCreateObject( class, title, location, setup, collision )
If rc <> 1 Then
   Say ' > failed to create ['title' | 'class'] at location ['location']'
Return rc

Createobjects:

rc = Createobject( 'WPFolder',,
   'RexxAutoStart',,
   '<WP_DESKTOP>',,
   'ICONVIEW=NONGRID,NORMAL;'||,
   'TREEVIEW=LINES,VISIBLE,MINI;'||,
   'DEFAULTSORT=-2;'||,
   'ALWAYSSORT=YES;'||,
   'ICONFILE=' || basedir || '\rxastfld.ico;'||,
   'ICONPOS=50,17;'||,
   'ICONVIEWPOS=14,78,80,20;'||,
   'NOPRINT=YES;'||,
   'HIDEBUTTON=DEFAULT;'||,
   'MINWIN=DEFAULT;'||,
   'CCVIEW=DEFAULT;'||,
   'DEFAULTVIEW=DEFAULT;'||,
   'OBJECTID=<RexxAutoStart_Folder>',,
   'U' )

rc = Createobject( 'WPProgram',,
   'RexxAutoStart^Setup',,
   '<RexxAutoStart_Folder>',,
   'EXENAME='basedir'\RXAUTOUT.EXE;'||,
   'STARTUPDIR='basedir'\;'||,
   'PROGTYPE=PM;'||,
   'ICONFILE=' || basedir || '\rxautost.ico;'||,
   'ICONPOS=50,17;'||,
   'NOPRINT=YES;'||,
   'HIDEBUTTON=DEFAULT;'||,
   'MINWIN=DEFAULT;'||,
   'CCVIEW=DEFAULT;'||,
   'DEFAULTVIEW=DEFAULT;'||,
   'OBJECTID=<RexxAutoStart_Setup>',,
   'R' )

rc = Createobject( 'WPProgram',,
   'RexxAutoStart',,
   '<RexxAutoStart_Folder>',,
   'EXENAME='basedir'\RXAUTOST.EXE;'||,
   'STARTUPDIR=;'||,
   'PARAMETERS='basedir'\RXAUTOST.EXE;'||,
   'PROGTYPE=PM;'||,
   'ICONFILE=' || basedir || '\rxautost.ico;'||,
   'ICONPOS=50,17;'||,
   'NOPRINT=YES;'||,
   'HIDEBUTTON=DEFAULT;'||,
   'MINWIN=DEFAULT;'||,
   'CCVIEW=DEFAULT;'||,
   'DEFAULTVIEW=DEFAULT;'||,
   'OBJECTID=<RexxAutoStart>',,
   'R' )

rc = Createobject( 'WPProgram',,
   'RexxAutoStart^Information',,
   '<RexxAutoStart_Folder>',,
   'EXENAME=VIEW.EXE;'||,
   'PROGTYPE=PM;'||,
   'PARAMETERS='basedir'\rxautost.inf;'||,
   'NOPRINT=YES;'||,
   'HIDEBUTTON=DEFAULT;'||,
   'MINWIN=DEFAULT;'||,
   'CCVIEW=NO;'||,
   'DEFAULTVIEW=DEFAULT;'||,
   'OBJECTID=<RexxAutoStart_Manual>',,
   'R' )

rc = Createobject( 'WPProgram',,
   'RexxAutoStart^Log File',,
   '<RexxAutoStart_Folder>',,
   'EXENAME=E.EXE;'||,
   'PROGTYPE=PM;'||,
   'PARAMETERS='basedir'\rxautost.log;'||,
   'NOPRINT=YES;'||,
   'HIDEBUTTON=DEFAULT;'||,
   'MINWIN=DEFAULT;'||,
   'CCVIEW=NO;'||,
   'DEFAULTVIEW=DEFAULT;'||,
   'OBJECTID=<RexxAutoStart_Logfile>',,
   'R' )

rc = Createobject( 'WPFolder',,
   'LAN Startup Folder',,
   '<RexxAutoStart_Folder>',,
   'ICONVIEW=NONGRID,NORMAL;'||,
   'TREEVIEW=LINES,VISIBLE,MINI;'||,
   'ICONFILE=' || basedir || '\rxastfld.ico;'||,
   'ICONPOS=50,17;'||,
   'ICONVIEWPOS=14,78,80,20;'||,
   'NOPRINT=YES;'||,
   'HIDEBUTTON=DEFAULT;'||,
   'MINWIN=DEFAULT;'||,
   'CCVIEW=DEFAULT;'||,
   'DEFAULTVIEW=DEFAULT;'||,
   'OBJECTID=<RexxAutoStart_LAN_Folder>',,
   'U' )

Return

Installsounds:
/* This routine is loosely based on Ulrich M”ller's sound001.cmd */

/* enable new RexxAutoStart system sound */
mmini = SysBootDrive()||"\MMOS2\MMPM.INI"

/* these are the titles of the sounds to be created */
rexxautostart_done = "RexxAutoStart: Done"
rexxautostart_open = "RexxAutoStart: Open object"
rexxautostart_abort = "RexxAutoStart: Abort"
rexxautostart_start = "RexxAutoStart: Start"

/* Create default sound entries */
rc = SysIni(mmini, "MMPM2_AlarmSounds", "681", basedir||"\Ready.WAV#"||rexxautostart_done||"#70"||'00'x)
rc = SysIni(mmini, "MMPM2_AlarmSounds", "682", basedir||"\Error.WAV#"||rexxautostart_abort||"#70"||'00'x)
rc = SysIni(mmini, "MMPM2_AlarmSounds", "683", basedir||"\dudubeep.wav#"||rexxautostart_open||"#70"||'00'x)
rc = SysIni(mmini, "MMPM2_AlarmSounds", "684", basedir||"\Open.WAV#"||rexxautostart_start||"#70"||'00'x)

Return

Check_startup:
If WPToolsQueryObject('<WP_START>') Then
   Return
Say 'No startup folder was identified with an object id of <WP_START>.'
If SysFileTree(SysBootDrive() || '\startup', 'test.', 'dso') = 0 Then
   Do i = 1 To test.0
      If WPToolsQueryObject(test.i, 'szClass', , 'szSetupString', 'szLocation') Then
         Do
            If szclass <> 'WPStartup' Then
               Iterate i
            If Pos('OBJECTID=', szsetupstring) <> 0 Then
               Iterate i
            Say 'Startup folder' test.i 'found in' szlocation || '.'
            Say 'Enter "OK" to make this the default startup folder.'
            Pull ans .
            If ans = 'OK' Then
               Do
                  Call WPToolsSetObjectData test.i, 'OBJECTID=<WP_START>;'
                  Return
               End
         End
   End
Return
/*:VRX         Halt
*/
Halt:
Exit

