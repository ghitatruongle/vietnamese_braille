$target = "E:\vietnamese_braille\viet_braille_app\build\windows\x64\runner\Release\viet_braille_app.exe"
$iconPath = "E:\vietnamese_braille\viet_braille_app\assets\icon\app_icon.ico"
$desktop = [Environment]::GetFolderPath("Desktop") + "\Vietnamese Braille.lnk"
$startMenu = [Environment]::GetFolderPath("StartMenu") + "\Programs\Vietnamese Braille.lnk"

# Xóa shortcut cũ nếu có
if (Test-Path $desktop) { Remove-Item -Path $desktop -Force }
if (Test-Path $startMenu) { Remove-Item -Path $startMenu -Force }

$ws = New-Object -ComObject WScript.Shell

# Desktop Shortcut
$s1 = $ws.CreateShortcut($desktop)
$s1.TargetPath = $target
$s1.WorkingDirectory = [System.IO.Path]::GetDirectoryName($target)
$s1.IconLocation = "$iconPath,0"
$s1.Description = "Vietnamese Braille Converter App v1.0.1"
$s1.Save()

# Start Menu Shortcut
$s2 = $ws.CreateShortcut($startMenu)
$s2.TargetPath = $target
$s2.WorkingDirectory = [System.IO.Path]::GetDirectoryName($target)
$s2.IconLocation = "$iconPath,0"
$s2.Description = "Vietnamese Braille Converter App v1.0.1"
$s2.Save()

Write-Host "Cài đặt ứng dụng và tạo Shortcut với Icon mới thành công!"

# Launch App
Start-Process -FilePath $target
