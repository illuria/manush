MODULE mnshDefs;
IMPORT crt;

CONST
  clrErr*                   = crt.Red;
  clrPrompt*                = crt.Yellow;
  clrHeader*                = crt.LightMagenta;
  clrDecoration*            = crt.Green;
  clrOptNum*                = crt.Blue;
  clrOption*                = crt.Yellow;
  clrOptDesc*               = crt.Blue;
  clrOptCommand*            = crt.Green;
  clrTxtBackground*         = crt.Black;
  clrTxtBackgroundStressed* = crt.DarkGray;
  iniFile* = "/usr/local/etc/manush/default.json";
  cmds* = "Commands";
END mnshDefs.
