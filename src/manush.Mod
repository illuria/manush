MODULE manush;

IMPORT Out, Strings, IntStr := oocIntStr,
       crt, VT100 := vt100, Platform, Args,
       mnshInput, mnshTerm,
       skprJson, strutils, StringList, opts,
       mnshStorage, mnshDefs, mnshList, mnshExtTools;

CONST
  defConf = "/usr/local/etc/manush/default.json";
  verbosityLevel1 = 1;
  verbosityLevel2 = 2;
  verbosityLevel3 = 3;
  
  initX = 3;
  initY = 5;
  offsetX0 = 0;
  offsetX = 6;
  offsetX2 = 6;
  offsetX3 = 40;
  offsetX4 = 29;

  toggleViewKey = 'v';

VAR
  interrupted: BOOLEAN;

PROCEDURE changeVerbosity(VAR v: LONGINT);
BEGIN
  INC(v);
  IF v > verbosityLevel3 THEN v := verbosityLevel1 END
END changeVerbosity;

PROCEDURE processInterrupt(yofquest: INTEGER);
BEGIN
  crt.GotoXY(0, yofquest); crt.TextColor(crt.Red);
  Out.String("interrupt caught.. "); crt.TextColor(crt.Yellow);
  Out.String("ignoring"); Out.Ln;
  interrupted := FALSE
END processInterrupt;


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

PROCEDURE assignZeroOption(VAR ml: mnshList.mList);
VAR
  name, command, comment: StringList.pstring;
BEGIN
  StringList.pstringFromString("Exit", name);
  StringList.pstringFromString("(internal)", command);
  StringList.pstringFromString("Exit This Menu", comment);
  ml.appendNodeByPointers(ml, name, command, comment);
END assignZeroOption;

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
  assignZeroOption(ml);
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
  ch: CHAR;
  i: INTEGER;
BEGIN
  crt.ClrScr;
  crt.cursoroff;
  crt.GotoXY(initX, initY);
  Out.Ln;
  i := Platform.System(cmd^);
  (*crt.cursoron;
  ch := mnshInput.getChar();
  crt.ClrScr;
  crt.GotoXY(initX, initY);*)
  Out.Ln;
  Out.String("exit code of the program: "); Out.Int(i, 0); Out.Ln;
  Out.Ln; Out.String("press ENTER to continue"); 
  Out.Ln;
  mnshTerm.StartV7Mode;
  ch := mnshInput.getChar();
END exec;

PROCEDURE drawMenu(VAR ml: mnshList.mList; v: LONGINT): INTEGER;
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
    Out.String("********************** ");
    crt.TextColor(crt.LightMagenta); Out.String("manush friendly menu");
    crt.TextColor(crt.Green); Out.String(" **********************"); 
    i := 0;
    REPEAT
      (* write option number *)
      crt.GotoXY(initX, y); 
      crt.TextColor(crt.Blue);
      Out.Int(i, 0); Out.Char(':'); 
      (* write option name *)
      pname := mnshList.getName(ml, i);

      crt.GotoXY(offsetX, y); crt.TextColor(crt.Yellow);
      Out.String(pname^); 

      IF v >= verbosityLevel2 THEN
        pcmnt := mnshList.getComment(ml, i);

        crt.GotoXY(offsetX3, y);
        crt.TextBackground(crt.Black); crt.TextColor(crt.Blue);
        Out.String(pcmnt^);
      END;

      IF v = verbosityLevel3 THEN
        pcmd := mnshList.getCommand(ml, i);

        INC(y, 2); 
        crt.GotoXY(offsetX2, y);
        crt.TextBackground(crt.DarkGray); crt.TextColor(crt.Green);
        Out.String(pcmd^)
      END;

      INC(y); 
      INC(i); IF i # ml.Count THEN INC(y) END;
    UNTIL i = ml.Count;
    
    (*INC(y); yofquest := y;
    crt.GotoXY(initX, yofquest); crt.TextColor(crt.Yellow);
    Out.String("enter number:");*)

    INC(y); INC(y);
    crt.GotoXY(offsetX0, y); crt.TextColor(crt.Green);
    Out.String("******************************************************************");
    Out.Ln; Out.Ln;
    
    INC(y); yofquest := y;
    crt.GotoXY(initX, yofquest); crt.TextColor(crt.Yellow);
    Out.String("enter number:");

    crt.TextColor(crt.Blue);
    crt.cursoron;

    yofquest := y;
  RETURN yofquest;
END drawMenu;

PROCEDURE menu*(VAR ml: mnshList.mList; v: LONGINT);
VAR
  yofquest: INTEGER;
  choice: CHAR;
  choiceStr: ARRAY 3 OF CHAR;
  ci: LONGINT; res: IntStr.ConvResults;
  pcmd: StringList.pstring;
