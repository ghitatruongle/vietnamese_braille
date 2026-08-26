; Inno Setup 6 — Bộ cài Vietnamese Braille (Windows x64)
; Biên dịch: ISCC.exe viet_braille.iss
; Yêu cầu: đã chạy `flutter build windows --release` trước đó.

#define MyAppName "Vietnamese Braille"
#define MyAppVersion "1.5.0-beta1"
#define MyAppExeName "viet_braille_app.exe"
#define ReleaseDir "F:\Project of Ghita\vietnamese_braille\viet_braille_app\build\windows\x64\runner\Release"

[Setup]
AppId={{A7E8D3F1-2B44-4C66-9A88-D1E5C0DE1001}}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher=ghitatruongle
; Cài per-user (không cần quyền admin): vào %LOCALAPPDATA%\Programs
PrivilegesRequired=lowest
DefaultDirName={localappdata}\Programs\VietnameseBraille
DisableProgramGroupPage=yes
OutputDir=build\installer
OutputBaseFilename=VietnameseBraille-{#MyAppVersion}-setup
Compression=lzma2/max
SolidCompression=yes
WizardStyle=modern
UninstallDisplayIcon={app}\{#MyAppExeName}

[Tasks]
Name: "desktopicon"; \
  Description: "Tạo biểu tượng trên Desktop"; \
  GroupDescription: "Tùy chọn:"; \
  Flags: checkedonce

[Files]
Source: "{#ReleaseDir}\*"; DestDir: "{app}"; \
  Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; \
  Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; \
  Description: "Chạy {#MyAppName} ngay bây giờ"; \
  Flags: nowait postinstall skipifsilent

[UninstallDelete]
; Dọn dữ liệu cache do Flutter sinh trong thư mục cài đặt khi gỡ.
Type: filesandordirs; Name: "{app}\data"
