; Inno Setup Script cho Vietnamese Braille Desktop v1.1.0
; Yêu cầu Inno Setup 6.0 trở lên: https://jrsoftware.org/isinfo.php

#define MyAppName "Vietnamese Braille"
#define MyAppVersion "1.1.0"
#define MyAppPublisher "Vietnamese Braille Contributors"
#define MyAppURL "https://github.com/ghitatruongle/vietnamese_braille"
#define MyAppExeName "viet_braille_app.exe"
#define SourceBuildDir "..\viet_braille_app\build\windows\x64\runner\Release"

[Setup]
AppId={{D8A1B541-9413-4E87-B5C8-9ADB159E43EA}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={localappdata}\Programs\{#MyAppName}
DefaultGroupName={#MyAppName}
AllowNoIcons=yes
PrivilegesRequired=lowest
LicenseFile=..\viet_braille_app\LICENSE
OutputDir=..\build\installer
OutputBaseFilename=VietnameseBraille_v1.1.0_Setup
Compression=lzma2/ultra64
SolidCompression=yes
WizardStyle=modern
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
UninstallDisplayIcon={app}\{#MyAppExeName}

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "{#SourceBuildDir}\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#SourceBuildDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent
