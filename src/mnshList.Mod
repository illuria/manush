MODULE mnshList;

IMPORT Out, Strings, List, lDefs, strutils;

TYPE
  mNode* = POINTER TO mNodeDesc;
  mNodeDesc = RECORD(lDefs.TObjectDesc)
       name, exec, comment : strutils.pstring;
  END;

  mList* = POINTER TO mListDesc;
  mListDesc = RECORD (List.TListDesc)
    addNode* : PROCEDURE (VAR l: mList; VAR name, exec, comment: ARRAY OF CHAR): LONGINT;
    appendNode*: PROCEDURE (VAR l: mList; VAR name, exec, comment: ARRAY OF CHAR);
    getName*:  PROCEDURE(l: mList; i: LONGINT): strutils.pstring;
  END;

  PROCEDURE addNode*(VAR l: mList; VAR name, exec, comment: ARRAY OF CHAR): LONGINT;
  VAR
    mn: mNode;
    i:  LONGINT;
  BEGIN
    NEW(mn);
    NEW(mn.name, Strings.Length(name)+1);
    NEW(mn.exec, Strings.Length(exec)+1);
    NEW(mn.comment, Strings.Length(comment)+1);
    COPY(name, mn^.name^);
    COPY(exec, mn^.exec^);
    COPY(comment, mn^.comment^);
    i := List.Add(l, mn);
    RETURN i
  END addNode;

  PROCEDURE appendNode*(VAR l: mList; VAR name, exec, comment: ARRAY OF CHAR);
  VAR
    mn: mNode;
  BEGIN
    NEW(mn);
    NEW(mn.name, Strings.Length(name)+1);
    NEW(mn.exec, Strings.Length(exec)+1);
    NEW(mn.comment, Strings.Length(comment)+1);
    COPY(name, mn^.name^);
    COPY(exec, mn^.exec^);
    COPY(comment, mn^.comment^);
    List.Append(l, mn);
  END appendNode;

  PROCEDURE getName*(l: mList; i: LONGINT): strutils.pstring;
  VAR
    e: List.Node;
    p: strutils.pstring;
  BEGIN
    e := List.Get(l, i);
    p := e.obj(mNode).name;
    RETURN p;
  END getName;

  PROCEDURE create*(): mList;
  VAR
    m: mList;
  BEGIN
    NEW(m);
    m.addNode := addNode;
    m.appendNode := appendNode;
    m.getName := getName;
    RETURN m
  END create;

END mnshList.
