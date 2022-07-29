MODULE mnshDefs;
IMPORT mnshCrt;

CONST
  clrErr*                   = mnshCrt.Red;
  clrPrompt*                = mnshCrt.Yellow;
  clrHeader*                = mnshCrt.Cyan;
  clrDecoration*            = mnshCrt.Green;
  clrOptNum*                = mnshCrt.Blue;
  clrOption*                = mnshCrt.Yellow;
  clrOptDesc*               = mnshCrt.Blue;
  clrOptCommand*            = mnshCrt.Green;
  clrTxtBackground*         = mnshCrt.BBlack;
  clrTxtBackgroundStressed* = mnshCrt.BBlack;
  iniFile* = "/usr/local/etc/manush/default.json";
  cmds* = "Commands";
END mnshDefs.
