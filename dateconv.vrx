/*:VRX         Dateconv
*/
/*----------------------------------------------------------------------------+
| DATECONV FUNCTION                                                           |
+-----------------------------------------------------------------------------+
| This code is a REXX internal function; add it to your REXX programs.        |
| See DATECONV PACKAGE and DATECONV HELPCMS for more information.             |
+-----------------------------------------------------------------------------+
| Labels used within DATECONV Procedure are:                                  |
|   Dateconv:             <--- entry point                                    |
|   Dateconv_yy2cc:       <--- 2 digit to 4 digit year conversion
|   Dateconv_b2s_s2b:     <--- Basedate/Sorted format conversion              |
+-----------------------------------------------------------------------------+
| YYMMDD Change history:
| 900803 rlb v1.0 new code.   Russel L. Brooks    BROOKS/SJFEVMX
| 900808 rlb v2.0 new, better, faster.  doesn't use old BASEDATE code.
| 900821 rlb v3.0 add Arg(4) "Yx" to control assumed leading year digits.
|                 add format_out "L" for leap year.
| 910220 rlb v4.0 add Arg(5) Offset output date +/- days.
|                 Turn Trace Off at both labels. Set ERROR in Month Select.
| 910226 rlb v4.1 move TRACE past PROCEDURE for compiler.
| 910418 rlb v4.2 add ISO date format yyyy-mm-dd.
|                 allow input date to default to TODAY.
|                 convert all uses of EBCDIC Not sign "ª" to "<>".
|                 change input date parsing to allow leading blanks.
|                 if offset amount is 0 turn offset off.
| 910916 rlb v5.0 generate all formats but select what is requested.
|                 reduce overchecking, drop numerics 15 in b2s2b routine.
|                 allow muliple format request.
| 930414 rlb v5.1 bugfix: don't allow yyyymm00 as a valid Date(S) date.
| 940831 rlb v6.0 bugfix: better detection of invalid Date(J|U) dates.
|                 combine Date(E|O|U) code.  remove unneeded code.
|                 Signal on NoValue (but _we_ don't have 'novalue' label).
|                 only develop DOW, Month, Leapyear if asked for.
|                 test numbers w/ verify(integer) instead of datatype(W).
| 950113 rlb v6.1 parse out days/month for very small speed increase.
| 980629 rlb v7.0 changed internal variable 'yx' to 'cc' (century).
|                 if Fi=U/E/O/J & cc = '' then 100 year sliding window.
|
+----------------------------------------------------------------------------*/
Dateconv:
Procedure
Trace o
Signal On Novalue                            /* force error detection */

Parse Upper Arg date date_xtra, fi xtra1, fo xtra2, cc xtra3, offset

Select
   When xtra1 <> '' Then
      out = 'ERROR'
   When xtra2 <> '' Then
      out = 'ERROR'
   When xtra3 <> '' Then
      out = 'ERROR'
   When Arg() > 5 Then
      out = 'ERROR'
   Otherwise                                            /* initialize */
      Parse Value fi With 1 fi 2 . sdate bdate out .  /* 1 ltr + nuls */
   today = Date('S') Date('B')
End

/*----------------------------------------------------------------------+
| Input date formats U/E/O/J only use 2 digit years.  If CC is null then
| we'll calculate an appropriate century using a 100 year sliding window
| similar to what Rexx's Date() uses.
|
| Date format "C" is different.  Event though it doesn't specify a
| century we won't try to calculate one based on a sliding window.
| The user can specify an alternate century via Arg(4) "CC".
+----------------------------------------------------------------------*/
If cc <> '' Then                                  /* check user value */
   Select
      When Verify(cc,'0123456789') > 0 Then
         out = 'ERROR'                                       /* <>Num */
      When Length(cc) <> 2 Then
         out = 'ERROR'
      When cc < 0 Then
         out = 'ERROR'
      Otherwise Nop                             /* user's CC looks ok */
   End

/*----------------------------------------------------------------------+
| If no leading +/- sign then treat as +.  User could use + but if not
| included in quotes then REXX strips off the + sign.
+----------------------------------------------------------------------*/
Parse Value Space(offset,0) With 1 offset_sign 2 offset_amnt . 1 offset .
If offset = '' Then
   offset = 0
Else
   Do
      If offset_sign = '+' | offset_sign = '-' Then
         Nop
      Else
         Do
            offset_sign = '+'            /* missing so default to '+' */
            offset_amnt = offset   /* use entire user field as amount */
         End
      If Verify(offset_amnt,'0123456789') >0 Then
         out = 'ERROR'                                       /* <>Num */
      If offset_amnt = 0 Then
         offset = 0                              /* no offset request */
      Else
         offset = 1                /* yes, return date needs shifting */
   End

