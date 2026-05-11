# Rachnakaar Android app — auto-install + build
# What this script does:
#   1. Installs OpenJDK 17 (needed by Android build tools)
#   2. Downloads + extracts the Flutter SDK (~700 MB)
#   3. Installs Android Studio via winget (~1 GB) — provides Android SDK + build tools
#   4. Adds Flutter to your PATH
#   5. Runs `flutter doctor`, `flutter create .`, `flutter pub get`
#   6. Builds the release APK at build\app\outputs\flutter-apk\app-release.apk
#
# How to run:
#   Right-click PowerShell -> "Run as Administrator" (only needed for winget installs)
#   Then paste:
#     Set-ExecutionPolicy -Scope Process Bypass -Force
#     E:\ClaudeProjects\rachnakaar-app\setup-flutter.ps1
#
# Time: 30-60 minutes depending on internet speed.

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

function Step($msg) { Write-Host ""; Write-Host "==> $msg" -ForegroundColor Magenta }
function Ok($msg)   { Write-Host "[OK] $msg" -ForegroundColor Green }
function Warn($msg) { Write-Host "[!!] $msg" -ForegroundColor Yellow }

$FlutterRoot = "C:\flutter"
$FlutterZipUrl = "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.24.5-stable.zip"
$FlutterZip = "$env:TEMP\flutter_sdk.zip"
$ProjectDir = "E:\ClaudeProjects\rachnakaar-app"

# Step 1: JDK 17
Step "Step 1/6 — Installing OpenJDK 17"
$jdkInstalled = $false
try { $v = (java -version 2>&1)[0]; if ($v -match '"(17|21|22)') { $jdkInstalled = $true; Ok "JDK already installed: $v" } } catch {}
if (-not $jdkInstalled) {
    winget install -e --id EclipseAdoptium.Temurin.17.JDK --accept-package-agreements --accept-source-agreements --silent
    Ok "JDK 17 installed"
}

# Step 2: Flutter SDK
Step "Step 2/6 — Downloading + extracting Flutter SDK (~700 MB)"
if (Test-Path "$FlutterRoot\bin\flutter.bat") {
    Ok "Flutter already at $FlutterRoot — skipping download"
} else {
    Write-Host "Downloading from $FlutterZipUrl..."
    Invoke-WebRequest -Uri $FlutterZipUrl -OutFile $FlutterZip -UseBasicParsing
    Write-Host "Extracting to C:\..."
    Expand-Archive -Path $FlutterZip -DestinationPath "C:\" -Force
    Remove-Item $FlutterZip -Force
    Ok "Flutter SDK extracted to C:\flutter"
}

# Step 3: Add Flutter to PATH (user env, persistent)
Step "Step 3/6 — Adding Flutter to your PATH"
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($userPath -notlike "*$FlutterRoot\bin*") {
    [Environment]::SetEnvironmentVariable("Path", "$userPath;$FlutterRoot\bin", "User")
    Ok "PATH updated (will take effect after reopening PowerShell)"
} else {
    Ok "Flutter already in PATH"
}
$env:Path = "$env:Path;$FlutterRoot\bin"

# Step 4: Android Studio (provides Android SDK + build tools)
Step "Step 4/6 — Installing Android Studio (~1 GB; provides Android SDK)"
$asInstalled = Test-Path "C:\Program Files\Android\Android Studio\bin\studio64.exe"
if ($asInstalled) {
    Ok "Android Studio already installed"
} else {
    winget install -e --id Google.AndroidStudio --accept-package-agreements --accept-source-agreements --silent
    Ok "Android Studio installed"
    Warn "Open Android Studio once manually to complete first-run SDK setup (it will auto-download Android SDK)"
    Warn "After SDK download finishes, RE-RUN this script to complete steps 5-6"
    exit 0
}

# Step 5: Flutter setup
Step "Step 5/6 — Running flutter doctor + accepting Android licenses"
& "$FlutterRoot\bin\flutter.bat" config --no-analytics 2>&1 | Out-Null
& "$FlutterRoot\bin\flutter.bat" doctor
Write-Host ""
Write-Host "Accepting Android SDK licenses (answer 'y' to each prompt if it asks)..."
& "$FlutterRoot\bin\flutter.bat" doctor --android-licenses

# Step 6: Generate Android folder + build APK
Step "Step 6/6 — Creating Android project folder + building release APK"
Set-Location $ProjectDir
if (-not (Test-Path "$ProjectDir\android")) {
    & "$FlutterRoot\bin\flutter.bat" create . --org com.rachnakaar --project-name rachnakaar --platforms android
}
& "$FlutterRoot\bin\flutter.bat" pub get
& "$FlutterRoot\bin\flutter.bat" build apk --release

$apk = "$ProjectDir\build\app\outputs\flutter-apk\app-release.apk"
if (Test-Path $apk) {
    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Green
    Write-Host " SUCCESS! APK built." -ForegroundColor Green
    Write-Host " File: $apk" -ForegroundColor Green
    $size = [math]::Round((Get-Item $apk).Length / 1MB, 1)
    Write-Host " Size: $size MB" -ForegroundColor Green
    Write-Host ""
    Write-Host " To install on your phone:" -ForegroundColor Cyan
    Write-Host "  1. Plug phone via USB or share APK via WhatsApp/Drive"
    Write-Host "  2. On phone, open the APK file -> tap Install"
    Write-Host "  3. If 'Install blocked', go to Settings -> enable 'Install unknown apps'"
    Write-Host "============================================================" -ForegroundColor Green
} else {
    Warn "Build finished but APK not found at expected path. Check the flutter output above for errors."
}
