MODULE mnshStorage;

IMPORT Out, Files, strutils;

PROCEDURE fileToString*(VAR fileName: ARRAY OF CHAR; VAR returnString: strutils.pstring);
VAR
    f: Files.File;
    r: Files.Rider;
    i, j: LONGINT;
BEGIN
    returnString := NIL;
    f := Files.Old(fileName);
    IF f # NIL THEN
      Files.Set(r, f, 0);
      i := Files.Length(f);
      NEW(returnString, i);
      j := 0;
      REPEAT
        Files.Read(r, returnString^[j]);
        INC(j);
      UNTIL r.eof OR (j >= i);
    ELSE
      Out.String("file ");
      Out.String(fileName);
      Out.String(" not found");
      Out.Ln;
    END;

END fileToString;

END mnshStorage.
