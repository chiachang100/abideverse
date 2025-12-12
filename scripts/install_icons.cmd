@echo off
setlocal

echo ===============================================
echo   Flutter Icon Installer (Windows CMD)
echo   Copies generated icons into your project
echo ===============================================

REM -------- CONFIG --------
set SRC_DIR=generated_icons
REM set FLUTTER_DIR=%cd%\your_flutter_project
set FLUTTER_DIR=C:\src\git\apps\abideverse

echo Source Icons: %SRC_DIR%
echo Target Flutter Project: %FLUTTER_DIR%
echo.

REM -------- Validate Paths --------
if not exist "%SRC_DIR%" (
    echo ERROR: Folder "%SRC_DIR%" not found!
    pause
    exit /b
)

if not exist "%FLUTTER_DIR%" (
    echo ERROR: Flutter project folder "%FLUTTER_DIR%" not found!
    echo Edit the script to set the correct FLUTTER_DIR.
    pause
    exit /b
)

REM -------- iOS --------
echo Copying iOS icons...
set IOS_TARGET=%FLUTTER_DIR%\ios\Runner\Assets.xcassets\AppIcon.appiconset
if not exist "%IOS_TARGET%" mkdir "%IOS_TARGET%"
xcopy "%SRC_DIR%\ios\AppIcon.appiconset\*" "%IOS_TARGET%\" /Y /Q

REM -------- Android --------
echo Copying Android mipmap icons...
xcopy "%SRC_DIR%\android\mipmap-mdpi" "%FLUTTER_DIR%\android\app\src\main\res\mipmap-mdpi" /E /Y /Q
xcopy "%SRC_DIR%\android\mipmap-hdpi" "%FLUTTER_DIR%\android\app\src\main\res\mipmap-hdpi" /E /Y /Q
xcopy "%SRC_DIR%\android\mipmap-xhdpi" "%FLUTTER_DIR%\android\app\src\main\res\mipmap-xhdpi" /E /Y /Q
xcopy "%SRC_DIR%\android\mipmap-xxhdpi" "%FLUTTER_DIR%\android\app\src\main\res\mipmap-xxhdpi" /E /Y /Q
xcopy "%SRC_DIR%\android\mipmap-xxxhdpi" "%FLUTTER_DIR%\android\app\src\main\res\mipmap-xxxhdpi" /E /Y /Q

REM Play Store icon (optional)
copy "%SRC_DIR%\android\ic_playstore_512x512.png" "%FLUTTER_DIR%\" >nul
if exist "%SRC_DIR%\android\ic_playstore_512x512.png" (
    copy "%SRC_DIR%\android\ic_playstore_512x512.png" "%FLUTTER_DIR%\" >nul
)

REM -------- Web / PWA --------
echo Copying Web + PWA icons...
if not exist "%FLUTTER_DIR%\web\icons" mkdir "%FLUTTER_DIR%\web\icons"
xcopy "%SRC_DIR%\web\icons" "%FLUTTER_DIR%\web\icons" /E /Y /Q
xcopy "%SRC_DIR%\web\favicon-*.png" "%FLUTTER_DIR%\web" /Y /Q

REM Don't copy manifest.json, use the existing one.
REM echo Updating manifest.json...
REM copy "%SRC_DIR%\web\manifest.json" "%FLUTTER_DIR%\web\manifest.json" >nul

echo.
echo ===============================================
echo           ALL ICONS INSTALLED!
echo ===============================================
echo iOS icons → ios/Runner/Assets.xcassets/AppIcon.appiconset/
echo Android icons → android/app/src/main/res/mipmap-*/
echo Web/PWA icons → web/ + web/icons/
echo.
pause
