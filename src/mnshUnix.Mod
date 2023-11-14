MODULE mnshUnix;
IMPORT SYSTEM, strUtils, Out;
TYPE
    (*
    ArgPtr* = POINTER TO ARRAY 1024 OF CHAR;
    ArgVec* = POINTER TO ARRAY 1024 OF ArgPtr;
    *)
    ArgPtr* = strUtils.pstring;
    ArgVec* = strUtils.pstrings;

PROCEDURE -Aincludeunistd   '#include <unistd.h>';
PROCEDURE -Aincludewait   '#include <sys/wait.h>';

PROCEDURE -getpid(): LONGINT   "(LONGINT)getpid()";
PROCEDURE -getppid(): LONGINT   "(LONGINT)getppid()";

PROCEDURE -fork(): LONGINT   "(LONGINT)fork()";

PROCEDURE -execvp(VAR file: ARRAY [1] OF CHAR; args: ArgVec): LONGINT
  "(LONGINT)execvp(file,(char *const *) args)";

PROCEDURE -waitpid(pid: LONGINT; VAR wstatus: LONGINT; options: LONGINT): LONGINT
  "waitpid (pid, wstatus, options)";

PROCEDURE Execvp*(VAR cmd: ARRAY [1] OF CHAR; args: ArgVec): LONGINT;
BEGIN
  RETURN execvp(cmd, args)
END Execvp;

PROCEDURE waitPID*(pid: LONGINT);
VAR
  wstatus: LONGINT;
  options: LONGINT;
  l: LONGINT;
BEGIN
  l := waitpid(pid, wstatus, options);
  IF l # 0 THEN
    Out.String("child process failed"); Out.Ln;
    HALT(13);
  END;
END waitPID;

PROCEDURE getPid*(): LONGINT;
BEGIN
  RETURN getpid()
END getPid;

PROCEDURE getPPid*(): LONGINT;
BEGIN
  RETURN getppid()
END getPPid;

PROCEDURE Fork*(): LONGINT;
BEGIN
  RETURN fork()
END Fork;

END mnshUnix.