/*----------------------------------------------------------------------+
| Examine date according to "fi" (format in) caller passed.  If ok then
| convert date to either "B"asedate, "S"orted, or both formats.
|
| Dates are converted because it is easy to create "fo" (format out)
| dates from one or the other of these input formats.  This also limits
| having to directly support every possible "fi" to "fo" combination.
+----------------------------------------------------------------------*/
Select
   When out <> '' Then
      Nop                                   /* Error already detected */
   When fi = '' Then                                         /* today */
      Do
         /*----------------------------------------------------------------+
         | special case.  allow input date and input format to default to
         | TODAY.  This bypasses input date validation because we can rely
         | on REXX to supply valid dates.
         +----------------------------------------------------------------*/
         If date = '' Then
            Parse Value today With sdate bdate .
         Else
            out = 'ERROR'                /* missing FormatIN for date */
      End
   When fi = 'N' Then                           /* Normal dd Mmm yyyy */
      Do/* Test for N early because its only one that uses 'date_xtra' */
         Parse Value date date_xtra With dd mm yy date_xtra
         If date_xtra <> '' Then
            out = 'ERROR'                           /* too many parms */
         Else
            Do
               mm = Wordpos(mm,'JAN FEB MAR APR MAY JUN JUL AUG SEP OCT NOV DEC')
               If mm = 0 Then
                  out = 'ERROR'             /* invalid 3 letter month */
               Else
                  sdate = yy || Right(mm,2,0)Right(dd,2,0)
            End
      End
   When date_xtra <> '' Then
      out = 'ERROR'                                 /* too many parms */
   When fi = 'B' Then
      bdate = date                                 /* Basedate dddddd */
   When fi = 'S' Then
      sdate = date                                 /* Sorted yyyymmdd */
   When fi = 'D' Then                                     /* Days ddd */
      Select
         When Verify(date,'0123456789') > 0 Then
            out = 'ERROR'                                    /* <>Num */
         Otherwise
            yyyy = Left(today,4)
         dd = Dateconv_b2s_s2b(yyyy'0101','S')             /* Jan 1st */
         temp = Dateconv_b2s_s2b(yyyy+1'0101','S')/* Jan 1st next year */
         If date < 1 | date > temp-dd Then
            out = 'ERROR'                              /* max 365|366 */
         Else
            bdate = dd + date - 1
      End
   When fi = 'C' Then                                /* Century ddddd */
      Select
         When Verify(date,'0123456789') > 0 Then
            out = 'ERROR'                                    /* <>Num */
         Otherwise
            If cc = '' Then
            cc = Left(today,2)
         dd = Dateconv_b2s_s2b(cc'000101','S')        /* this century */
         temp = Dateconv_b2s_s2b(cc+1'000101','S')    /* next century */
         If date<1 | date>temp-dd Then
            out = 'ERROR'                          /* max 36524|36525 */
         Else
            bdate = dd + date - 1
      End
   When fi = 'J' Then                                 /* Julian yyddd */
      Select
         When Length(date) <> 5 Then
            out = 'ERROR'
         When Verify(date,'0123456789') > 0 Then
            out = 'ERROR'                                    /* <>Num */
         Otherwise
            Parse Value date With 1 yy 3 ddd .
         If cc = '' Then
            cc = Dateconv_yy2cc(yy)
         yyyy = cc || yy
         dd = Dateconv_b2s_s2b(yyyy'0101','S')             /* Jan 1st */
         temp = Dateconv_b2s_s2b(yyyy+1'0101','S') /* Jan 1st next yy */
         If ddd < 1 | ddd > temp-dd Then
            out = 'ERROR'                              /* max 365|366 */
         Else
            bdate = dd + ddd - 1
      End
   Otherwise                /* USA|European|Ordered|ISO ...or invalid */
      Select
         When fi = 'U' Then
            Parse Value date With mm'/'dd'/'yy .
         When fi = 'E' Then
            Parse Value date With dd'/'mm'/'yy .
         When fi = 'O' Then
            Parse Value date With yy'/'mm'/'dd .
         When fi = 'I' Then
            Parse Value date With 1 cc 3 yy'-'mm'-'dd .
         Otherwise out = 'ERROR'                 /* invalid Format_In */
      End
   Select
      When out <> '' Then
         Nop
      When Verify(Space(cc yy mm dd,0),'0123456789') > 0 Then
         out = 'ERROR'
      When Length(yy) <> 2 Then
         out = 'ERROR'
      When Length(mm) > 2 Then
         out = 'ERROR'
      When Length(dd) > 2 Then
         out = 'ERROR'
      Otherwise
         If cc = '' Then
         cc = Dateconv_yy2cc(yy)
      sdate = cc || Right(yy,2,0)Right(mm,2,0)Right(dd,2,0)
   End
End

