MODULE mnshStorage;

IMPORT Out, Files, strUtils;

PROCEDURE fileToString*(fileName: ARRAY OF CHAR; VAR returnString: strUtils.pstring);
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

PROCEDURE exists*(VAR path: ARRAY OF CHAR): BOOLEAN;
VAR
  F: Files.File;
BEGIN
  F := Files.Old(path);
  IF F = NIL THEN RETURN FALSE ELSE RETURN TRUE END
END exists;

END mnshStorage.
