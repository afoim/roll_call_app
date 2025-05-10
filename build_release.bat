@echo off
echo ========================================
echo        Roll Call App - Multi-platform Build Script
echo ========================================
echo.

:: Set output directory
set OUTPUT_DIR=%CD%\shell-output
echo Creating output directory: %OUTPUT_DIR%
if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"

:: Save current directory
set START_DIR=%CD%

echo Cleaning old build files...
call flutter clean

echo Getting dependencies...
call flutter pub get

echo.
echo ========================================
echo Building Web application...
echo ========================================
call flutter config --enable-web
call flutter build web --release --verbose
if %ERRORLEVEL% NEQ 0 (
  echo Web application build failed!
  exit /b %ERRORLEVEL%
)
echo Packaging Web application...
cd build\web
powershell -Command "Compress-Archive -Path * -DestinationPath '%OUTPUT_DIR%\RollCall-Web.zip' -Force"
cd %START_DIR%
echo Web application build completed!

echo.
echo ========================================
echo Building Windows application...
echo ========================================
call flutter config --enable-windows-desktop
call flutter build windows --release --verbose
if %ERRORLEVEL% NEQ 0 (
  echo Windows application build failed!
  exit /b %ERRORLEVEL%
)
echo Packaging Windows application...
cd build\windows\x64\runner\Release
powershell -Command "Compress-Archive -Path * -DestinationPath '%OUTPUT_DIR%\RollCall-Windows.zip' -Force"
cd %START_DIR%
echo Windows application build completed!

echo.
echo ========================================
echo Building Android APK...
echo ========================================
call flutter build apk --release --verbose
if %ERRORLEVEL% NEQ 0 (
  echo Android APK build failed!
  exit /b %ERRORLEVEL%
)
echo Copying Android APK to output directory...
copy /Y "build\app\outputs\flutter-apk\app-release.apk" "%OUTPUT_DIR%\RollCall.apk"
echo Android APK build completed!

echo.
echo ========================================
echo All builds completed! Output files are in %OUTPUT_DIR% directory
echo ========================================
echo File list:
dir /b "%OUTPUT_DIR%"

pause 