/*----------------------------------------------------------------------+
| If the output date is being shifted by an offset then...
|   1- get the basedate if it doesn't already exist
|   2- offset the basedate by the amount requested
|   3- scratch sorted date because it doesn't match offset basedate
+----------------------------------------------------------------------*/
If offset & out = '' Then
   Do
      If bdate = '' Then
         Do
            bdate = Dateconv_b2s_s2b(sdate,'S')
            If bdate = '' Then
               out = 'ERROR'
         End
      If out = '' Then                                    /* no Error */
         Do
            If offset_sign = '+' Then
               bdate = bdate + offset_amnt
            Else
               bdate = bdate - offset_amnt
         End
      sdate = ''  /* date shifted, if sdate existed it is now invalid */
   End

/*----------------------------------------------------------------------+
| we have Basedate or Sorted, generate the other if we don't have both.
+----------------------------------------------------------------------*/
Select
   When out <> '' Then
      Nop                                                    /* error */
   When bdate = '' Then
      Do
         bdate = Dateconv_b2s_s2b(sdate,'S')
         If bdate = '' Then
            out = 'ERROR'
      End
   When sdate = '' Then
      Do
         sdate = Dateconv_b2s_s2b(bdate,'B')
         If sdate = '' Then
            out = 'ERROR'
      End
   Otherwise Nop/* both Bdate and Sdate already exist (and no errors) */
End

Parse Value sdate With 1 yyyy 5 . 1 cc 3 yy 5 mm 7 dd .
Parse Value '' With ddd ddddd month .       /* (re)initialize to null */

/*----------------------------------------------------------------------+
| "fo" Format_Out defaults to "Normal" out.
| "*" means return multiple formats, ALL if just "*" or the set of dates
| specified by the letters following "*".
+----------------------------------------------------------------------*/
Parse Value fo With 1 fo_string 2 temp
Select
   When fo_string = '' Then
      fo_string = 'N'                     /* default: "Normal" format */
   When fo_string <> '*' Then
      Nop                         /* use single letter in 'fo_string' */
   Otherwise
      If temp = '' Then
      fo_string = 'NBSMWDJCOEULI'                      /* all formats */
   Else
      fo_string = temp         /* multiple formats selected by caller */
End

