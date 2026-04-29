#!/bin/bash

echo "Starting clean build process..."

echo "To run it:"
echo "clean_build"

echo "Switch to project directory"
cd ~/src/git/apps/abideverse

echo "Print current directory"
pwd

echo "1. Run Flutter clean"
flutter clean || echo "flutter clean failed, continuing...

echo "Delete directory"
rm -rf .dart_tool || echo "could not delete .dart_tool, continuing...

echo "2. Get the packages"
flutter pub get

echo "3. Localization Code Generation"
rm -rf lib/shared/localization
dart run easy_localization:generate -S assets/translations -O lib/shared/localization
dart run easy_localization:generate -S assets/translations -f keys -O lib/shared/localization -o locale_keys.g.dart

echo "4. Generate Splash Screen"
dart run flutter_native_splash:create

echo "5. Run build_runner"
dart run build_runner build --delete-conflicting-outputs

echo "6. Build `AbideVerse` for the cross platforms"
echo "6.1 Build Web"
flutter build web
#flutter build -v web --release

echo "6.2 Build Android"
flutter build apk

echo "6.3 Build iOS"
echo "Build iOS works only on macOS"
flutter build ios

echo "7. Run Tests"
flutter test

echo "8. Run `AbideVerse` Web App Locally with Web Server or Browser"
flutter run --dart-define-from-file=config.json -d web-server --web-port=5100

echo "9. Run `AbideVerse` Android App in Local Android Emulator"
echo "flutter run --dart-define-from-file=config.json -d emulator-5554"

echo "10. Run `AbideVerse` iOS App in Local iOS Simulator"
echo "flutter run --dart-define-from-file=config.json -d [iOS Simulator]"

echo "11. Serve and test `AbideVerse` with Firebase Hosting locally"
echo "firebase serve --only hosting"

echo "firebase deploy --only hosting"

echo "Clean build complement."
