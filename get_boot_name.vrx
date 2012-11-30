/*:VRX         Get_boot_name
Usage:  get_boot_name(<drive>)
Where:     drive = drive to be queried, default = current boot drive
Result:    boot manager name of drive for use in "setboot /IBA:name"
*/
Get_boot_name: Procedure
save_trace = Trace('N')
Parse Arg bootdrive
if bootdrive = '' then
  bootdrive = SysBootDrive()
/* clear out queue for response */
Do Queued()
   Pull .
End
Address cmd '@lvm /query: bootable, all; 2>&1|RXQUEUE'
Do Queued()
   Parse Pull drive name .
   If drive = bootdrive Then
      boot_name = name
End
Return boot_name