If out = '' Then                                   /* if no Error yet */
   Do While fo_string <> ''
      Parse Value fo_string With 1 fo 2 fo_string
      Select
         When fo = 'B' Then
            out = out bdate                               /* Basedate */
         When fo = 'S' Then
            out = out sdate                                 /* Sorted */
         When fo = 'M' | fo = 'N' Then
            Do
               If month = '' Then
                  Do
                     temp = 'January February March April May June July'
                     temp = temp 'August September October November December'
                     month = Word(temp,mm)
                     If month = '' Then
                        Do
                           out = 'ERROR'
                           Leave
                        End
                  End
               If fo = 'M' Then
                  out = out month                            /* Month */
               Else
                  out = out dd+0 Left(month,3) yyyy         /* Normal */
            End
         When fo = 'W' Then                                /* Weekday */
            Do
               temp = 'Monday Tuesday Wednesday Thursday Friday Saturday Sunday'
               out = out Word(temp,(bdate//7)+1)
            End
         When fo = 'D' | fo = 'J' Then
            Do
               If ddd = '' Then
                  Do
                     ddd = Dateconv_b2s_s2b(yyyy'0101','S')
                     If ddd = '' Then
                        Do
                           out = 'ERROR'
                           Leave
                        End
                     Else
                        ddd = bdate - ddd + 1
                  End
               If fo = 'D' Then
                  out = out ddd                               /* Days */
               Else
                  out = out yy || Right(ddd,3,0)            /* Julian */
            End
         When fo = 'C' Then                                /* Century */
            Do
               ddddd = Dateconv_b2s_s2b(cc'000101','S')
               If ddddd = '' Then
                  Do
                     out = 'ERROR'
                     Leave
                  End
               Else
                  ddddd = bdate - ddddd + 1
               out = out ddddd
            End
         When fo = 'L' Then                               /* Leapyear */
            Do
               Select
                  When yyyy // 4 > 0 Then
                     leap_year = 0
                  When yyyy // 100 > 0 Then
                     leap_year = 1
                  When yyyy // 400 = 0 Then
                     leap_year = 1
                  Otherwise leap_year = 0
               End
               out = out leap_year
            End
         When fo = 'E' Then
            out = out dd'/'mm'/'yy                        /* European */
         When fo = 'O' Then
            out = out yy'/'mm'/'dd                         /* Ordered */
         When fo = 'U' Then
            out = out mm'/'dd'/'yy                             /* USA */
         When fo = 'I' Then
            out = out yyyy'-'mm'-'dd                           /* ISO */
         Otherwise
            out = 'ERROR'                /* Format_Out not recognized */
         Leave
      End
   End

If out = 'ERROR' Then
   out = ''                   /* null return indicates function error */
Return Strip(out,'L')          /*  <---  Dateconv Function exits here */


/*----------------------------------------------------------------------+
| Calculate a suitable Century for a 2 digit year using a sliding window
| similar to Rexx's Date() function.
|
|   (current_year - 50) = low end of window
|   (current_year + 49) = high end of window
+----------------------------------------------------------------------*/
Dateconv_yy2cc:
temp = Left(today,4) + 49
If (Left(temp,2)||Arg(1)) <= temp Then
   Return Left(temp,2)
Else
   Return Left(temp,2) - 1


/*----------------------------------------------------------------------+
| Convert Date(B) <--> Date(S)
|
| Arg(1) :  Date(B) or Date(S) date to be converted to other format.
|
| Arg(2) :  "B" or "S" to identify Arg(1)
|
| Return :  the converted date or "" (null) if an error detected.
+----------------------------------------------------------------------*/
Dateconv_b2s_s2b:
Procedure
Trace o
Signal On Novalue                            /* force error detection */

Arg dd .         /* Total days or sorted date, don't know which (yet) */
If Verify(dd,'0123456789') > 0 Then
   Return ''                                                 /* <>Num */

/* Initialize Days per month stem */
temp = 0 31 28 31 30 31 30 31 31 30 31 30 31
Parse Value temp With d. d.1 d.2 d.3 d.4 d.5 d.6 d.7 d.8 d.9 d.10 d.11 d.12 .

Select
   When Arg(2) = 'B' Then               /* Convert Date(B) to Date(S) */
      Do
         dd = dd + 1                           /* Date(S) = Date(B)+1 */
         yyyy = dd % 146097 * 400                  /* 400 year groups */
         dd = dd // 146097         /* all 400 year groups are similar */

         temp = dd % 36524                         /* 100 year groups */
         dd = dd // 36524
         If temp = 4 Then
            Do
               temp = 3/* back up 1, 4th 100 year group not same as 1st 3 */
               dd = dd + 36524
            End
         yyyy = temp * 100 + yyyy

         temp = dd % 1461                            /* 4 year groups */
         dd = dd // 1461
         If temp = 25 Then
            Do
               temp = 24/* back up 1, 25th 4 year group not same as 1st 24 */
               dd = dd + 1461
            End
         yyyy = temp * 4 + yyyy

         yyyy = dd % 365.25 + yyyy                   /* 1 year groups */
         dd = dd - ((dd % 365.25) * 365.25) % 1

         If dd = 0 Then
            Parse Value 12 31 With mm dd .                /* Dec 31st */
         Else
            Do
               yyyy = yyyy + 1                /* partial year = mm/dd */
               Select
                  When yyyy // 4 > 0 Then
                     Nop
                  When yyyy // 100 > 0 Then
                     d.2 = 29                            /* Leap Year */
                  When yyyy // 400 = 0 Then
                     d.2 = 29                            /* Leap Year */
                  Otherwise Nop
               End
               Do mm = 1 While dd > d.mm              /* count months */
                  dd = dd - d.mm            /* while subtracting days */
               End
            End
         Return Right(yyyy,4,0)Right(mm,2,0)Right(dd,2,0)/* Date(Sorted) */
      End
   When Arg(2) = 'S' Then               /* Convert Date(S) to Date(B) */
      Do
         If Length(dd) <> 8 Then
            Return ''
         Parse Value dd With 1 yyyy 5 mm 7 dd .
         Select
            When yyyy // 4 > 0 Then
               Nop
            When yyyy // 100 > 0 Then
               d.2 = 29                                  /* Leap Year */
            When yyyy // 400 = 0 Then
               d.2 = 29                                  /* Leap Year */
            Otherwise Nop
         End
         mm = mm + 0                              /* strip leading 0s */
         If d.mm = 0 Then
            Return ''                                    /* bad month */
         If dd = 0 | dd > d.mm Then
            Return ''                                     /* bad days */

         /* What was the Basedate December 31st of the "PREVIOUS" year?   */
         yyyy = yyyy - 1                             /* previous year */
         If yyyy = 0 Then
            days = 0                    /* there was no previous year */
         Else
            days = yyyy * 365 + (yyyy % 4) - (yyyy % 100) + (yyyy % 400)

         /* What 'nth' day of this year is mm/dd? */
         Do i = 1 To (mm-1)
            days = days + d.i         /* add days of completed months */
         End
         Return days + dd - 1           /* Date(Basedate) = Date(S)-1 */
      End
   Otherwise Return ''                /* Error: Arg(2) not "B" or "S" */
End
/*----------------------------------------------------------------------------+
| End of DATECONV FUNCTION code.                                              |
+----------------------------------------------------------------------------*/
