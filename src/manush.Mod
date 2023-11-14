MODULE manush;

IMPORT Out, Strings, IntStr := oocIntStr,
       mnshCrt, Platform,
       mnshInput, mnshTerm,
       skprJson, strUtils, StringList, opts, pipes,
       mnshStorage, mnshDefs, mnshList, mnshExtTools, mnshUnix;

CONST
  defConf = mnshDefs.iniFile;
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

  msgWrongNumber = "wrong number... ";
  msgEnterNumber = "enter number:   ";
  msgConfigFile  = "config file ";
  msgNotFound    = " not found!";
  msgQuitting    = "quitting...";
  msgNoConfProvided = "No configuration file provided, trying ";
  msgNotValid    = " not valid, correct it!";

  toggleViewKey = 'v';

VAR
  interrupted, wrong: BOOLEAN;

PROCEDURE changeVerbosity(VAR v: LONGINT);
BEGIN
  INC(v);
  IF v > verbosityLevel3 THEN v := verbosityLevel1 END
END changeVerbosity;

PROCEDURE processInterrupt(yofquest: INTEGER);
BEGIN
  mnshCrt.GotoXY(0, yofquest); mnshCrt.TextColor(mnshDefs.clrErr);
  Out.String("interrupt caught.. "); mnshCrt.TextColor(mnshDefs.clrPrompt);
  Out.String("ignoring"); Out.Ln;
  interrupted := FALSE
END processInterrupt;

PROCEDURE AssignValues(VAR keys, values: StringList.TStringList; VAR ml: mnshList.mList);
VAR
  ek, ev: StringList.Node;
  i: INTEGER;
  VAR name, exec, comment, exitstatus: StringList.pstring;
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
    IF Strings.Match(ek.obj(StringList.TString).str^, mnshList.exitStatusField) THEN
      exitstatus := ev.obj(StringList.TString).str;
    Out.Int(i, 0); Out.String(" found exitstatus: "); Out.String(exitstatus^); Out.Ln;
    END;
INC(i);
  UNTIL i = keys.Count - 1;
  (*ml.appendNode(ml, name^, exec^, comment^);*)
  ml.appendNodeByPointers(ml, name, exec, comment, exitstatus);
END AssignValues;

PROCEDURE assignZeroOption(VAR ml: mnshList.mList);
VAR
  name, command, comment, exitstatus: StringList.pstring;
  pid, ppid: LONGINT;
  parent : ARRAY 32 OF CHAR;
  l: LONGINT;
BEGIN
  pid := mnshUnix.getPPid();
    Out.String("ppid="); Out.Int(pid, 0); Out.Ln;
  (*ppid := mnshExtTools.getPPIDbyPID(pid);
    Out.String("ppid="); Out.Int(ppid, 0); Out.Ln;*)
  l := mnshExtTools.getNameByPID(pid, parent); 
  Out.String("parent="); Out.String(parent); Out.Ln;
  strUtils.dumpChars(parent); Out.Ln;
  IF l # 0 THEN
    Out.String("popen() failed, hmmm..."); Out.Ln;
    Out.String("but it is still possible to continue..."); Out.Ln;
    Out.String("waiting 5 secs to make you notice the warning..."); Out.Ln;
    HALT(5);
  ELSE
    IF strUtils.contains1(parent, "manush") THEN
      Out.String("assigning baaack"); Out.Ln;
      StringList.pstringFromString("Back", name);
      StringList.pstringFromString("Back to previous menu", comment);
    ELSE
      Out.String("assigning exit"); Out.Ln;
      StringList.pstringFromString("Exit", name);
      StringList.pstringFromString("Exit this menu", comment);
    END;
  END;
  StringList.pstringFromString("(internal)", command);
  StringList.pstringFromString("false", exitstatus);
  ml.appendNodeByPointers(ml, name, command, comment, exitstatus);
END assignZeroOption;

PROCEDURE json2tree(VAR cnf: ARRAY OF CHAR): mnshList.mList;
VAR
  json, item : skprJson.JsonTypePointer;
  p: strUtils.pstring;
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
    Out.String(msgConfigFile); Out.String(cnf); Out.String(msgNotFound); Out.Ln; Out.String(msgQuitting); Out.Ln; HALT(1);
  END;
  RETURN ml;
END json2tree;

PROCEDURE smth(jFileName: ARRAY OF CHAR; VAR ml: mnshList.mList);
VAR
  p: strUtils.pstring;
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

PROCEDURE showExitStatus(VAR ml: mnshList.mList; ci: LONGINT): BOOLEAN;
VAR
  whitespace: CHAR;
  est, pcmd : StringList.pstring;
  tmp : strUtils.pstring;
  b, show : BOOLEAN;
