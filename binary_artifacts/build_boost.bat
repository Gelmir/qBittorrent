@ECHO OFF
GOTO BEGIN
:CLEANUP
CD %CWD%
ECHO 1 > %INST_DIR%\cache.appv
SET INST_DIR=
IF EXIST %SOURCEROOT%\Boost RD /S /Q %SOURCEROOT%\Boost
GOTO END
:FAIL
ECHO Building failed, leaving source tree as is and dumping custom env vars
CD %CWD%
IF DEFINED INST_DIR ECHO INST_DIR = %INST_DIR%
SET INST_DIR=
GOTO END
:BEGIN
SET "INST_DIR=%BUILDROOT%\Boost"
IF EXIST %INST_DIR%\cache.appv GOTO CLEANUP
IF EXIST %INST_DIR% RD /S /Q %INST_DIR%
SET CWD=%CD%
CALL "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvars64.bat"
IF EXIST %SOURCEROOT%\Boost RD /S /Q %SOURCEROOT%\Boost
MD %SOURCEROOT%\Boost
CD %SOURCEROOT%\Boost
curl -fsS -o "%ARCHIVES%\Boost.7z" -L "https://dl.bintray.com/boostorg/release/1.65.1/source/boost_1_65_1.7z"
7z.exe x %ARCHIVES%\Boost.7z -o%SOURCEROOT%\Boost
CD .\boost_1_65_1
IF EXIST %BUILDROOT%\bjam RD /S /Q %BUILDROOT%\bjam
CD .\tools\build
CALL .\bootstrap.bat
IF ERRORLEVEL 1 GOTO FAIL
.\b2.exe --toolset=msvc architecture=x86 address-model=64 --prefix=%BUILDROOT%\bjam link=shared runtime-link=shared variant=release debug-symbols=off warnings=off warnings-as-errors=off inlining=full optimization=speed "cflags=/O2 /GL /favor:blend" "linkflags=/NOLOGO /OPT:REF /OPT:ICF=5 /LTCG" install
IF ERRORLEVEL 1 GOTO FAIL
CD ..\..\
SET "PATH=%BUILDROOT%\bjam\bin;%PATH%"
@ECHO OFF
bjam -j8 -q --with-system --with-chrono --with-random --with-date_time --with-thread --toolset=msvc --layout=system --prefix=%INST_DIR% link=shared runtime-link=shared variant=release debug-symbols=off threading=multi address-model=64 host-os=windows target-os=windows embed-manifest=on architecture=x86 warnings=off warnings-as-errors=off inlining=full optimization=speed "cflags=/O2 /GL /favor:blend" "linkflags=/NOLOGO /OPT:REF /OPT:ICF=5 /LTCG" install
IF ERRORLEVEL 1 GOTO FAIL
XCOPY /Y /Q %SOURCEROOT%\Boost\*.jam %INST_DIR%\
COPY /Y %SOURCEROOT%\Boost\Jamroot %INST_DIR%\
GOTO CLEANUP
:END
ECHO END BJAM AND BOOST BUILD