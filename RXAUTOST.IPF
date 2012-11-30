:userdoc.:title.RexxAutoStart
:docprof toc=123.
.***************************************************
.*** IPF-Generator Version 0.82 for Framework IV ***
.***************************************************

:h1 res=100.0. Introduction

:font facename='Default' size=0x0.:artwork align=center name='E:\DEV\REXX\VXREXX\Projects\RXAUTOST.2\RXAUTOST.BMP' .
:lines align=left.:font facename='Helv' size=36x20.RexxAutoStart:font facename='Default' size=0x0. Version 1.8.0 (31.03.2001) by :link  reftype=hd refid=Author.Herwig Bauernfeind:elink. and Chuck McCinnis
===========================================================================================
:elines.:p.This program is basically a workaround for timing problems that lead to a WPS hang on 
startup on certain OS&slr.2 versions and fixlevels. 
:p.What is more it provides the following features&colon.
:ul compact.
:li.Declare any folder as your startup folder. You even could use different folders 
for different startup sequences.
:li.RexxAutoStart can also (slightly) speed up boot process&comma. because harddisk activity is reduced (a bit).
:li.Startup process can be interrupted at any time.
:li.3 new cool sound events in the OS&slr.2 sound object.
:li.Configurable by GUI&comma. command line and environment variable
:eul.
:i1.what is it

:h1 res=200.1. License

:font facename='Default' size=0x0.:p.:hp8.From version 1.41 onward&comma. this program is free software (hmmm&comma.
it was always free&comma. but now it is GPLed); you can redistribute it
and&slr.or modify it under the terms of the GNU General Public License as
published by the Free Software Foundation; either version 2 of the
License&comma. or (at your option) any later version.:ehp8.

:p.This program is distributed in the hope that it will be useful&comma.
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

:p.You should have received a :link reftype=launch object='E.EXE' data='COPYING'.copy of the GNU General Public License:elink.
along with this program; if not&comma. write to the Free Software
Foundation&comma. Inc.&comma. 675 Mass Ave&comma. Cambridge&comma. MA
02139&comma. USA.

:p.So&comma. in short&colon. No money&comma. no warranty. Use at your own
risk. Pay nothing. Be happy.

:p.You are not allowed to think nasty about the author!
:i1.warranty
:i1.copyright
:i1.distribution
:i1.responsibility

:h1 res=300.2. Requirements

