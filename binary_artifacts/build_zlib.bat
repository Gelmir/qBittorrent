@ECHO OFF
GOTO BEGIN
:CLEANUP
CD %CWD%
ECHO 1 > %INST_DIR%\cache.appv
SET INST_DIR=
IF EXIST %SOURCEROOT%\Zlib RD /S /Q %SOURCEROOT%\Zlib
GOTO END
:FAIL
ECHO Building failed, leaving source tree as is and dumping custom env vars
CD %CWD%
IF DEFINED INST_DIR ECHO INST_DIR = %INST_DIR%
SET INST_DIR=
EXIT 8
:BEGIN
SET "INST_DIR=%BUILDROOT%\Zlib"
IF EXIST %INST_DIR%\cache.appv GOTO CLEANUP
IF EXIST %INST_DIR% RD /S /Q %INST_DIR%
MD %INST_DIR%
SET CWD=%CD%
CALL "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvars64.bat"
IF EXIST %SOURCEROOT%\Zlib RD /S /Q %SOURCEROOT%\Zlib
MD %SOURCEROOT%\Zlib
CD %SOURCEROOT%\Zlib
curl -fsS -o "%ARCHIVES%\zlib.zip" "http://www.zlib.net/zlib1211.zip"
7z.exe x %ARCHIVES%\zlib.zip -o%SOURCEROOT%\Zlib
CD .\zlib-1.2.11
:: Time to edit Makefiles
sed -b -e "s/\(^ASFLAGS = \).*\(\$(LOC)\)/\1\2/" -e "s/\(^AS = \).*/\1ml64/" -e "s/\(^CFLAGS  = \).*\(\$(LOC)\)/\1 -nologo -MD -O2 -W3 -favor\:blend -GL -GR- -Y- -MP -EHs-c- \2/" -e "s/\(^LDFLAGS = \).*/\1-nologo -incremental\:no -opt\:ref -opt\:icf=5 -ltcg/" -e "s/\(^ARFLAGS = .*\)/\1 -ltcg/" < .\win32\Makefile.msc > .\win32\Makefile.msc.%SEDEXT%
MOVE /Y .\win32\Makefile.msc.%SEDEXT% .\win32\Makefile.msc
nmake -f .\win32\Makefile.msc AS=ml64 LOC="-DASMV -DASMINF -DNDEBUG -I." OBJA="inffasx64.obj gvmat64.obj inffas8664.obj"
IF ERRORLEVEL 1 GOTO FAIL
nmake -f .\win32\Makefile.msc test
IF ERRORLEVEL 1 GOTO FAIL
:: Provided Makefile has no install target; doing this ourselves
XCOPY /Y /Q /I .\*.dll %INST_DIR%\bin\
XCOPY /Y /Q /I .\*.lib %INST_DIR%\lib\
XCOPY /Y /Q /I .\zconf.h %INST_DIR%\include\
XCOPY /Y /Q /I .\zlib.h %INST_DIR%\include\
GOTO CLEANUP
:END
ECHO END ZLIB BUILD