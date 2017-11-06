; Example run command:
; ISCC.exe "/dMyFilesRoot=path_to_directory_containing_qbt" "/dPACKDIR=dir_containing_vcredist_x64.exe" "/dMyAppVersion=qBt_version_here" "/dMyIcon=path_to_setup_icon""/foverride_resulting_installer_name" "/oput_installer_in_this_directory" "path_to_script"
; 
; Same example using environmental variables:
; "C:\Program Files (x86)\Inno Setup 5\ISCC.exe" "/dMyFilesRoot=%INST_DIR%" "/dPACKDIR=%PACKAGEDIR%" "/dMyAppVersion=%QBT_VERSION%" "/dMyIcon=%SOURCEROOT%\qbittorrent\src\qbittorrent.ico" "/fqBittorrent-%QBT_VERSION%-x64-setup" "/o%PACKAGEDIR%" "%SCRIPTROOT%\qbt\qbt64.iss"

#define MyAppName "qBittorrent (x64 Edition)"
#define MyAppPublisher "The qBittorrent project"
#define MyAppCopyright "Copyright ©2006-2013 The qBittorrent project"
#define MyAppURL "http://www.qbittorrent.org/"
#define MyAppExeName "qbittorrent.exe"
#define MyAppPdbName "qbittorrent.pdb"

