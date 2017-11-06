@ECHO OFF
GOTO BEGIN
:CLEANUP
CD %CWD%
ECHO 1 > %INST_DIR%\cache.appv
SET INST_DIR=
IF EXIST %SOURCEROOT%\libtorrent RD /S /Q %SOURCEROOT%\libtorrent
GOTO END
:FAIL
ECHO Building failed, leaving source tree as is and dumping custom env vars
CD %CWD%
IF DEFINED INST_DIR ECHO INST_DIR = %INST_DIR%
SET INST_DIR=
EXIT 8
:BEGIN
SET "INST_DIR=%BUILDROOT%\libtorrent"
IF EXIST %INST_DIR%\cache.appv GOTO CLEANUP
IF EXIST %INST_DIR% RD /S /Q %INST_DIR%
SET CWD=%CD%
CALL "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvars64.bat"
IF EXIST %SOURCEROOT%\libtorrent RD /S /Q %SOURCEROOT%\libtorrent
MD %SOURCEROOT%\libtorrent
CD %SOURCEROOT%\libtorrent
curl -fsS -o "%ARCHIVES%\libtorrent.zip" -L "https://github.com/arvidn/libtorrent/archive/libtorrent-1_1_5.zip"
7z.exe x %ARCHIVES%\libtorrent.zip -o%SOURCEROOT%\libtorrent
cd .\libtorrent-libtorrent-1_1_5
patch -p1 -Nfi %ARCHIVES%\patches\crypto.patch
IF ERRORLEVEL 1 GOTO FAIL
SET "PATH=%BUILDROOT%\bjam\bin;%PATH%"
bjam -j2 -q --toolset=msvc --prefix=%INST_DIR% asserts=off windows-version=vista invariant-checks=off crypto=openssl boost-link=shared export-extra=on link=shared runtime-link=shared variant=release debug-symbols=off threading=multi address-model=64 host-os=windows target-os=windows embed-manifest=on architecture=x86 warnings=off warnings-as-errors=off inlining=full optimization=speed "cflags=/O2 /GL /favor:blend" "linkflags=/NOLOGO /OPT:REF /OPT:ICF=5 /LTCG" "include=C:\OpenSSL-Win64\include" "include=%BUILDROOT%\Boost\include" "library-path=C:\OpenSSL-Win64\lib" "library-path=%BUILDROOT%\Boost\lib" "define=BOOST_ALL_NO_LIB" install
IF ERRORLEVEL 1 GOTO FAIL
GOTO CLEANUP
:END
ECHO END LIBTORRENT BUILD