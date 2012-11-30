/* test url */
trace 'r'
parse version version
part1 = arg(1)
parse arg part1
part1 = value(part1, , 'os2environment')
return 0

/*
[E:\work]testurl http://pws.prserv.net/mckinnis/nicpak/
     3 *-* parse version version
       >>>   "OBJREXX 6.00 18 May 1999"
     4 *-* part1 = arg(1)
       >>>   "1"
       >>>   "http://pws.prserv.net/mckinnis/nicpak/"
     5 *-* parse arg part2
       >>>   "http://pws.prserv.net/mckinnis/nicpak/"
     6 *-* return 0
       >>>   "0"
*/
/*
[E:\work]testurl http://pws.prserv.net/mckinnis/nicpak/
     3 *-*   Parse Version version;
       >>>     "REXXSAA 4.00 3 Feb 1999"
     4 *-*   part1 = arg(1);
       >>>     "http:"
     5 *-*   Parse Arg part2;
       >>>     "http:"
     6 *-*   Return 0;
       >>>     "0"
*/
