/*:VRX         Main
*/
Main:
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
Call Halt audiorc
Exit

/*:VRX         Halt
*/
Halt:
Parse Arg macrc
/* Make sure multimedia-REXX is properly terminated. */
Call mciRxExit
Exit macrc

/*:VRX         LogError
*/
Logerror:
Return

