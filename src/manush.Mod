MODULE manush;

IMPORT Out, Strings, 
       skprJson, strutils, StringList,
       mnshStorage, mnshDefs;

PROCEDURE processConfig(cnf: ARRAY OF CHAR);
VAR
  json : skprJson.JsonTypePointer;
  pstring: strutils.pstring;
  keys, values: StringList.TStringList;
  strs: ARRAY 64 OF skprJson.TString;
  i: LONGINT;
BEGIN
  mnshStorage.fileToString(mnshDefs.iniFile, pstring);
  IF pstring # NIL THEN
    json := skprJson.Create(pstring^);
    Out.String("json terminal number "); Out.Int(json.TerminalNumber, 0); Out.Ln;
    Out.String("json nonterm number "); Out.Int(json.NonTerminalNumber, 0); Out.Ln;
    json.GetNoneTerminalKeys(json, strs);
    i := 0;
    REPEAT
      Out.String(strs[i]); Out.Ln;
      INC(i)
    UNTIL i = json.NonTerminalNumber;
    (*ELSE
      Out.String("config file does not contain '"); Out.String(mnshDefs.cmds); Out.String("' section!"); Out.Ln; Out.String("quitting..."); Out.Ln; HALT(2);
    END*)
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
