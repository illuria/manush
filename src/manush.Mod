MODULE manush;

IMPORT Out, Strings, 
       skprJson, strutils,
       mnshStorage, mnshDefs;

PROCEDURE processConfig(cnf: ARRAY OF CHAR);
VAR
  json, cmds, cmd0: skprJson.JsonTypePointer;
  pstring: strutils.pstring;
BEGIN
  mnshStorage.fileToString(mnshDefs.iniFile, pstring);
  IF pstring # NIL THEN
    json := skprJson.Create(pstring^);
    cmds := json.GetNonTerminal(json, mnshDefs.cmds);
    IF cmds # NIL THEN
      Out.String("commands found"); Out.Ln;
    ELSE
      Out.String("config file does not contain '"); Out.String(mnshDefs.cmds); Out.String("' section!"); Out.Ln; Out.String("quitting..."); Out.Ln; HALT(2);
    END;
  ELSE
    Out.String("config file "); Out.String(mnshDefs.iniFile); Out.String(" not found!"); Out.Ln; Out.String("quitting..."); Out.Ln; HALT(1);
  END;
END processConfig;


PROCEDURE main;

BEGIN

  processConfig(mnshDefs.iniFile);
END main;

BEGIN

main;


END manush.
