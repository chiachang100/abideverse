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

echo "5. Build `AbideVerse` for the cross platforms"
echo "5.1 Build Web"
flutter build web
#flutter build -v web --release

echo "5.2 Build Android"
flutter build apk

echo "5.3 Build iOS"
echo "Build iOS works only on macOS"
flutter build ios

echo "6. Run Tests"
flutter test

echo "7. Run `AbideVerse` Web App Locally with Web Server or Browser"
flutter run -d web-server --web-port=5100

echo "8. Run `AbideVerse` Android App in Local Android Emulator"
echo "flutter run -d emulator-5554"

echo "9. Run `AbideVerse` iOS App in Local iOS Simulator"
echo "flutter run -d [iOS Simulator]"

echo "10. Serve and test `AbideVerse` with Firebase Hosting locally"
echo "firebase serve --only hosting"

echo "firebase deploy --only hosting"

echo "Clean build complement."
