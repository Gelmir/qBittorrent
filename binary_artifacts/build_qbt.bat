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
IF EXIST %INST_DIR% RD /S /Q %INST_DIR%
MD %INST_DIR%
SET CWD=%CD%
CALL "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvars64.bat"
CD /D C:\out\qbt
7z.exe -y x %ARCHIVES%\GeoIP.7z -o.\src\gui\geoip\
IF ERRORLEVEL 1 GOTO FAIL
SET "PATH=C:\Qt\5.9\msvc2017_64\bin;%BUILDROOT%\jom;%PATH%"
SET "QMAKESPEC=C:\Qt\5.9\msvc2017_64\mkspecs\win32-msvc"
COPY /Y C:\Qt\5.9\msvc2017_64\bin\lupdate.exe .\
.\lupdate.exe -recursive -no-obsolete ./qbittorrent.pro
IF ERRORLEVEL 1 GOTO FAIL
DEL /Q .\lupdate.exe
SET "QMAKESPEC="
MD build
CD build
qmake -config release -r ../qbittorrent.pro "CONFIG += strace_win warn_off rtti ltcg mmx sse sse2" "CONFIG -= 3dnow" "INCLUDEPATH += C:/out/3rdparty_binaries/Boost/include" "INCLUDEPATH += C:/out/3rdparty_binaries/libtorrent/include" "INCLUDEPATH += C:/out/3rdparty_binaries/zlib/include" "INCLUDEPATH += C:/OpenSSL-Win64/include" "LIBS += -LC:/out/3rdparty_binaries/Boost/lib" "LIBS += -LC:/out/3rdparty_binaries/libtorrent/lib" "LIBS += -LC:/out/3rdparty_binaries/zlib/lib" "LIBS += -LC:/OpenSSL-Win64/lib" "LIBS += ole32.lib"
IF ERRORLEVEL 1 GOTO FAIL
jom -j1
IF ERRORLEVEL 1 GOTO FAIL
COPY /Y .\src\release\qbittorrent.exe %INST_DIR%\
IF EXIST .\src\release\qbittorrent.pdb COPY /Y .\src\release\qbittorrent.pdb %INST_DIR%\
FOR %%X IN (Qt5Core.dll Qt5Gui.dll Qt5Network.dll Qt5Widgets.dll Qt5Xml.dll Qt5WinExtras.dll Qt5Svg.dll) DO (
  COPY /Y C:\Qt\5.9\msvc2017_64\bin\%%X %INST_DIR%\
)
:: Only qico4.dll is required
XCOPY /Y /Q /I C:\Qt\5.9\msvc2017_64\plugins\imageformats\qico.dll %INST_DIR%\plugins\imageformats\
:: Not sure if needed
XCOPY /Y /Q /I /E C:\Qt\5.9\msvc2017_64\plugins\platforms %INST_DIR%\plugins\platforms
:: Use newer Qt translations if possible
:: Now I HAVE to use perl for non-greedy regex :(
FOR /F "usebackq" %%X IN (`DIR /B "C:\out\qbt\dist\qt-translations\" ^| perl -pe "s/^.*?_(.*)/\1/"`) DO (
  IF EXIST "C:\Qt\5.9\msvc2017_64\translations\qt_%%X" (
    COPY /Y "C:\Qt\5.9\msvc2017_64\translations\qt_%%X" "C:\out\qbt\dist\qt-translations\"
  )
  IF EXIST "C:\Qt\5.9\msvc2017_64\translations\qtbase_%%X" (
    COPY /Y "C:\Qt\5.9\msvc2017_64\translations\qtbase_%%X" "C:\out\qbt\dist\qt-translations\"
  )
)
XCOPY /Y /Q /I C:\out\qbt\dist\qt-translations\qt_* %INST_DIR%\translations\
XCOPY /Y /Q /I C:\out\qbt\dist\qt-translations\qtbase_* %INST_DIR%\translations\

echo [Paths] > %INST_DIR%\qt.conf
echo Translations = ./translations >> %INST_DIR%\qt.conf
echo Plugins = ./plugins >> %INST_DIR%\qt.conf
XCOPY /Y /Q C:\OpenSSL-Win64\*.dll %INST_DIR%\
COPY /Y %BUILDROOT%\libtorrent\lib\torrent.dll %INST_DIR%\
COPY /Y %BUILDROOT%\Boost\lib\boost_system.dll %INST_DIR%\
:: LT 1.1.0 and higher needs chrono + random
COPY /Y %BUILDROOT%\Boost\lib\boost_chrono.dll %INST_DIR%\
COPY /Y %BUILDROOT%\Boost\lib\boost_random.dll %INST_DIR%\
:: Copy VC++ 2012 x64 Redist DLLs
COPY /Y "%VCINSTALLDIR%\Redist\MSVC\14.11.25325\x64\Microsoft.VC141.CRT\msvcp140.dll" %INST_DIR%\
COPY /Y "%VCINSTALLDIR%\Redist\MSVC\14.11.25325\x64\Microsoft.VC141.CRT\concrt140.dll" %INST_DIR%\
COPY /Y "%VCINSTALLDIR%\Redist\MSVC\14.11.25325\x64\Microsoft.VC141.CRT\vccorlib140.dll" %INST_DIR%\
COPY /Y "%VCINSTALLDIR%\Redist\MSVC\14.11.25325\x64\Microsoft.VC141.CRT\vcruntime140.dll" %INST_DIR%\
COPY /Y "C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\redist\x64\Microsoft.VC120.CRT\msvcp120.dll" %INST_DIR%\
COPY /Y "C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\redist\x64\Microsoft.VC120.CRT\msvcr120.dll" %INST_DIR%\
COPY /Y "C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\redist\x64\Microsoft.VC120.CRT\vccorlib120.dll" %INST_DIR%\
COPY /Y "%BUILDROOT%\dbghelp.dll" %INST_DIR%\
:: Copy License
COPY /Y C:\out\qbt\COPYING %INST_DIR%\LICENSE.txt
unix2dos -ascii %INST_DIR%\LICENSE.txt
GOTO CLEANUP
:END
ECHO END QBITTORRENT BUILD