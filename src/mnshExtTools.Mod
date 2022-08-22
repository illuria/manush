MODULE mnshExtTools;

IMPORT Platform, Strings, pipes, IntStr := oocIntStr, Out;

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

PROCEDURE getPPIDbyPID*(pid: LONGINT): LONGINT;
VAR
  res: SHORTINT;
  pidstr, pidstr0: ARRAY 8 OF CHAR;
  cmd0, cmd: ARRAY 64 OF CHAR;
  text : pipes.Text;
  exit, ppid : LONGINT;
BEGIN
    Out.String("pid="); Out.Int(pid,0); Out.Ln;
  IntStr.IntToStr(pid, pidstr);
    Out.String("pidstr="); Out.String(pidstr); Out.Ln;
  COPY("ps -o ppid ", cmd);
  Strings.Append(pidstr, cmd);
     Out.String("cmd is "); Out.String(cmd); Out.Ln;
  COPY(" | grep -v PPID", cmd0);
  Strings.Append(cmd0, cmd);
    Out.String(cmd); Out.Ln;
  text := pipes.Popen(cmd, 'r');
  IF text # NIL THEN
    pipes.ReadLine(text, pidstr0);
    exit := pipes.Pclose(text);
  ELSE
    Out.String("popen() failed"); Out.Ln;
    HALT(1)
  END;
  IntStr.StrToInt(pidstr0, ppid, res);
  IF res # IntStr.strAllRight THEN
    Out.String("failure when converting "); Out.String(pidstr0); Out.String(" to integer"); Out.Ln;
    HALT(1);
  END;
  RETURN ppid;
END getPPIDbyPID;

PROCEDURE getNameByPID*(p: LONGINT; VAR name: ARRAY OF CHAR): LONGINT;
VAR
  cmd, cmd0: ARRAY 64 OF CHAR;
  pid: ARRAY 8 OF CHAR;
  text: pipes.Text;
  exit: LONGINT;
BEGIN
  COPY("ps ", cmd);
  IntStr.IntToStr(p, pid);
  Strings.Append(pid, cmd);
  COPY(" | grep -v PID | awk '{print $NF}'", cmd0);
  Strings.Append(cmd0, cmd);
    Out.String("getnamebypid cmd "); Out.String(cmd); Out.Ln;
  text := pipes.Popen(cmd, 'r');
  IF text # NIL THEN
    pipes.ReadLine(text, name);
    exit := pipes.Pclose(text);
  ELSE
    Out.String("popen() failed"); Out.Ln;
    HALT(1)
  END;
  RETURN exit
END getNameByPID;

END mnshExtTools.
