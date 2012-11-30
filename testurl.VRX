/*:VRX         Main
*/
Main:
    signal on halt
commandline = VRGet( "Application", "CommandLine" )
our_var = systempfilename('url?????')
our_url = value(our_var, commandline, 'os2environment')
address cmd 'start testurl.cmd' our_url
exit

/*:VRX         Halt
*/
Halt:

exit

