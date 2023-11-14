MODULE mnshList; (* noch 2022-01 / 2022-02-17  list to keep menu options *)



IMPORT Out, Strings, List, StringList;

CONST
  nameField* = "name";
  execField* = "exec";
  cmntField* = "cmnt";
  exitStatusField* = "exitstatus";

TYPE
  mNode* = POINTER TO mNodeDesc;
  mNodeDesc = RECORD(List.TObjectDesc)
       name, exec, comment, exitstatus : StringList.pstring;
  END;

  mList* = POINTER TO mListDesc;
  mListDesc = RECORD (List.TListDesc)
    addNode* : PROCEDURE (VAR l: mList; VAR name, exec, comment, exitstatus: ARRAY OF CHAR): LONGINT;
    appendNode*: PROCEDURE (VAR l: mList; VAR name, exec, comment, exitstatus: ARRAY OF CHAR);
    appendNodeByPointers*: PROCEDURE (VAR l: mList; VAR name, exec, comment, exitstatus: StringList.pstring);
  getName*:  PROCEDURE(VAR l: mList; i: LONGINT): StringList.pstring;
    getCommand*:  PROCEDURE(VAR l: mList; i: LONGINT): StringList.pstring;
    getComment*:  PROCEDURE(VAR l: mList; i: LONGINT): StringList.pstring;
    getExitStatus*:  PROCEDURE(VAR l: mList; i: LONGINT): StringList.pstring;
    END;

  PROCEDURE addNode*(VAR l: mList; VAR name, exec, comment, exitstatus: ARRAY OF CHAR): LONGINT;
  VAR
    mn: mNode;
    i:  LONGINT;
  BEGIN
    NEW(mn);
    NEW(mn.name, Strings.Length(name)+1);
    NEW(mn.exec, Strings.Length(exec)+1);
    NEW(mn.comment, Strings.Length(comment)+1);
    NEW(mn.exitstatus, Strings.Length(exitstatus)+1);
    COPY(name, mn^.name^);
    COPY(exec, mn^.exec^);
    COPY(comment, mn^.comment^);
    COPY(exitstatus, mn^.exitstatus^);
    i := List.Add(l, mn);
    RETURN i
  END addNode;

  PROCEDURE appendNode*(VAR l: mList; VAR name, exec, comment, exitstatus: ARRAY OF CHAR);
  VAR
    mn: mNode;
  BEGIN
    NEW(mn);
    NEW(mn.name, Strings.Length(name)+1);
    NEW(mn.exec, Strings.Length(exec)+1);
    NEW(mn.comment, Strings.Length(comment)+1);
    NEW(mn.exitstatus, Strings.Length(exitstatus)+1);
    COPY(name, mn^.name^);
    COPY(exec, mn^.exec^);
    COPY(comment, mn^.comment^);
    COPY(exitstatus, mn^.exitstatus^);
    List.Append(l, mn);
  END appendNode;

  PROCEDURE appendNodeByPointers*(VAR l: mList; VAR name, exec, comment, exitstatus: StringList.pstring);
  VAR
    mn: mNode;
  BEGIN
    NEW(mn);
    mn.name := name;
    mn.exec := exec;
    mn.comment := comment;
    mn.exitstatus := exitstatus;
    List.Append(l, mn);
  END appendNodeByPointers;

  PROCEDURE getName*(VAR l: mList; i: LONGINT): StringList.pstring;
  VAR
    e: List.Node;
    p: StringList.pstring;
  BEGIN
    e := List.Get(l, i);
    p := e.obj(mNode).name;
    RETURN p;
  END getName;

  PROCEDURE getCommand*(VAR l: mList; i: LONGINT): StringList.pstring;
  VAR
    e: List.Node;
    p: StringList.pstring;
  BEGIN
    e := List.Get(l, i);
    p := e.obj(mNode).exec;
    RETURN p
  END getCommand;

  PROCEDURE getComment*(VAR l: mList; i: LONGINT): StringList.pstring;
  VAR
    e: List.Node;
    p: StringList.pstring;
  BEGIN
    e := List.Get(l, i);
    p := e.obj(mNode).comment;
    RETURN p;
  END getComment;

  PROCEDURE getExitStatus*(VAR l: mList; i: LONGINT): StringList.pstring;
  VAR
    e: List.Node;
    p: StringList.pstring;
  BEGIN
    e := List.Get(l, i);
    p := e.obj(mNode).exitstatus;
    RETURN p;
  END getExitStatus;

  PROCEDURE create*(): mList;
  VAR
    m: mList;
  BEGIN
    NEW(m);
    m.addNode := addNode;
    m.appendNode := appendNode;
    m.appendNodeByPointers := appendNodeByPointers;
    m.getName := getName;
    m.getCommand := getCommand;
    m.getComment := getComment;
    m.getExitStatus := getExitStatus;
    RETURN m
  END create;

END mnshList.