BEGIN
  mnshTerm.StartV7Mode;
  REPEAT
    yofquest := drawMenu(ml, v);
    (*crt.GotoXY(initX, yofquest); crt.TextColor(crt.Yellow);*)
    crt.GotoXY(0, yofquest); crt.TextColor(crt.Yellow);
    Out.Ln; 
    Out.String("enter number:");
    REPEAT
     (*crt.GotoXY(offsetX4, yofquest);*)
      crt.GotoXY(0, yofquest);
      choice := mnshInput.getChar();
      IF choice = toggleViewKey THEN
        changeVerbosity(v);
        ci := -1; (* setting it to something other than zero so the loop continues *)
        EXIT
      ELSE
        choiceStr[0] := choice;
        choiceStr[1] := 0X;
        IntStr.StrToInt(choiceStr, ci, res);
        IF (res # IntStr.strAllRight) OR (ci > ml.Count - 1) THEN
          crt.GotoXY(0, yofquest); crt.TextColor(crt.Red);
          Out.String("wrong number.. "); crt.TextColor(crt.Yellow);
          Out.String("enter number:"); Out.Ln;
        END
      END
    UNTIL (res = IntStr.strAllRight) & (ci <= ml.Count -1);
    pcmd := mnshList.getCommand(ml, ci);
    IF ci # 0 THEN exec(pcmd) END
  UNTIL ci = 0;
  VT100.Reset
END menu;

PROCEDURE showHelp;
BEGIN
  Out.String("manush friendly shell"); Out.Ln; Out.Ln;
  Out.String("if no configuration file provided, ");
  Out.String(defConf); Out.String(" will be used."); Out.Ln;
  Out.Ln;
END showHelp;

PROCEDURE main;
VAR
    options  : opts.Options;
    foptions : opts.Options;
         opt : opts.Option;
        opt2 : opts.Option;
    verbosityLevel: LONGINT;
         res : SHORTINT;
        
 
          ml : mnshList.mList;
        json : ARRAY 512 OF CHAR;
          st : INTEGER;
BEGIN
  options  := opts.createOptions();
  foptions := opts.createOptions();

  opt      := opts.createOpt();
  opts.setOptName(opt, "-c");
  opts.setOptHasVal(opt, TRUE);
  opts.setOptRequired(opt, FALSE);
  opts.setOptLName(opt, "--config");
  opts.setOptDesc(opt, "configuration file");

  options.add(options, opt);

  opt     := opts.createOpt();
  opts.setOptName(opt, "-v");
  opts.setOptHasVal(opt, TRUE);
  opts.setOptRequired(opt, FALSE);
  opts.setOptLName(opt, "--verbose");
  opts.setOptDesc(opt, "verbosity level in range 1..3: only name, name and comment, name, comment and the command.");

  options.add(options, opt);

  opt     := opts.createOpt();
  opts.setOptName(opt, "-h");
  opts.setOptHasVal(opt, FALSE);
  opts.setOptRequired(opt, FALSE);
  opts.setOptLName(opt, "--help");
  opts.setOptDesc(opt, "show this help message");

  options.add(options, opt);

  foptions := opts.populateOptions(options);
  (* this we don't need because we don't have required options 
  IF opts.reqsSatisfied(options, foptions) THEN
    Out.String("required options provided"); Out.Ln;
  ELSE
    Out.String("required options not provided"); Out.Ln;
    showHelp;
    opts.showHelp(options);
    HALT(3);
  END; *)

  verbosityLevel := verbosityLevel2;

  IF foptions # NIL THEN
    IF opts.findOpt("-h", foptions) # NIL THEN
        showHelp;
        opts.showHelp(options);
        HALT(0)
    END;
   
    opt2 := opts.findOpt("-v", foptions);
    IF opt2 # NIL THEN
      IF opt2.val # NIL THEN
        IntStr.StrToInt(opt2.val^, verbosityLevel, res);
        IF res = IntStr.strAllRight THEN
          IF verbosityLevel <= verbosityLevel1 THEN verbosityLevel := verbosityLevel1
          ELSIF verbosityLevel >= verbosityLevel3 THEN verbosityLevel := verbosityLevel3
          END
        ELSE
          Out.String("Error: verbosity level should be a number in a range of 1..3"); Out.Ln;
          HALT(2);
        END;
      END;
    END;

    IF opts.findOpt("-c", foptions) = NIL THEN
      Out.Ln;
      Out.String("No configuration file provided, trying "); Out.String(defConf); Out.Ln;
      COPY(defConf, json)
    ELSE
      (*ml := json2tree(mnshDefs.iniFile);*)
      opts.valOfOpt("-c", foptions, json);
    END;
  ELSE (* if foptions = NIL *)
    COPY(defConf, json)
  END;

    IF ~mnshStorage.exists(json) THEN
      Out.String(json); Out.String(" is not found!"); Out.Ln;
      HALT(3);
    ELSE
      st := mnshExtTools.check(json);
      IF st # 0 THEN
        Out.String(json); Out.String(" is not valid, correct it!"); Out.Ln;
        HALT(2);
      ELSE
        ml := json2tree(json);
        menu(ml, verbosityLevel)
      END
    END
END main;

PROCEDURE interrupt(i: LONGINT);
BEGIN
  interrupted := TRUE;
END interrupt;

BEGIN
  interrupted := FALSE;
  Platform.SetInterruptHandler(interrupt);
  main;


END manush.
