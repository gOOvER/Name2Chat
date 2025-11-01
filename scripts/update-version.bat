@echo off
REM Development script to update version in TOC file for Windows
REM Usage: scripts\update-version.bat 3.5.6

if "%1"=="" (
    echo Usage: %0 ^<version^>
    echo Example: %0 3.5.6
    exit /b 1
)

set VERSION=%1

REM Update version in TOC file (Windows PowerShell approach)
powershell -Command "(Get-Content Name2Chat.toc) -replace '@project-version@', '%VERSION%' | Set-Content Name2Chat.toc"

echo Updated Name2Chat.toc version to: %VERSION%
echo Updated line:
findstr "## Version:" Name2Chat.toc

REM Verify the change
findstr "## Version: %VERSION%" Name2Chat.toc >nul
if %errorlevel%==0 (
    echo ✅ Version successfully updated to %VERSION%
) else (
    echo ❌ Failed to update version. Current version line:
    findstr "## Version:" Name2Chat.toc
)