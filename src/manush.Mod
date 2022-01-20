MODULE manush;

IMPORT Out, Strings, 
       skprJson, strutils, StringList,
       mnshStorage, mnshDefs;

PROCEDURE processConfig(cnf: ARRAY OF CHAR);
VAR
  json, cmds : skprJson.JsonTypePointer;
  pstring: strutils.pstring;
  cmdList, keys, values: StringList.TStringList;
BEGIN
  mnshStorage.fileToString(mnshDefs.iniFile, pstring);
  IF pstring # NIL THEN
    json := skprJson.Create(pstring^);
    cmds := json.GetNonTerminal(json, mnshDefs.cmds);
    IF cmds # NIL THEN
      cmds.GetTerminalKeys(cmds, cmdList);
      StringList.list(cmdList);
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