:font facename='Default' size=0x0.:p.This program was designed and developed on a system that runs OS&slr.2 Warp 4
German&comma. FixPack #06&comma. which did not boot any more after some WPS extensions
were installed (especially Object Desktop 2.0.x and CandyBarZ). Therefore the
"recommended" platform is&colon.
:ul.
:li.OS&slr.2 Warp 4&comma. FP#06 or better
:li.OS&slr.2 Warp 3 (almost fully supported from version 1.40 onward&comma. see :link  reftype=hd refid=Known_problems.Known
problems:elink.&comma. see :link  reftype=hd refid=Command_line_switches.command line switches:elink.).
:li.Fixpack #35 or higher (#40 tested) recommended on OS&slr.2 Warp 3.
:li.REXX (Classic REXX or Object REXX) installed.
:li.WPTools from Henk Kelder
(:link reftype=launch object='NETSCAPE.EXE' data='http://www.os2ss.com/information/kelder/wptool26.zip'.http&colon.&slr.&slr.www.os2ss.com&slr.information&slr.kelder&slr.wptool31.zip:elink.)
:li.VROBJ.DLL the VX-REXX runtime library. Somebody out there who does not have it? 
(BTW it's located on the Warp 4 CD-ROM)
:eul.
:i1.requirements
:i1.version of OS&slr.2
:i1.fixpack
:i1.RxExtras
:i1.WPTools
:i1.Kelder&comma. Henk
:i1.OS&slr.2 Warp 3
:i1.OS&slr.2 Warp 4

:h1 res=400.3. Installation

:font facename='Default' size=0x0.:p.You have to take the following steps to get things running (Sorry my installer
is not smart enough by now)&colon.
:ul.
:li.Create a directory for :font facename='Courier' size=14x8.RexxAutoStart:font facename='Default' size=0x0.. Add this directory eventually to your PATH
and BOOKSHELF (recommended but not inevitable).
:li.Unzip the archive.
:li.Invoke the INSTALL.CMD script. This will create a folder and program objects.
:li.Place :font facename='Courier' size=14x8.WPTOOLS.DLL:font facename='Default' size=0x0. in a directory within your :font facename='Courier' size=14x8.LIBPATH:font facename='Default' size=0x0..
:li.Remove :font facename='Courier' size=14x8.WARPCENTER:font facename='Default' size=0x0. and :font facename='Courier' size=14x8.LAUNCHPAD:font facename='Default' size=0x0. from your :font facename='Courier' size=14x8.SET AUTOSTART:font
facename='Default' size=0x0. line in
:font facename='Courier' size=14x8.CONFIG.SYS:font facename='Default' size=0x0..:font facename='Helv' size=8x4. If you want to use Launchpad and&slr.or WarpCenter place 
them (or a shadow of them) into your startup folder.:font facename='Default' size=0x0.
:li.Add :font facename='Courier' size=14x8.SET RESTARTOBJECTS=NO:font facename='Default' size=0x0. (this is no typo!) to your :font facename='Courier' size=14x8.CONFIG.SYS:font facename='Default' size=0x0..
:eul.:font facename='Helv' size=8x4.:note.If you are updating from a previous release&comma. just copy 
the new files over the old ones.:font facename='Default' size=0x0.
:p.One additional step is required&colon.
:ul compact.
:li.Open RexxAutoStart Setup Utility to configure delays and options.
:li.Do not forget to place :font facename='Courier' size=14x8.START &slr.MIN RXAUTOST:font facename='Default' size=0x0. into your :font facename='Courier' size=14x8.STARTUP.CMD:font facename='Default' size=0x0. on your boot drive.
:li.RexxAutoStart Setup Utility can assist you on this. Use Edit - Create&slr.Modify&slr.Delete 
in order to have a valid :font facename='Courier' size=14x8.STARTUP.CMD:font facename='Default' size=0x0..
:eul.
:p.You do not have to change your way to handle programs that startup
on boot in any way&colon. Just drop them (or a shadow of them) into the
Startup-Folder&comma. the folder will be parsed upon every bootup and the 
newly created script will be executed immediately.

:p.The order of programs in Startup folder is the same as the one if 
you used Startup folder normally.

:i1.installation&comma. transparent usage
 
:i1.installation&comma. common steps
:i1.CONFIG.SYS
:i1.location for files
:i1.updating

:h1 res=500 Name=Command_line_switches.4. Configuration

:font facename='Default' size=0x0.:p.Some switches from version 1.60 have vanished. All the options of RexxAutoStart 
can be configured from the new Setup Utility (RXAUTOUT). Basically RexxAutoStart 
does not need switches or environment variable anymore but still supports them.
:p.Rule of thumb&colon. INI is default&comma. environment variable overrides INI&comma. command line 
overrides both others.
:ol.
:li.:hp2.Switches to get help&colon.
:sl compact.
:li.:ehp2.&slr.?      Simple list of valid switches with a short explanation.
:esl.
:li.:hp2.Generally used switches&colon.
:sl compact.
:li.:ehp2.&slr.WPS  Delay execution of this program until desktop (:hp5.:hp2.WPS:ehp5.:ehp2.) is populated
:li.&slr.OD     Delay execution of this program until Object Desktop's autostart
:li.        features (Tab LaunchPad and Control Center) have come up.
:li.        This feature has been added by Chuck McCinnis.
:li.&slr.D&colon.n    :hp5.:hp2.D:ehp5.:ehp2.elay execution of this program by n seconds (n = 1..99).
:li.&slr.F&colon."<FolderID>" Do not use <WP_START> but <FolderID> as startup :hp5.:hp2.F:ehp5.:ehp2.older.
:li.        This feature enables the user to have his very own private startup
:li.        folder&comma. which will not be known to any other program.
:li.&slr.L      :hp5.:hp2.L:ehp5.:ehp2.og every output into RXAUTOST.LOG.
:li.        This feature has been added by Chuck McCinnis.
:li.&slr.V      :hp5.:hp2.V:ehp5.:ehp2.erbose. Give us some hints what we are doing right now.
:esl.
:li.:hp2.Switches to control script creation&colon.
:sl compact.
:li.:ehp2.&slr.P&colon.n    :hp5.:hp2.P:ehp5.:ehp2.ause between started objects should be n seconds (n = 1..9). Default = 2.
:li.&slr.R&colon.n    Number of attempts (:hp5.:hp2.R:ehp5.:ehp2.etries) to open an object. Default = 2.
:esl.
:eol.
:p.RxAutoSt.EXE checks the value of the environmental variable RXAUTOST and reads switches from it.
Command line switches override the environment variable switches
:i1.environment variable
:i1.switches
:i1.command line
:i1.topic

:h1 res=600.5. What it does (and what it does not do)

:font facename='Default' size=0x0.:p.:hp2.What it does:ehp2.&colon.

:p.Basically the idea behind RexxAutoStart is&colon.
:ul compact.
:li.Forbid the WPS to restart anything&comma. which is likely to cause problems.
It is best to remove everything from SET AUTOSTART except PROGRAMS&comma.TASKLIST&comma.FOLDERS.
:li.Forbid the WPS even to start Startup Folders by SET RESTARTOBJECTS=NO.
:li.Place objects for everything that should be started in the now inactive Startup Folder.
:li.Call RxAutost.EXE from StartUp.CMD. It will query the inactive StartUp Folder and
open anything it finds in it&comma. but not all at once like the WPS does&comma. but one by one with
configurable attempts to open each object and configurable delays between each object.
:eul.

:p.:hp2.What it does not do:ehp2.&colon.

:p.RexxAutoStart does not pollute your system in any way&comma. except it
needs some space on your harddisk. It has its own INI file and does 
not pollute OS2.INI or OS2SYS.INI.

:p.It has been tested on many flavors of OS&slr.2 Version 3&comma. 4&comma. 4.5  and 4.51.

:i1.pollution
:i1.INI-entries
:i1.tested constellations
:i1.startup-folder

:h1 res=700 Name=Known_problems.6. Known problems

:font facename='Default' size=0x0.:ul.
:li.RexxAutoStart cannot process objects without an ObjectID or a ShadowID. While every
object should have an ID&comma. there are cases where they have not. I'm not sure when and how 
this happens.

:li.Executing RxAutoSt.EXE immediately after placing objects into the Startup 
folder may fail to properly read the object IDs. An invalid script is created 
in this case.

:li.The | character is not allowed in ObjectID and&slr.or ShadowIDs. If an ID contains 
this character&comma. the object will fail to open.

:li.RexxAutoStart should be run on systems that understand the SysBootDrive and 
the SysWaitForShell functions. There are workarounds for both built in&comma. but be 
careful to have RUNWORKPLACE point to your boot drive&comma. if your REXX version does
not understand the above functions&comma. otherwise results are unpredictable (for me).

:li.Do not compress the executables with lxLite&comma. it will be damaged by doing so!

:li.My English is not the best. Sorry folks... (That's a permanent restriction;-)

:li.No other problems are known at this time.
:eul.
:i1.known problems
:i1.problems
:i1.restrictions

:h1 res=800 Name=To-Do-List.7. To-Do-List

:font facename='Default' size=0x0.:p.I thought&comma. that I was through with RexxAutoStart&comma. but then
Chuck McKinnis&comma. who is a much better programmer than I am took
over and I was out of order for some months because of an MS attack on
my right eye&comma. from which fortunately recovered almost
completely.
:p.In late autumn 2000 I started to work on RexxAutoStart again. Chuck
had done 2 minor releases in the meantime and I was completely away
from the source code.
:p.I had done a few programs in VX-REXX for my work and wanted to port
RexxAutoStart to VX-REXX. My first attempt failed miserably.
:p.The second attempt looked promising&comma. but I could not afford the
time to work on it and complete it
:p.In mid February 2001 I learned that Chuck worked on a version 2.00
that he already had on his homepage. Chuck had moved to
GPF-Rexx&comma. which is a path I cannot and do not want to follow.
:p.What is more&comma. Chuck had dropped features&comma. I really wanted
to have in RexxAutosStart (the enviroment variable support&comma. for
example).
:p.So I decided to go on with my own port and implemented most of his
features (except the LAN Startup Folder). My INI files are backward
compatible to his. You even could use Chucks installer to configure
the common set of features.
:p.Today the feature set of my RexxAutoStart and Chuck's is a bit
different&colon.
:p.Chuck has a better installer and the LAN Startup feature.
:p.I have the interrupt button&comma. the sound effects and the backward
compatibility&comma. and maybe the better look.
:p.My future plans are to implemement the LAN startup folder (compatible
with Chuck) and to enhance the installer. A WPI version is in the
works.
:p.The manual has to be rewritten (baah...).
:i1.To-do-list
:i1.ideas
:i1.future

:h1 res=900.8. History

:font facename='Default' size=0x0.:lines align=left.
:hp5.1.8.0:ehp5. 31-03-2001 "My (Herwig's) comeback release"
               - completely ported to VX-REXX (done by Herwig)
               - added complete INI code (compabtible to Chuck)
                 (Chuck's LAN startup folder is missing)
               - created RxAutoUt (mostly compatible to Chuck)
                 (Chuck's install routine for CONFIG.SYS is missing)
               - added sound event codes for "Done"&comma. "Open Object" and "Abort"
               - added animated icon
               - Added INSTALL.CMD to create WPS-objects
1.8 alpha.1 18-02-2001 ("special Tony build")
               - beginning to implement Chuck's features from his 2.00
               - added interrupt button
               - added progress bar
1.8   15-10-2000 completely new port to VX-REXX&comma. skeleton only&comma. no release (done by Herwig).
1.7   05-10-2000 quickly ported to VX-REXX&comma. did not work&comma. no release (done by Herwig).

:hp5.1.62:ehp5.  10.08.2000 :hp4.Feature:ehp4.&colon. Modified the Object Desktop logic to remove dependencies 
                 on OD releases.
                 :hp8.Bugfix:ehp8.&colon. Modified utility to handle startup.cmd file in Rexx format.
                 :hp8.Bugfix:ehp8.&colon. Modified installation to check for acceptable level of WPTools.
                 :hp8.Bugfix:ehp8.&colon. The &slr.OD option in RxAutoSt caused an abend when no Object Desktop tasks
                           were selected to start.
                 everything done and released by Chuck McKinnis
:hp5.1.61:ehp5.  25.05.2000 :hp8.Bugfix:ehp8.&colon. Setting of the current directory was being done too late to locate necessary
                 dll modules.
                 :hp8.Bugfix:ehp8.&colon. Corrected the updating of various parameters by RxAutoUt.
                 everything done and released by Chuck McKinnis
:hp5.1.60:ehp5.  15.05.2000 :hp4.Changes:ehp4.&colon.
                 Removed any requirement for Object Rexx and&slr.or RxExtras.
                 Added a new parameter&comma. &slr.L (log information to a log file).
                 Updated the autostrt.cmd generation to support the &slr.L and &slr.V
                 options&comma. Warp 4&comma. Warp 3&comma. and Object Desktop (including standalone (&slr.S).
                 The parameter setup now appends the value of RXAUTOST to the values
                 on the command line (ie&comma. the command line parameters will be processed
                 as overrides).Added a generic console output routine to handle the &slr.V and &slr.L
                 options. Changed the parameter parsing to permit almost any value to be
                 entered after a semi-colon (everything by Chuck McCinnis).
:hp5.1.50:ehp5.  15.02.2000 :hp4.Feature:ehp4.&colon. Object Desktop support (by Chuck McCinnis) and &slr.OD switch!
                 &slr.EV switch. Nonfunctional GUI draft enclosed.
1.43  28.08.1999 :hp8.Bugfix:ehp8.&colon. Small letters were not properly recognized on some parameters.
:hp5.1.42:ehp5.  10.06.1999 :hp4.Feature:ehp4.&colon. Source code publicly available. Program under GNU GPL.
1.41  20.03.1999 Little (mostly cosmetic) changes in AutoStrt.CMD code.
                 :hp8.Bugfix:ehp8.&colon. &slr.A&colon.n switch was parsed wrongly. Code cleaned and beautified.
:hp5.1.40:ehp5.  01.03.1999 :hp4.Feature:ehp4.&colon. Executables for Classic REXX and Object REXX. New &slr.H[&colon.topic]-switch.
                 Added &slr.F and &slr.NI switches. &slr.WPS switch supported under OS&slr.2 Warp 3.
                 :hp8.Bugfix:ehp8.&colon. Blanks and ' in ObjectIDs or ShadowIDs led to an invalid script.
                 Missing ID was recognized correctly&comma. but led to an invalid script. Completed
                 necessary modifictions in CONFIG.SYS (SET AUTOSTART line was missing).
:hp5.1.35:ehp5.  22.02.1999 :hp4.Feature:ehp4.&colon. Added &slr.E switch&comma. i.e. even less pollution&colon.-)
1.34  21.02.1999 :hp4.Feature:ehp4.&colon. Removed &slr.H(istory) switch (this page)&comma. some little (partly cosmetic)
                 enhancements&comma. AutoStrt script code slightly changed. Manual in INF-format.
:hp5.1.33:ehp5.  10.02.1999 :hp4.Feature:ehp4.&colon. Self extracting&comma. self attaching icon upon first start.
1.32  08.02.1999 :hp8.Bugfix:ehp8.&colon. Program checks whether it runs on OS&slr.2 Warp 3 or 4.
1.31  07.02.1999 :hp8.Bugfix:ehp8.&colon. Did not run on OS&slr.2 Warp 3. Ouch!
1.30  29.01.1999 :hp4.Feature:ehp4.&colon. Enhanced standalone code&comma. enhanced &slr.A switch.
1.20  26.01.1999 :hp8.Bugfix:ehp8.&colon. Modified code to read ShadowID&comma. if no ObjectID is available.
                 Now really all kinds of objects should be startable..
1.15  24.01.1999 :hp4.Feature:ehp4.&colon. Added &slr.A switch.
1.14  21.01.1999 :hp4.Feature:ehp4.&colon. Added &slr.R parameter for number of retries. New retry code.
1.13  21.01.1999 :hp4.Feature:ehp4.&colon. Added &slr.S parameter and code to run AutoStrt.CMD standalone.
                 Changed code so that &slr.WPS and &slr.D switch can be used together
                 sensibly (to provide a delay after desktop has been populated.
1.12  21.01.1999 :hp4.Feature:ehp4.&colon. Added code for 1 retry&comma. if 1st attempt to open an object failed.
1.11  19.01.1999 :hp4.Feature:ehp4.&colon. Changed standard behaviour and &slr.NV switch to &slr.V.
                 Some little (cosmetic) enhancements.
1.10  10.01.1999 :hp4.Feature:ehp4.&colon. Shortened the created script by using a subroutine.
1.02  10.01.1999 :hp8.Bugfix:ehp8.&colon. Changed view to open from RUNNING (4) to DEFAULT (0).
                 Now all kinds of objects should be startable.
1.01  07.01.1999 :hp4.Feature:ehp4.&colon. Enhanced method to determine bootdrive&comma. &slr.WPS-switch to wait for
                 populated desktop&comma. display current REXX-Version on help.
:hp5.1.00:ehp5.  28.12.1998 Initial release in Fidonet echo OS2.WPS.GER.

:elines.:i1.history
:i1.features
:i1.fixed bugs
:i1.bugs&comma. fixed
:i1.random features&comma. fixed
:i1.releases

:h1 res=1000.9. Thanks go to ...

:font facename='Default' size=0x0.:ul.
:li.IBM for creating OS&slr.2. Shame on them for neglecting us this way by now!
:li.Chuck McCinnis for adding Object Desktop support and many other things.
:li.:link reftype=launch object='NETSCAPE.EXE' data='http://www.os2ss.com/information/kelder'.Henk Kelder:elink. for creating WPTools (and other valuable utilities for OS&slr.2).
:li.:link reftype=launch object='NETSCAPE.EXE' data='http://www.ozemail.com.au/~dbareis'.Dennis Bareis:elink. for his Rexx compiler.
:li.Ulrich M&oe.ller for giving me the idea how to exploit the OS&slr.2 sound object.
:li.Bernd Schemmer for his Rexx Tips and Tricks!
:li.Andrew Zabolotny for creating lxLite. Great tool&comma. really!
:li.Jeff Glatt for his way writing disclaimers!
:li.Additional thanks go to Martin Binder&comma. Burkhard Schneider&comma. Wilfried Brinkmann&comma.
Stephen Worthington and (once more) Martin Binder.
:eul.
:i1.Thanks

:h1 res=1100 Name=Author.10. Authors

:font facename='Default' size=0x0.:p.My name is Herwig Bauernfeind and I am from Austria. I'm working in 
the accounting business. My programming skills are very limited&comma. but 
I have been working with OS&slr.2 for about 8 years and I really learned 
a lot from this. REXX is a great language for someone like me (IMHO it's one
of the killer features of OS&slr.2) and that's why I chose it...

:p.Versions of RexxAutoStart from 1.41 onward come under the GNU GPL license with 
full source. If you think source still looks ugly and style is bad and&comma. heck&comma. this 
or that construction is ridiculous&comma. beautify it&comma. streamline it and send it back 
to me. I will be happy to enclose the changes and mention your name in the next release;-)

:p.If you find bugs&comma. just email me. If you think it runs fine&comma. just email me&comma. too.
Any feedback is appreciated.
:p.You can reach me&colon.
:lines align=left.
By email&colon. :link reftype=launch object='NETSCAPE.EXE' data='mailto:herwig.bauernfeind@aon.at'.herwig.bauernfeind@aon.at:elink.
FidoNet&colon.  :link reftype=fn refid=3.Herwig Bauernfeind:elink.&comma. 2&colon.313&slr.41.5
:elines.:p.My name is Chuck McKinnis&comma. and I live in New Mexico&comma. USA. I retired from IBM
in 1991 after 26 years as a Senior Systems Engineer.  I currently do some part-time
consulting work for Denver Solutions Group&comma. an IBM Business Partner&comma. and I specialize
in IBM S&slr.390 mainframe operating systems and communications.  I have been using
OS&slr.2 since Version 1.3&comma. and I have been writing REXX code since it was first
introduced by IBM for the VM&slr.370 operating system.
:p.You can reach me&colon.
:lines align=left.By email&colon.:link reftype=launch object='NETSCAPE.EXE' data='mailto:mckinnis@attglobal.net'.mckinnis@attglobal.net:elink.
:elines.:p.My web page also contains some interesting code&colon. http&colon.&slr.&slr.pws.prserv.net&slr.mckinnis&slr.

:fn id=2.:p.herwig.bauernfeind@aon.at:efn.
:fn id=3.:p.You got me!:artwork align=left name='E:\DEV\INF\HERWIG.BMP'.:efn.
:i1.author
:i1.contacting
:i1.email address
:i1.fidonet address
:i1.source


:p.:link reftype=fn refid=IPFGen.About IPF-Generator:elink.
:fn id=IPFGen.:lines.:hp8.:font facename='Tms Rmn' size=24x14.IPF-Generator Version 0.82:font facename=Helv size=8x4.alpha:ehp8.:font facename='Tms Rmn' size=24x14.
:font facename=Helv size=8x4.Another fine user developed piece of software
written in FRED for good, old Framework IV.
(c) by Herwig Bauernfeind. All rights reserved.
:elines.:p.IPF-Generator is (1) a printer driver and (2) a bound set of macros, that create the IPF-Tags (not all by now), translate Framework container structures to .IPF structures and call the IBM IPF-Compiler at last.
:p.Viewers available for OS/2-PM, OS/2-Text, Win16, DOS-Text.:efn.
:euserdoc.