BEGIN
  whitespace := 20X;
  est  := mnshList.getExitStatus(ml, ci);
  show := TRUE;
  IF (est # NIL) & (est^ = "false") THEN show := FALSE END;
 
  pcmd := mnshList.getCommand(ml, ci);
  tmp := strUtils.ExtractWord(1, pcmd^, whitespace);
  IF tmp # NIL THEN
    (*IF tmp^ = "manush" THEN show := FALSE END;*)
    IF strUtils.contains1(tmp^, "manush") THEN show := FALSE END
  END;
  RETURN show
END showExitStatus;

PROCEDURE exec(VAR ml: mnshList.mList; ci: LONGINT);
VAR
  ch: CHAR;
  i: LONGINT;
  pcmd : StringList.pstring;
  est  : StringList.pstring;
  args : StringList.pstrings;
  show : BOOLEAN;
  (*ptxt : pipes.Text;*)
BEGIN
  pcmd := mnshList.getCommand(ml, ci);
  mnshTerm.StopV7Mode;
  mnshCrt.Reset;
  mnshCrt.ClrScr;
  mnshCrt.GotoXY(initX, initY);
  Out.Ln;
  i := Platform.System(pcmd^);

(* comment shows how to do the same with popen 
  ch := 'r'; ptxt := pipes.Popen(pcmd^, ch);
  WHILE ~ ptxt.eof DO
    pipes.Read(ptxt, ch);
  END;
  i := pipes.Pclose (ptxt);
*)
(* comment shows how to do the same with fork
   but not recommended, because forked process has no stdin/terminal
  i := mnshUnix.Fork();
  IF i < 0 THEN
    Out.String("error on fork()"); Out.Ln;
    HALT(1);
  ELSIF i = 0 THEN
    Out.String("forked ok, i am the child"); Out.Ln;
    args := strUtils.tokenize(pcmd^, ' ');
    i := mnshUnix.Execvp(args[0]^, args)
  ELSE
    mnshUnix.waitPID(i);
    IF showExitStatus(ml, ci) THEN
      Out.Ln;
      Out.String("exit code of the program: "); Out.Int(i, 0); Out.Ln;
      Out.Ln; Out.String("press ENTER to continue"); 
      Out.Ln;

      mnshTerm.StartV7Mode;
      ch := mnshInput.getChar();
    END
  END;
*)
  IF showExitStatus(ml, ci) THEN
    Out.Ln;
    Out.String("exit code of the program: "); Out.Int(i, 0); Out.Ln;
    Out.Ln; Out.String("press ENTER to continue"); 
    Out.Ln;
    mnshTerm.StartV7Mode;
    ch := mnshInput.getChar();
  END
END exec;

PROCEDURE drawMenu(VAR ml: mnshList.mList; v: LONGINT): INTEGER;
VAR
  i: LONGINT;
  pname, pcmd, pcmnt, pestatus: StringList.pstring;
  x, y, xofquest, yofquest: INTEGER;
BEGIN
    x := initX; y := initY;
    mnshCrt.TextBackground(mnshDefs.clrTxtBackground);
    mnshCrt.ClrScr; mnshCrt.cursoroff;
    mnshCrt.GotoXY(x,0);
    mnshCrt.TextColor(mnshDefs.clrDecoration);
    Out.Ln; Out.Ln;
    Out.String("********************** ");
    mnshCrt.TextColor(mnshDefs.clrHeader); Out.String("manush friendly menu");
    mnshCrt.TextColor(mnshDefs.clrDecoration); Out.String(" **********************"); 
    i := 0;
    REPEAT
      (* write option number *)
      mnshCrt.GotoXY(initX, y); 
      mnshCrt.TextColor(mnshDefs.clrOptNum);
      Out.Int(i, 0); Out.Char(':'); 
      (* write option name *)
      pname := mnshList.getName(ml, i);
      mnshCrt.GotoXY(offsetX, y); mnshCrt.TextColor(mnshDefs.clrOption);
      Out.String(pname^); 

      (*pestatus := mnshList.getExitStatus(ml, i);*)

      IF v >= verbosityLevel2 THEN
        pcmnt := mnshList.getComment(ml, i);

        mnshCrt.GotoXY(offsetX3, y);
        mnshCrt.TextBackground(mnshDefs.clrTxtBackground); mnshCrt.TextColor(mnshDefs.clrOptDesc);
        Out.String(pcmnt^);
      END;

      IF v = verbosityLevel3 THEN
        pcmd := mnshList.getCommand(ml, i);

        INC(y, 2); 
        mnshCrt.GotoXY(offsetX2, y);
        mnshCrt.TextBackground(mnshDefs.clrTxtBackgroundStressed); mnshCrt.TextColor(mnshDefs.clrOptCommand);
        Out.String(pcmd^);
        mnshCrt.TextBackground(mnshDefs.clrTxtBackground) 
      END;

      INC(y); 
      INC(i); IF i # ml.Count THEN INC(y) END;
    UNTIL i = ml.Count;
    
    (*INC(y); yofquest := y;
    mnshCrt.GotoXY(initX, yofquest); mnshCrt.TextColor(mnshDefs.clrPrompt);
    Out.String("enter number:");*)

    INC(y); INC(y);
    mnshCrt.GotoXY(offsetX0, y); mnshCrt.TextColor(mnshDefs.clrDecoration);
    Out.String("******************************************************************");
    Out.Ln; Out.Ln;
    
    INC(y); yofquest := y;
    mnshCrt.GotoXY(initX, yofquest); mnshCrt.TextColor(mnshDefs.clrPrompt);
    Out.String("enter number:");

    mnshCrt.TextColor(mnshDefs.clrOptDesc);
    mnshCrt.cursoron;

    yofquest := y;
  RETURN yofquest;
END drawMenu;

PROCEDURE ask(err: BOOLEAN; y: INTEGER);
BEGIN
  mnshCrt.GotoXY(0, y);
  IF err THEN
    mnshCrt.TextColor(mnshDefs.clrErr);
    Out.String(msgWrongNumber); mnshTerm.StartV7Mode;
    wrong := TRUE;
    mnshCrt.GotoXY(Strings.Length(msgWrongNumber)+2, y);
  END;
  mnshCrt.TextColor(mnshDefs.clrPrompt);
  Out.String(msgEnterNumber); Out.Ln;
  mnshTerm.StartV7Mode;
  mnshCrt.cursoroff
END ask;

PROCEDURE menu*(VAR ml: mnshList.mList; v: LONGINT);
VAR
  yofquest: INTEGER;
  choice: CHAR;
  choiceStr: ARRAY 3 OF CHAR;
  ci: LONGINT; res: IntStr.ConvResults;
  exitLoop: BOOLEAN;

  PROCEDURE checkInterrupted;    
  BEGIN  
    IF interrupted THEN
      yofquest := drawMenu(ml, v);
      processInterrupt(yofquest)
    END
  END checkInterrupted;

BEGIN
  wrong := FALSE;
  REPEAT
    yofquest := drawMenu(ml, v);
    ask(wrong, yofquest);
    REPEAT
      mnshTerm.StartV7Mode;
      wrong := FALSE;
      exitLoop := TRUE;
     (*mnshCrt.GotoXY(offsetX4, yofquest);*)
      mnshCrt.GotoXY(0, yofquest);
      mnshTerm.StartV7Mode;
      choice := mnshInput.getChar();
      mnshTerm.StartV7Mode;
      IF choice = toggleViewKey THEN
        changeVerbosity(v);
        yofquest := drawMenu(ml, v);
        ask(wrong, yofquest);
        exitLoop := FALSE
      ELSE
        choiceStr[0] := choice;
        choiceStr[1] := 0X;
        IntStr.StrToInt(choiceStr, ci, res);
        IF (res # IntStr.strAllRight) OR (ci > ml.Count - 1) THEN
          exitLoop := FALSE; wrong := TRUE; yofquest := drawMenu(ml, v); ask(wrong, yofquest)
        ELSE
          wrong := FALSE;
          exitLoop := TRUE
        END
      END;
    UNTIL exitLoop & (res = IntStr.strAllRight) & (ci <= ml.Count -1);
    IF ci # 0 THEN exec(ml, ci) END
  UNTIL ci = 0;
  mnshCrt.Reset
END menu;

PROCEDURE showHelp;
BEGIN
  Out.String("manush friendly shell"); Out.Ln; Out.Ln;
  Out.String("if no configuration file provided, ");
  Out.String(defConf); Out.String(" will be used."); Out.Ln;
  Out.Ln;
  Out.String("press 'v' to toggle verbosity level"); Out.Ln;
  Out.Ln
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
      Out.String(msgNoConfProvided); Out.String(defConf); Out.Ln;
      COPY(defConf, json)
    ELSE
      (*ml := json2tree(mnshDefs.iniFile);*)
      opts.valOfOpt("-c", foptions, json);
    END;
  ELSE (* if foptions = NIL *)
    COPY(defConf, json)
  END;

    IF ~mnshStorage.exists(json) THEN
      Out.String(json); Out.String(msgNotFound); Out.Ln;
      HALT(3);
    ELSE
      st := mnshExtTools.check(json);
      IF st # 0 THEN
        Out.String(json); Out.String(msgNotValid); Out.Ln;
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
  mnshTerm.StopV7Mode;

END manush.
