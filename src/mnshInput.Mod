MODULE mnshInput;

IMPORT SYSTEM;

PROCEDURE -inclStdio
  "#include <stdio.h>";

PROCEDURE -getchar(): INTEGER
  "getchar()";

PROCEDURE getChar*(): CHAR;
BEGIN
  RETURN CHR(SHORT(SHORT(getchar())));
END getChar;

END mnshInput.
