# ==============================
# Build and Send Flutter APK Script
# ==============================

# Check if a project name is passed as an argument
if (-not $args[0]) {
    Write-Host "Error: Please provide a project name."
    exit 1
}

# Define the base path for your projects
Write-Host "Setting up project paths..."
$PROJECTS_PATH = "C:\flutter_dev\projects"
$PROJECT_NAME = $args[0]
$PROJECT_DIR = "$PROJECTS_PATH\$PROJECT_NAME"

Write-Host "Project: $PROJECT_NAME"
Write-Host "Path: $PROJECT_DIR"

# Check if the project directory exists
if (-not (Test-Path $PROJECT_DIR)) {
    Write-Host "Error: Project directory '$PROJECT_DIR' does not exist."
    exit 1
}

# Navigate to the project directory
Write-Host "Navigating to project directory..."
Set-Location -Path $PROJECT_DIR

# Extract the current version from pubspec.yaml
Write-Host "Extracting current version..."
$version_line = (Select-String -Pattern "^version: " pubspec.yaml).Line
$version_line = $version_line -replace "version: ", ""

# Separate version and build number
$version_parts = $version_line -split "\+"
$current_version = $version_parts[0]
$current_build_number = [int]$version_parts[1]

# Increment the build number
$new_build_number = $current_build_number + 1
Write-Host "Incremented build number to $new_build_number"

# Increment the patch version
$version_tokens = $current_version -split "\."
$major_version = $version_tokens[0]
$minor_version = $version_tokens[1]
$patch_version = [int]$version_tokens[2] + 1

# Construct the new version string
$new_version = "$major_version.$minor_version.$patch_version"
$new_full_version = "$new_version+$new_build_number"
Write-Host "New version set to $new_full_version"

# Update the version in pubspec.yaml
Write-Host "Updating pubspec.yaml..."
(Get-Content pubspec.yaml) | ForEach-Object {
    if ($_ -match "^version: ") {
        "version: $new_full_version"
    } else {
        $_
    }
} | Set-Content pubspec_temp.yaml

Move-Item -Force pubspec_temp.yaml pubspec.yaml

Write-Host "Version updated successfully"

# Run flutter pub get and build the release APK
Write-Host "Running flutter pub get and building APK..."
flutter pub get
flutter build apk --release

# Locate the generated APK
$APK_DIR = "$PROJECT_DIR\build\app\outputs\flutter-apk"
$ORIGINAL_APK = "$APK_DIR\app-release.apk"

if (-not (Test-Path $ORIGINAL_APK)) {
    Write-Host "Error: APK file not found at '$ORIGINAL_APK'."
    exit 1
}

# Rename the APK file to include the project name and version
$NEW_APK_NAME = "${PROJECT_NAME}_${new_full_version}.apk"
$NEW_APK_PATH = "$APK_DIR\$NEW_APK_NAME"

Write-Host "Renaming APK to $NEW_APK_NAME..."
Rename-Item -Path $ORIGINAL_APK -NewName $NEW_APK_NAME

if (Test-Path $NEW_APK_PATH) {
    Write-Host "APK successfully renamed to '$NEW_APK_NAME'."
} else {
    Write-Host "??? Error: Failed to rename APK."
    exit 1
}

Write-Host "Build and renaming completed for project: $PROJECT_NAME"

# ==============================
# ??? Telegram Send Section
# ==============================

# Optional 2nd argument: Telegram username
$telegram_user = if ($args.Count -ge 2) { $args[1] } else { $null }

# Define paths
$python_script_path = "C:\Users\Abel Seyoum\PycharmProjects\pythonProject\main.py"
$python_interpreter = "C:\Users\Abel Seyoum\PycharmProjects\pythonProject\venv\bin\python.exe"

# Helper: check if user is active (machine unlocked)
function Is-UserPresent {
    try {
        $session = (quser 2>$null | Select-String "$env:USERNAME")
        return ($session -ne $null)
    } catch {
        return $false
    }
}
# Function to show Windows toast notification
function Show-Notification {
    param(
        [string]$Title,
        [string]$Message
    )

    try {
        Add-Type -AssemblyName System.Windows.Forms
        $notify = New-Object System.Windows.Forms.NotifyIcon
        $notify.Icon = [System.Drawing.SystemIcons]::Information
        $notify.BalloonTipTitle = $Title
        $notify.BalloonTipText = $Message
        $notify.Visible = $true
        $notify.ShowBalloonTip(5000)
    } catch {
        Write-Host "?????? Notification failed to display: $Message"
    }
}

# Ask user if not provided
if (-not $telegram_user) {
    if (Is-UserPresent) {
        $telegram_user = Read-Host "Enter the Telegram username to send the APK to"
    } else {
        Show-Notification -Title "Build Completed" -Message "Project '$PROJECT_NAME' built successfully. Telegram username needed to send APK."
        Write-Host "?????? No user present; Telegram send skipped."
        exit 0
    }
}

# Proceed with sending
Write-Host "???? Sending APK to Telegram user '$telegram_user'..."
try {
    & $python_interpreter $python_script_path --recipient $telegram_user --file "$NEW_APK_PATH"
    Write-Host "??? APK sent successfully to Telegram user: $telegram_user"
} catch {
    if (Is-UserPresent) {
        Write-Host "???Telegram send failed, possibly needs password. Please check manually."
    } else {
        Show-Notification -Title "Action Required" -Message "Telegram send failed for '$PROJECT_NAME'. User input may be required."
    }
}

Write-Host "Build process completed."

