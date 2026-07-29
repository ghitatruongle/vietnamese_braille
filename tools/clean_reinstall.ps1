# Clean Uninstall & Reinstall Script for Windows Desktop Shortcut & Icon Cache

Write-Host "Đang gỡ cài đặt và dọn dẹp bộ nhớ đệm Icon của Windows..."

# 1. Dừng tiến trình Explorer để mở khóa các file cache
Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 1

# 2. Xóa các Shortcut cũ
$desktop = [Environment]::GetFolderPath("Desktop") + "\Vietnamese Braille.lnk"
$startMenu = [Environment]::GetFolderPath("StartMenu") + "\Programs\Vietnamese Braille.lnk"

if (Test-Path $desktop) { Remove-Item -Path $desktop -Force }
if (Test-Path $startMenu) { Remove-Item -Path $startMenu -Force }

# 3. Xóa các tệp bộ nhớ đệm IconCache của Windows
try {
    Remove-Item -Path "$env:LOCALAPPDATA\IconCache.db" -Force -ErrorAction SilentlyContinue
    Get-ChildItem -Path "$env:LOCALAPPDATA\Microsoft\Windows\Explorer" -Filter "iconcache*" | Remove-Item -Force -ErrorAction SilentlyContinue
} catch {}

# 4. Tạo lại Shortcut mới trỏ trực tiếp tới Icon trong suốt
$target = "E:\vietnamese_braille\viet_braille_app\build\windows\x64\runner\Release\viet_braille_app.exe"
$iconPath = "E:\vietnamese_braille\viet_braille_app\assets\icon\app_icon.ico"

$ws = New-Object -ComObject WScript.Shell

$s1 = $ws.CreateShortcut($desktop)
$s1.TargetPath = $target
$s1.WorkingDirectory = [System.IO.Path]::GetDirectoryName($target)
$s1.IconLocation = "$iconPath,0"
$s1.Description = "Vietnamese Braille Converter App v1.1.0"
$s1.Save()

$s2 = $ws.CreateShortcut($startMenu)
$s2.TargetPath = $target
$s2.WorkingDirectory = [System.IO.Path]::GetDirectoryName($target)
$s2.IconLocation = "$iconPath,0"
$s2.Description = "Vietnamese Braille Converter App v1.1.0"
$s2.Save()

# 5. Khởi động lại Windows Explorer
Start-Process explorer

Write-Host "Đã gỡ cài đặt, làm sạch IconCache và cài đặt lại thành công!"

# Khởi chạy lại ứng dụng
Start-Process -FilePath $target
