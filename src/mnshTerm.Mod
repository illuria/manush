MODULE mnshTerm;
IMPORT Platform;

CONST
  cmdStart0 = "stty cbreak";
  cmdStart1 = "stty -echo";
  cmdStop0 = "stty -g $(stty -g)";
  cmdStop1 = "stty echo";
  cmdStop2 = "stty sane";
  cmdFixErase = "stty erase ^h";
  delay = 10;

PROCEDURE StartV7Mode*;
VAR
  i: INTEGER;
BEGIN
  i := Platform.System(cmdStart0);
  Platform.Delay(delay);
  i := Platform.System(cmdStart1);
END StartV7Mode;

PROCEDURE StopV7Mode*;
VAR
  i: INTEGER;
BEGIN
  i := Platform.System(cmdStop1);
  Platform.Delay(delay);
  i := Platform.System(cmdStop2);
  Platform.Delay(delay);
  i := Platform.System(cmdFixErase);

END StopV7Mode;



END mnshTerm.
