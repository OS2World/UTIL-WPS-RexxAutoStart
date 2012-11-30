/* PB_InstallSound_Click */
    /* This routine is loosely based on Ulrich M”ller's sound001.cmd */

    /* enable new RexxAutoStart system sound */
    MMINI = SysBootDrive()||"\MMOS2\MMPM.INI"

    /* these are the titles of the sounds to be created */
    RexxAutoStart_Done  = "RexxAutoStart: Done" 
    RexxAutoStart_Open  = "RexxAutoStart: Open object" 
    RexxAutoStart_Abort = "RexxAutoStart: Abort"

    /* Create empty sound entries */
    rc = SysINI(MMINI, "MMPM2_AlarmSounds", "681", "#"||RexxAutoStart_Done||"#100")    
    rc = SysINI(MMINI, "MMPM2_AlarmSounds", "682", "#"||RexxAutoStart_Abort||"#100")   
    rc = SysINI(MMINI, "MMPM2_AlarmSounds", "683", "#"||RexxAutoStart_Open||"#100")


    /* open WP_SOUND */
    ok = SysOpenObject("<WP_SOUND>","DEFAULT",1)
exit