[Setup]
; NOTE: The value of AppId uniquely identifies this application.
; Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{2589239E-DCDD-4F29-960B-DE40C1AC0CDD}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
;AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppCopyright={#MyAppCopyright}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={pf}\{#MyAppName}
DefaultGroupName={#MyAppName}
; Do not allow to change start menu shortcut group during installation
DisableProgramGroupPage=yes
LicenseFile="{#MyFilesRoot}\LICENSE.txt"
Compression=lzma2/ultra
SolidCompression=yes
CompressionThreads=auto
LZMANumBlockThreads=2
; Only install in x64 mode and on x64 OSes (Vista and up)
ArchitecturesInstallIn64BitMode=x64
ArchitecturesAllowed=x64
MinVersion=6.0.6000
; Installer icon
SetupIconFile={#MyIcon}
; Use installation rules from previous setup (when updating) if possible
UsePreviousTasks=yes
; refresh explorer when associations are set
ChangesAssociations=yes
RestartApplications=no

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "brazilianportuguese"; MessagesFile: "compiler:Languages\BrazilianPortuguese.isl"
Name: "catalan"; MessagesFile: "compiler:Languages\Catalan.isl"
Name: "czech"; MessagesFile: "compiler:Languages\Czech.isl"
Name: "danish"; MessagesFile: "compiler:Languages\Danish.isl"
Name: "dutch"; MessagesFile: "compiler:Languages\Dutch.isl"
Name: "finnish"; MessagesFile: "compiler:Languages\Finnish.isl"
Name: "french"; MessagesFile: "compiler:Languages\French.isl"
Name: "german"; MessagesFile: "compiler:Languages\German.isl"
Name: "greek"; MessagesFile: "compiler:Languages\Greek.isl"
Name: "hebrew"; MessagesFile: "compiler:Languages\Hebrew.isl"
Name: "hungarian"; MessagesFile: "compiler:Languages\Hungarian.isl"
Name: "italian"; MessagesFile: "compiler:Languages\Italian.isl"
Name: "japanese"; MessagesFile: "compiler:Languages\Japanese.isl"
Name: "norwegian"; MessagesFile: "compiler:Languages\Norwegian.isl"
Name: "polish"; MessagesFile: "compiler:Languages\Polish.isl"
Name: "portuguese"; MessagesFile: "compiler:Languages\Portuguese.isl"
Name: "russian"; MessagesFile: "compiler:Languages\Russian.isl"
Name: "serbiancyrillic"; MessagesFile: "compiler:Languages\SerbianCyrillic.isl"
Name: "serbianlatin"; MessagesFile: "compiler:Languages\SerbianLatin.isl"
Name: "slovenian"; MessagesFile: "compiler:Languages\Slovenian.isl"
Name: "spanish"; MessagesFile: "compiler:Languages\Spanish.isl"
Name: "ukrainian"; MessagesFile: "compiler:Languages\Ukrainian.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked
Name: "firewall"; Description: "Add Firewall Exception"; GroupDescription: "{cm:AdditionalIcons}"
Name: "torrent_assoc"; Description: "Associate with .torrent files"; GroupDescription: "{cm:AdditionalIcons}"
Name: "magnet_assoc"; Description: "Associate with magnet links"; GroupDescription: "{cm:AdditionalIcons}"

[Files]
Source: "{#MyFilesRoot}\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion
; Hack for pdb inclusion on different versions
Source: "{#MyFilesRoot}\{#MyAppPdbName}"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist
; Boost
Source: "{#MyFilesRoot}\boost_system.dll"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist
Source: "{#MyFilesRoot}\boost_date_time.dll"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist
Source: "{#MyFilesRoot}\boost_chrono.dll"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist
Source: "{#MyFilesRoot}\boost_random.dll"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist
Source: "{#MyFilesRoot}\libboost_system.dll"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist
Source: "{#MyFilesRoot}\libboost_date_time.dll"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist
; OpenSSL
Source: "{#MyFilesRoot}\libeay32.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#MyFilesRoot}\ssleay32.dll"; DestDir: "{app}"; Flags: ignoreversion
; libtorrent-rasterbar
Source: "{#MyFilesRoot}\torrent.dll"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist
Source: "{#MyFilesRoot}\libtorrent.dll"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist
; Qt shared files
Source: "{#MyFilesRoot}\plugins\*"; DestDir: "{app}\plugins"; Flags: ignoreversion recursesubdirs createallsubdirs skipifsourcedoesntexist
Source: "{#MyFilesRoot}\translations\*"; DestDir: "{app}\translations"; Flags: ignoreversion recursesubdirs createallsubdirs skipifsourcedoesntexist
Source: "{#MyFilesRoot}\qt.conf"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist
; Qt4 version
Source: "{#MyFilesRoot}\QtCore4.dll"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist
Source: "{#MyFilesRoot}\QtGui4.dll"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist
Source: "{#MyFilesRoot}\QtNetwork4.dll"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist
Source: "{#MyFilesRoot}\QtXml4.dll"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist
; Qt5 version
Source: "{#MyFilesRoot}\Qt5Core.dll"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist
Source: "{#MyFilesRoot}\Qt5Gui.dll"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist
Source: "{#MyFilesRoot}\Qt5Network.dll"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist
Source: "{#MyFilesRoot}\Qt5Widgets.dll"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist
Source: "{#MyFilesRoot}\Qt5Xml.dll"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist
Source: "{#MyFilesRoot}\Qt5WinExtras.dll"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist
Source: "{#MyFilesRoot}\Qt5Svg.dll"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist
; Visual C++ 201X x64 Redistributable
Source: "{#MyFilesRoot}\msvcp110.dll"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist
Source: "{#MyFilesRoot}\msvcr110.dll"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist
Source: "{#MyFilesRoot}\msvcp120.dll"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist
Source: "{#MyFilesRoot}\msvcr120.dll"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist
Source: "{#MyFilesRoot}\msvcp140.dll"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist
Source: "{#MyFilesRoot}\concrt140.dll"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist
Source: "{#MyFilesRoot}\vccorlib140.dll"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist
Source: "{#MyFilesRoot}\vccorlib120.dll"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist
Source: "{#MyFilesRoot}\vcruntime140.dll"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist
; Gcc runtime
Source: "{#MyFilesRoot}\libgcc_s_seh-1.dll"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist
Source: "{#MyFilesRoot}\libssp-0.dll"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist
Source: "{#MyFilesRoot}\libstdc++-6.dll"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist
Source: "{#MyFilesRoot}\libwinpthread-1.dll"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist
; Debug helper for stacktraces
Source: "{#MyFilesRoot}\dbghelp.dll"; DestDir: "{app}"; Flags: ignoreversion
; App to kill process by name
Source: "{#PACKDIR}\processviewer.exe"; Flags: dontcopy
; License
Source: "{#MyFilesRoot}\LICENSE.txt"; DestDir: "{app}"; Flags: ignoreversion


[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"
Name: "{commondesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon


[Registry]
; .torrent association
Root: HKCR; Subkey: ".torrent"; ValueType: string; ValueName: ""; ValueData: "qBittorrent"; Flags: uninsdeletevalue; Tasks: torrent_assoc 
Root: HKCR; Subkey: ".torrent"; ValueType: string; ValueName: "Content Type"; ValueData: "application/x-bittorrent"; Flags: uninsdeletevalue; Tasks: torrent_assoc 
Root: HKCR; Subkey: "qBittorrent\Content Type"; ValueType: string; ValueName: ""; ValueData: "application/x-bittorrent"; Flags: uninsdeletekey; Tasks: torrent_assoc
Root: HKCR; Subkey: "qBittorrent\DefaultIcon"; ValueType: string; ValueName: ""; ValueData: """{app}\{#MyAppExeName}"",1"; Flags: uninsdeletekey; Tasks: torrent_assoc
Root: HKCR; Subkey: "qBittorrent\shell"; ValueType: string; ValueName: ""; ValueData: "open"; Flags: uninsdeletekey; Tasks: torrent_assoc
Root: HKCR; Subkey: "qBittorrent\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """{app}\{#MyAppExeName}"" ""%1"""; Flags: uninsdeletekey; Tasks: torrent_assoc

; magnet association
Root: HKCR; Subkey: "Magnet"; ValueType: string; ValueName: ""; ValueData: "Magnet URI"; Flags: uninsdeletevalue; Tasks: magnet_assoc 
Root: HKCR; Subkey: "Magnet"; ValueType: string; ValueName: "Content Type"; ValueData: "application/x-magnet"; Flags: uninsdeletevalue; Tasks: magnet_assoc 
Root: HKCR; Subkey: "Magnet"; ValueType: string; ValueName: "URL Protocol"; ValueData: ""; Flags: uninsdeletekey; Tasks: magnet_assoc
Root: HKCR; Subkey: "Magnet\DefaultIcon"; ValueType: string; ValueName: ""; ValueData: """{app}\{#MyAppExeName}"",1"; Flags: uninsdeletekey; Tasks: magnet_assoc
Root: HKCR; Subkey: "Magnet\shell"; ValueType: string; ValueName: ""; ValueData: "open"; Flags: uninsdeletekey; Tasks: magnet_assoc
Root: HKCR; Subkey: "Magnet\shell"; ValueType: string; ValueName: ""; ValueData: "open"; Flags: uninsdeletekey; Tasks: magnet_assoc
Root: HKCR; Subkey: "Magnet\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """{app}\{#MyAppExeName}"" ""%1"""; Flags: uninsdeletekey; Tasks: magnet_assoc


[Run]
; Add/Remove firewall exception
; Need to remove exceptions first when updating
Filename: "{sys}\netsh.exe"; Parameters: "advfirewall firewall delete rule name=""qBittorrent64 TCP"" "; StatusMsg: "Removing Firewall Exception (TCP IN)"; Flags: runhidden; Tasks: firewall
Filename: "{sys}\netsh.exe"; Parameters: "advfirewall firewall delete rule name=""qBittorrent64 UDP"" ";  StatusMsg: "Removing Firewall Exception (UDP IN)"; Flags: runhidden; Tasks: firewall

Filename: "{sys}\netsh.exe"; Parameters: "advfirewall firewall add rule name=""qBittorrent64 TCP"" protocol=TCP dir=in action=allow program=""{app}\{#MyAppExeName}"" "; StatusMsg: "Adding Firewall Exception (TCP IN)"; Flags: runhidden; Tasks: firewall
Filename: "{sys}\netsh.exe"; Parameters: "advfirewall firewall add rule name=""qBittorrent64 UDP"" protocol=UDP dir=in action=allow program=""{app}\{#MyAppExeName}"" "; StatusMsg: "Adding Firewall Exception (UDP IN)"; Flags: runhidden; Tasks: firewall

[UninstallRun]
Filename: "{sys}\netsh.exe"; Parameters: "advfirewall firewall delete rule name=""qBittorrent64 TCP"" "; StatusMsg: "Removing Firewall Exception (TCP IN)"; Flags: runhidden
Filename: "{sys}\netsh.exe"; Parameters: "advfirewall firewall delete rule name=""qBittorrent64 UDP"" ";  StatusMsg: "Removing Firewall Exception (UDP IN)"; Flags: runhidden

[Code]

// With Qt5 version on the horizon we must uninstall previous version automatically
// Otherwise installation directory is gonna be cluttered with both Qt4 and Qt5 libraries

// Thanks to http://stackoverflow.com/a/2099805/1477014 for the functions
/////////////////////////////////////////////////////////////////////
function GetUninstallString(): String;
var
  sUnInstPath: String;
  sUnInstallString: String;
begin
  sUnInstPath := ExpandConstant('Software\Microsoft\Windows\CurrentVersion\Uninstall\{#emit SetupSetting("AppId")}_is1');
  sUnInstallString := '';
  if not RegQueryStringValue(HKLM, sUnInstPath, 'UninstallString', sUnInstallString) then
    RegQueryStringValue(HKCU, sUnInstPath, 'UninstallString', sUnInstallString);
  Result := sUnInstallString;
end;


/////////////////////////////////////////////////////////////////////
function IsUpgrade(): Boolean;
begin
  Result := (GetUninstallString() <> '');
end;


/////////////////////////////////////////////////////////////////////
function UnInstallOldVersion(): Integer;
var
  sUnInstallString: String;
  iResultCode: Integer;
begin
// Return Values:
// 1 - uninstall string is empty
// 2 - error executing the UnInstallString
// 3 - successfully executed the UnInstallString

  // default return value
  Result := 0;

  // get the uninstall string of the old app
  sUnInstallString := GetUninstallString();
  if sUnInstallString <> '' then begin
    sUnInstallString := RemoveQuotes(sUnInstallString);
    if Exec(sUnInstallString, '/SILENT /NORESTART /SUPPRESSMSGBOXES','', SW_HIDE, ewWaitUntilTerminated, iResultCode) then
      Result := 3
    else
      Result := 2;
  end else
    Result := 1;
end;

/////////////////////////////////////////////////////////////////////
procedure CurStepChanged(CurStep: TSetupStep);
begin
  if (CurStep=ssInstall) then
  begin
    if (IsUpgrade()) then
    begin
      UnInstallOldVersion();
    end;
  end;
end;
/////////////////////////////////////////////////////////////////////

// Check if qBittorrent.exe is running
function ProductRunning(): Boolean;
var
  ExitCode:    Integer;
begin  
  ExtractTemporaryFile('processviewer.exe');
  if Exec(ExpandConstant('{tmp}\processviewer.exe'), 'qbittorrent.exe', '', SW_HIDE, ewWaitUntilTerminated, ExitCode)
  then
  begin
    // Process found
    Result := ( ExitCode > 0 );
    Exit;    
  end;
  
  Result := False;
end;
  
// Check if 32-bit qBittorrent is installed
function qBt32Installed: Boolean;
begin
  Result := RegkeyExists( HKLM32, 'SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\qbittorrent' );
end;

// Uninstall 32-bit qBittorrent
// Return 0 on success; 1 on Reg fail; 2 if uninstaller does not exist; 3 if uninstaller failed to start; 4 if uninstaller produced some kind of error
function qBt32Uninstall: Integer;
var
  Fail:          Boolean;
  UninstallerString:    String;
  UninstallerReturnCode:  Integer;
begin
  Fail := NOT RegQueryStringValue( HKLM32, 'SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\qbittorrent', 'UninstallString', UninstallerString );
  
  // Uninstaller path not found in registry
  if Fail
  then
  begin
    Result := 1;
    Exit;
  end;
  
  Fail := NOT FileExists( RemoveQuotes( UninstallerString ) );
  
  // Uninstaller does not exist
  if Fail
  then
  begin
    Result := 2;
    Exit;
  end;
  
  Fail := NOT Exec ( '>', UninstallerString, '', SW_SHOW, ewWaitUntilTerminated, UninstallerReturnCode );
  
  // Failed to create process
  if Fail
  then
  begin
    Result := 3;
    Exit;
  end;
  
  // 32 bit uninstaller failed
  if UninstallerReturnCode <> 0
  then
  begin
    Result := 4;
    Exit;
  end;
  
  // NSIS uninstaller spawns a child process and terminates, so using 'ewWaitUntilTerminated' in exec is useless
  // That is why we need this dirty hack to prevent exiting function until uninstaller finishes
  MsgBox( 'Click "OK" when 32-bit uninstaller has finished.', mbInformation, MB_OK );
  
  Result := 0;
end;

// Override Setup Init
function InitializeSetup(): Boolean;
var
  MsgBoxResult:    Integer;
  UninstallerResult:  Integer;
begin
  if qBt32Installed()
  then
  begin
    MsgBoxResult := MsgBox( '32-bit version of qBittorrent is already installed.' + #13#10 +
      'It is recommended to uninstall 32-bit version of qBittorrent prior to installing 64-bit version.' + #13#10 +
      'Press "NO" to cancel setup allowing you to uninstall 32-bit version manually' + #13#10 +
      'Press "YES" to instruct setup to launch uninstaller for 32-bit version auromatically'  + #13#10 +
      'Press "CANCEL" to ignore this recommendation, if you know what you are doing.',
      mbInformation, MB_YESNOCANCEL OR MB_SETFOREGROUND);
    
    if MsgBoxResult = IDNO
    then
    begin
      Result := False;
      Exit;
    end;
    
    if MsgBoxResult = IDYES
    then
    begin
      UninstallerResult := qBt32Uninstall();
      
      if ( UninstallerResult <> 0 ) OR qBt32Installed()
      then
      begin
        case UninstallerResult of
          1:
            MsgBox( 'Uninstalling failed: failed to read uninstaller registry string.' + #13#10 +
              'Please uninstall manually.', mbError, MB_OK );
          2:
            MsgBox( 'Uninstalling failed: failed to locate uninstaller executable.' + #13#10 +
              'Please uninstall manually.', mbError, MB_OK );
          3:
            MsgBox( 'Uninstalling failed: failed to start uninstaller executable.' + #13#10 +
              'Please uninstall manually.', mbError, MB_OK );
          4:
            MsgBox( 'Uninstalling failed: 32-bit uninstaller returned error.' + #13#10 +
              'Please uninstall manually.', mbError, MB_OK );
          else
            MsgBox( 'Uninstalling was successeful, but old registry keys are still present.' + #13#10 +
              'Try ignoring "32-bit version of qBittorrent is already installed" next time.' + #13#10 +
              'P.S. Should never see this message.', mbError, MB_OK OR MB_SETFOREGROUND );
        end;
        
        Result := False;
        Exit;
      end;
    end;
    
    // Nothing to do here, ignore all 'already installed' checks for 32-bit qBt
    //if MsgBoxResult = IDCANCEL
    //then
    //begin
    //end;
  end;
  
  if ProductRunning()
  then
  begin
    MsgBox( 'qBittorrent is already running. Please close all application instances and restart setup.', mbInformation, MB_OK );
    Result := False;
  end
  else
  begin
    Result := True;
  end;
end;

