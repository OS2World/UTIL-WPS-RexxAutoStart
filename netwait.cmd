/*:VRX */
_lanwaitforconnection:
Trace 'r'
Call Rxfuncadd 'LsLoadFuncs', 'NETUTIL', 'LsLoadFuncs'
Call LsLoadFuncs
ls_retries = 5
ls_sleepsec = 5
simplelogononly = 1
/*    ok = VRRedirectStdIO( On, "" ) */
/* LAN connection wait logic */
ls_info = 0
ls_logged = 0
Call _sayout 'Waiting for LAN connection.', 1
Do ls_retries While \ls_logged
   Call Checkforevent
   Parse Value LsMyInfo() With lanrc my_uid admin? my_machine my_domain my_domain_controller .
   If lanrc = 0 | lanrc = 2453 Then
      Do
         If simplelogononly Then
            Do
               If my_uid \= '?' Then
                  Do
                     Call _sayout my_uid 'is logged on to' Strip(my_machine, 'l', '\'), 2
                     ls_info = 1
                     ls_logged = 1
                  End
            End
         Else
            Do
               If my_domain_controller \= '?' Then
                  Do
                     lanrc = LsLogonUser('lan_users', my_domain_controller)
                     If lanrc = 0 & lan_users.0 > 0 Then/* someone is logged on */
                        Do i = 1 To lan_users.0/* check for this user */
                           If my_uid = lan_users.i.0uid Then/* logged on */
                              Do
                                 Call _sayout my_uid 'is logged on to' Strip(my_domain_controller, 'l', '\'), 2
                                 ls_info = 1
                                 ls_logged = 1
                              End
                        End
                  End
               Else
                  Do
                     Call _sayout 'The domain controller for domain' my_domain 'cannot be found.', 2
                     ls_logged = 1
                  End
            End
         If \ls_logged Then
            Do
               Call _sayout 'Waiting for logon.', 3
               Call SysSleep ls_sleepsec
            End
      End
   Else
      Do
         If lanrc = 2138 Then
            Call _sayout 'Requester not started.', 3
         Call SysSleep ls_sleepsec
      End
End
If \ls_logged Then
   Call _sayout 'Wait for LAN connection timed out.', 2
Return ls_info                             /* 1 = success 0 = failure */

Checkforevent:
Return
_sayout: Procedure
Parse Arg text
Say text
Return
