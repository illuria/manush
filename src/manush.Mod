MODULE manush;

IMPORT Out, Strings, 
       skprJson, strutils, StringList,
       mnshStorage, mnshDefs, mnshList;

PROCEDURE AssignValues(VAR keys, values: StringList.TStringList; VAR ml: mnshList.mList);
VAR
  ek, ev: StringList.Node;
  i: INTEGER;
  VAR name, exec, comment: StringList.pstring;
BEGIN
i := 0;
  REPEAT
    ek := keys.Get(keys, i);
    ev := values.Get(values, i);
    IF Strings.Match(ek.obj(StringList.TString).str^, mnshList.nameField) THEN
      (*name := ev.obj(StringList.TString).str*)
      name := values.GetString(values, i);
    Out.Int(i, 0); Out.String(" found name: "); Out.String(name^); Out.Ln;
    END;
    IF Strings.Match(ek.obj(StringList.TString).str^, mnshList.execField) THEN
      exec := ev.obj(StringList.TString).str;
    Out.Int(i, 0); Out.String(" found command: "); Out.String(exec^); Out.Ln;
    END;
    IF Strings.Match(ek.obj(StringList.TString).str^, mnshList.cmntField) THEN
      comment := ev.obj(StringList.TString).str;
    Out.Int(i, 0); Out.String(" found comment: "); Out.String(comment^); Out.Ln;
    END;
    INC(i);
  UNTIL i = keys.Count - 1;
  (*ml.appendNode(ml, name^, exec^, comment^);*)
  ml.appendNodeByPointers(ml, name, exec, comment);
END AssignValues;

PROCEDURE json2tree(cnf: ARRAY OF CHAR): mnshList.mList;
VAR
  json, item : skprJson.JsonTypePointer;
  p: strutils.pstring;
  keys, values: StringList.TStringList;
  strs: POINTER TO ARRAY OF skprJson.TString;
  ml: mnshList.mList;
  i: LONGINT;
BEGIN
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
      item := json.GetNonTerminal(json, strs[i]);
      IF item # NIL THEN
        keys := NIL; values := NIL;
        item.GetTerminalKeys(item, keys);
        item.GetTerminalValues(item, values);
        AssignValues(keys, values, ml);
      ELSE
        Out.String("we know there should be section ");
        Out.String(strs[0]); Out.String("... this is strange"); Out.Ln;
        HALT(1);
      END;
      INC(i)
    UNTIL i = json.NonTerminalNumber;
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
  name : StringList.pstring;
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

PROCEDURE showMenu*(VAR ml: mnshList.mList);
VAR
  i: LONGINT;
  p: StringList.pstring;
BEGIN
  Out.String("********* manush friendly menu *********");
  i := 0;
  REPEAT
    Out.Int(i, 0); Out.Ln;
    p := mnshList.getName(ml, i);
    Out.String(p^); Out.Ln;
    p := mnshList.getCommand(ml, i);
    Out.String(p^); Out.Ln;
    p := mnshList.getComment(ml, i);
    Out.String(p^); Out.Ln;
    INC(i);
  UNTIL i = ml.Count;
END showMenu;


PROCEDURE main;
VAR
 ml: mnshList.mList;
BEGIN
  ml := json2tree(mnshDefs.iniFile);
  (*smth(mnshDefs.iniFile, ml);*)
  showMenu(ml);
END main;

BEGIN

main;


END manush.
