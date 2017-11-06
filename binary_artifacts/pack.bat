@ECHO OFF
GOTO BEGIN
:CLEANUP
CD /D %CWD%
GOTO END
:FAIL
ECHO Building failed, leaving source tree as is and dumping custom env vars
EXIT 8
:BEGIN
:: Required for nested loops and ifs
Setlocal EnableDelayedExpansion
SET "INST_DIR=%BUILDROOT%\qBittorrent64"
SET CWD=%CD%
CALL "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvars64.bat"
CD /D C:\out\qbt
:: Get qBt version for packaging
FOR /F "delims=" %%X IN ('findstr /R "^VER_MAJOR" .\version.pri ^| sed -e "s/^.* = \(.*\)/\1/"') DO @SET QBT_VERSION=%%X
FOR /F "delims=" %%X IN ('findstr /R "^VER_MINOR" .\version.pri ^| sed -e "s/^.* = \(.*\)/\1/"') DO @SET "QBT_VERSION=!QBT_VERSION!.%%X"
FOR /F "delims=" %%X IN ('findstr /R "^VER_BUGFIX" .\version.pri ^| sed -e "s/^.* = \(.*\)/\1/"') DO @SET "QBT_VERSION=!QBT_VERSION!.%%X"
FOR /F "delims=" %%X IN ('findstr /R "^VER_STATUS" .\version.pri ^| sed -e "s/^.* = \(.*\) #.*/\1/"') DO @SET "QBT_VERSION=!QBT_VERSION!%%X"
7z.exe -y x %ARCHIVES%\GeoIP.7z -o.\src\gui\geoip\
IF ERRORLEVEL 1 GOTO FAIL
SET "PATH=C:\Qt\5.9\msvc2017_64\bin;%PATH%"
SET "QB_STRING=qBittorrent-%QBT_VERSION%-%APPVEYOR_REPO_COMMIT%-libtorrent1.1"
SET "PACKAGE=%PACKAGEDIR%\%QB_STRING%.7z"
IF EXIST %PACKAGE% DEL /Q %PACKAGE%
7z.exe a -t7z %PACKAGE% %INST_DIR% -mx9 -mmt=on -mf=on -mhc=on -ms=on -m0=LZMA2
IF ERRORLEVEL 1 GOTO FAIL
ECHO Creating installer...
ECHO Installer log: %PACKAGEDIR%\%QB_STRING%-x64-setup.log
IF EXIST "%PACKAGEDIR%\%QB_STRING%-x64-setup.exe" DEL /Q "%PACKAGEDIR%\%QB_STRING%-x64-setup.exe"
"C:\Program Files (x86)\Inno Setup 5\ISCC.exe" "/dMyFilesRoot=%INST_DIR%" "/dPACKDIR=%PACKAGEDIR%" "/dMyAppVersion=%QBT_VERSION%" "/dMyIcon=C:\out\qbt\src\qbittorrent.ico" "/f%QB_STRING%-x64-setup" "/o%PACKAGEDIR%" "%ARCHIVES%\qbt64.iss"
IF ERRORLEVEL 1 GOTO FAIL
GOTO CLEANUP
:END
ECHO END QBITTORRENT PACKAGING