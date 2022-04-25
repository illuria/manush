MODULE mnshExtTools;

IMPORT Platform, Strings;

PROCEDURE check*(VAR path: ARRAY OF CHAR): INTEGER;
VAR
  cmd : ARRAY 600 OF CHAR;
  status: INTEGER;
BEGIN
  status := 0;
  COPY("cat ", cmd);
  Strings.Append(path, cmd);
  Strings.Append(" | jq -e", cmd);
  status := Platform.System(cmd);
  RETURN status
END check;



END mnshExtTools.
