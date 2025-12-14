REM To run it:
REM cmd /c build_clean.cmd

@echo off
REM Switch to project directory
cd /d C:\src\git\apps\abideverse

REM Print current directory
owd

@echo 1. Run Flutter clean
flutter clean || echo flutter clean failed, continuing...

REM Delete directory (cmd version of rm -rf)
rmdir /s /q .dart_tool || echo could not delete .dart_tool, continuing...

REM 2. Get the packages
flutter pub get

REM 3. Localization Code Generation
dart run easy_localization:generate -S assets\translations -O lib/shared/localization
dart run easy_localization:generate -S assets\translations -f keys -O lib/shared/localization -o locale_keys.g.dart

REM 4. Generate Splash Screen
dart run flutter_native_splash:create

REM 5. Run Tests
flutter test

REM 6. Run `AbideVerse` Web App Locally with Web Server or Browser
flutter build web
REM flutter run -d web-server --web-port=5100

REM 7. Run `AbideVerse` Android App in Local Android Emulator
flutter build apk
REM flutter run -d emulator-5554

REM 8. Run `AbideVerse` iOS App in Local iOS Simulator
REM flutter build ios
REM flutter run -d [iOS Simulator]

REM 9. Serve and test `AbideVerse` with Firebase Hosting locally
flutter build -v web --release
firebase serve --only hosting

REM firebase deploy --only hosting

echo Done.
pause
