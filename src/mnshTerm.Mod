MODULE mnshTerm;
IMPORT Platform;

CONST
  cmd0 = "stty cbreak";
  cmd1 = "stty -g $(stty -g)";

PROCEDURE StartV7Mode*;
VAR
  i: INTEGER;
BEGIN
  i := Platform.System(cmd0);
END StartV7Mode;

PROCEDURE StopV7Mode*;
VAR
  i: INTEGER;
BEGIN
  i := Platform.System(cmd1);
END StopV7Mode;


END mnshTerm.
