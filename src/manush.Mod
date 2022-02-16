MODULE manush;

IMPORT Out, Strings, 
       skprJson, strutils, StringList,
       mnshStorage, mnshDefs, mnshList;

PROCEDURE json2tree(cnf: ARRAY OF CHAR): mnshList.mList;
VAR
  json, item : skprJson.JsonTypePointer;
  p: strutils.pstring;
  keys, values: StringList.TStringList;
  lst: mnshList.mList;
  strs: POINTER TO ARRAY OF skprJson.TString;
  ml: mnshList.mList;
  i: LONGINT;
  (*tmp?*)
  str0, str1: ARRAY 16 OF CHAR;
BEGIN
  COPY("", str0); COPY("", str1);
  ml := mnshList.create();
  p := NIL;
  mnshStorage.fileToString(mnshDefs.iniFile, p);
  IF p # NIL THEN
    json := skprJson.Create(p^);
    Out.String("json terminal number "); Out.Int(json.TerminalNumber, 0); Out.Ln;
    Out.String("json nonterm number "); Out.Int(json.NonTerminalNumber, 0); Out.Ln;
    NEW(strs, json.NonTerminalNumber);
    json.GetNoneTerminalKeys(json, strs^);
    i := 0;
    REPEAT
      Out.String("strs["); Out.Int(i, 0); Out.String("]=");
      Out.String(strs[i]); Out.Ln;
      ml.appendNode(ml, strs[i], str0, str1);
      INC(i)
    UNTIL i = json.NonTerminalNumber;
    (*  item := json.GetNonTerminal(json, strs[0]);
      IF item # NIL THEN
        item.GetTerminalKeys(item, keys);
        Out.String("*------");Out.Ln;
        StringList.list(keys);
        Out.String("------*");Out.Ln;
        item.GetTerminalValues(item, values);
      ELSE
        Out.String("this cannot happen. memory corruption?"); Out.Ln;
      END;*)
  ELSE
    Out.String("config file "); Out.String(mnshDefs.iniFile); Out.String(" not found!"); Out.Ln; Out.String("quitting..."); Out.Ln; HALT(1);
  END;
  RETURN ml;
END json2tree;

PROCEDURE smth(jFileName: ARRAY OF CHAR; VAR ml: mnshList.mList);
VAR
  p: strutils.pstring;
  jsonRecord, item: skprJson.JsonTypePointer;
  keys, values: StringList.TStringList;
  b: BOOLEAN;
  name : strutils.pstring;
BEGIN
  b := FALSE;
  p := NIL;
  mnshStorage.fileToString(jFileName, p);
  IF p # NIL THEN
    jsonRecord := skprJson.Create(p^);
    name := ml.getName(ml, 0); Out.String("name="); Out.String(name^); Out.Ln;
    item := jsonRecord.GetNonTerminal(jsonRecord, name^);
    IF item # NIL THEN
      keys := NIL; values := NIL;
      item.GetTerminalKeys(item, keys);
      item.GetTerminalValues(item, values);
      Out.String("keys count: "); Out.Int(keys.Count, 0); Out.Ln;
      Out.String("values count: "); Out.Int(values.Count, 0); Out.Ln;
      Out.String("listing keys"); Out.Ln; StringList.list(keys);
      Out.String("listing values"); Out.Ln; StringList.list(values);
    ELSE
      Out.String(name^); Out.String(" section not found in json file"); Out.Ln; HALT(1);
    END;
  ELSE
    Out.String("could not open file"); Out.Ln;
    HALT(1);
  END
END smth;


PROCEDURE main;
VAR
 ml: mnshList.mList;
BEGIN
  ml := json2tree(mnshDefs.iniFile);
  smth(mnshDefs.iniFile, ml);
END main;

BEGIN

main;


END manush.
