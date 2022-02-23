MODULE manush;

IMPORT Out, Strings, oocIntStr, ulmIO, crt, Platform, Args,
       skprJson, strutils, StringList,
       mnshStorage, mnshDefs, mnshList;

CONST
  initX = 3;
  initY = 5;
  offsetX0 = 0;
  offsetX = 6;
  offsetX2 = 6;
  offsetX3 = 20;
  offsetX4 = 29;

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

PROCEDURE json2tree(VAR cnf: ARRAY OF CHAR): mnshList.mList;
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
  mnshStorage.fileToString(cnf, p);
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
    Out.String("config file "); Out.String(cnf); Out.String(" not found!"); Out.Ln; Out.String("quitting..."); Out.Ln; HALT(1);
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

PROCEDURE showMenuOld*(VAR ml: mnshList.mList);
VAR
  i: LONGINT;
  p: StringList.pstring;
BEGIN
  Out.String("********* manush friendly menu *********"); Out.Ln;
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
END showMenuOld; (* incomplete *)

PROCEDURE exec(VAR cmd: StringList.pstring);
VAR
  s: ARRAY 3 OF CHAR;
  i: INTEGER;
BEGIN
  i := Platform.System(cmd^);
  Out.String("exit code of the program: "); Out.Int(i, 0); Out.Ln;
  Out.Ln; Out.String("press ENTER to continue"); 
  ulmIO.ReadLine(s);
END exec;

PROCEDURE drawMenu(VAR ml: mnshList.mList): INTEGER;
VAR
  i: LONGINT;
  pname, pcmd, pcmnt: StringList.pstring;
  x, y, xofquest, yofquest: INTEGER;
BEGIN
    x := initX; y := initY;
    crt.ClrScr; crt.cursoroff;
    crt.GotoXY(x,0);
    crt.TextColor(crt.Green);
    Out.Ln; Out.Ln;
    Out.String("************ ");
    crt.TextColor(crt.LightMagenta); Out.String("manush friendly menu");
    crt.TextColor(crt.Green); Out.String(" ************"); 
    i := 0;
    REPEAT
      crt.GotoXY(3, y); 
      crt.TextColor(crt.Blue);
      Out.Int(i, 0); Out.Char(':'); 

      pname := mnshList.getName(ml, i);

      crt.GotoXY(offsetX, y); crt.TextColor(crt.Yellow);
      Out.String(pname^); 

      pcmd := mnshList.getCommand(ml, i);

      INC(y, 2); crt.GotoXY(offsetX2, y);
      crt.TextBackground(crt.DarkGray); crt.TextColor(crt.Green);
      Out.String(pcmd^);

      pcmnt := mnshList.getComment(ml, i);

      crt.GotoXY(offsetX3, y);
      crt.TextBackground(crt.Black); crt.TextColor(crt.Blue);
      Out.String(pcmnt^);
      INC(y); 
      INC(i); IF i # ml.Count THEN INC(y) END;
    UNTIL i = ml.Count;
    
    INC(y); yofquest := y;
    crt.GotoXY(initX, yofquest); crt.TextColor(crt.Yellow);
    Out.String("enter number:");

    INC(y); INC(y);
    crt.GotoXY(offsetX0, y); crt.TextColor(crt.Green);
    Out.String("**********************************************");
    Out.Ln; Out.Ln;
    crt.TextColor(crt.Blue);
    crt.cursoron;
  RETURN yofquest;
END drawMenu;


PROCEDURE menu*(VAR ml: mnshList.mList);
VAR
  yofquest: INTEGER;
  choice: ARRAY 8 OF CHAR;
  ci: LONGINT; res: oocIntStr.ConvResults;
  pcmd: StringList.pstring;
BEGIN
  WHILE TRUE DO
    yofquest := drawMenu(ml);
    crt.GotoXY(initX, yofquest); crt.TextColor(crt.Yellow);
    Out.String("enter number:");
    REPEAT
      crt.GotoXY(offsetX4, yofquest - 1);
      ulmIO.ReadLine(choice);
      oocIntStr.StrToInt(choice, ci, res);
      IF (res # oocIntStr.strAllRight) OR (ci > ml.Count - 1) THEN
        crt.GotoXY(0, yofquest); crt.TextColor(crt.Red);
        Out.String("wrong number.. "); crt.TextColor(crt.Yellow);
        Out.String("enter number:"); Out.Ln;
      END;
    UNTIL (res = oocIntStr.strAllRight) & (ci <= ml.Count -1);
    pcmd := mnshList.getCommand(ml, ci);
    exec(pcmd);
  END  
END menu;

PROCEDURE showHelp;
BEGIN
  Out.String("manush friendly shell"); Out.Ln; Out.Ln;
  Out.String("expects exactly one commandline argument,"); Out.Ln;
  Out.String("which contains menu description in json format"); Out.Ln;
  Out.Ln;
  Out.String("usage:"); Out.Ln;
  Out.String("  manush config.json"); Out.Ln;
  Out.Ln;
END showHelp;

PROCEDURE main;
VAR
 ml: mnshList.mList;
 json: ARRAY 128 OF CHAR;
BEGIN
  IF Args.argc # 2 THEN
    showHelp;
  ELSE
    (*ml := json2tree(mnshDefs.iniFile);*)
    Args.Get(1, json);
    ml := json2tree(json);
    menu(ml)
  END
END main;

BEGIN

main;


END manush.
