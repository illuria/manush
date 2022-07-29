MODULE mnshCrt;

IMPORT VT100, Platform, Out, Strings;

CONST

   (* foreground colors *)
   Black*        = "30m";
   Red*          = "31m";
   Green*        = "32m";
   Yellow*       = "33m";
   Blue*         = "34m";
   Magenta*      = "35m";
   Cyan*         = "36m";
   LightGray*    = "37m";
   Default*      = "39m";
   DarkGray*     = "90m";
   LightRed*     = "91m";
   LightGreen*   = "92m";
   LightYellow*  = "93m";
   LightBlue*    = "94m";
   LightMagenta* = "95m";
   LightCyan*    = "96m";
   White*        = "97m";

   (* background colors *)
   BBlack*       = "40m";
   BRed*         = "41m";
   BGreen*       = "42m";
   BYellow*      = "43m";
   BBlue*        = "44m";
   BMagenta*     = "45m";
   BCyan*        = "46m";
   BLightGray*   = "47m";
   BDefault*     = "49m";
   BDarkGray*    = "100m";
   BLightRed*    = "101m";
   BLightGreen*  = "102m";
   BLightYellow* = "103m";
   BLightBlue*   = "104m";
   BLightMagenta*= "105m";
   BLightCyan*   = "106m";
   BWhite*       = "107m";


(* Add-in for blinking *)
   Blink*         = 128;

   PROCEDURE Reset*;
   BEGIN
     VT100.Reset
   END Reset;

   PROCEDURE EraseDisplay*;
   BEGIN
      VT100.ED(2);
   END EraseDisplay;

   PROCEDURE ClrScr*;
   BEGIN
      VT100.ED(2);
   END ClrScr;

   PROCEDURE ClrEol*;
   BEGIN
      VT100.EL(0);
   END ClrEol;

   PROCEDURE cursoroff*;
   BEGIN
      VT100.DECTCEMl;
   END cursoroff;

   PROCEDURE cursoron*;
   BEGIN
      VT100.DECTCEMh;
   END cursoron;

   PROCEDURE Delay*(ms: INTEGER);
   BEGIN Platform.Delay(ms) END Delay;

   PROCEDURE GotoXY* (x, y: INTEGER);
   BEGIN
      VT100.CUP (y, x);
   END GotoXY;

   PROCEDURE HighVideo*;
   VAR tmpstr: ARRAY 5 OF CHAR;
   BEGIN
      COPY (VT100.CSI, tmpstr);
      Strings.Append(VT100.Bold, tmpstr);
      Out.String(tmpstr);
   END HighVideo;

   PROCEDURE DelLine*;
   BEGIN
      VT100.EL(2);
   END DelLine;

   PROCEDURE InsLine*;
   BEGIN
      VT100.SCP;
      Out.Ln;
      VT100.RCP;
   END InsLine;

   PROCEDURE LowVideo*;
   VAR tmpstr : ARRAY 7 OF CHAR;
   BEGIN
      COPY (VT100.CSI, tmpstr);
      Strings.Append(VT100.ResetBold, tmpstr);
      Out.String(tmpstr);
   END LowVideo;

   PROCEDURE NormVideo*;
   VAR tmpstr : ARRAY 7 OF CHAR;
   BEGIN
      COPY(VT100.CSI, tmpstr);
      Strings.Append(VT100.ResetAll, tmpstr);
      Out.String(tmpstr);
   END NormVideo;

   PROCEDURE TextBackground*(color : ARRAY OF CHAR);
   BEGIN
   VT100.SetAttr(color)
   END TextBackground;

   PROCEDURE TextColor*(color : ARRAY OF CHAR);
   BEGIN
   VT100.SetAttr(color)
   END TextColor;

END mnshCrt.
