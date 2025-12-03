# abideverse

**AbideVerse - Your Daily Bible Verse Companion**

_"你們要常在我裡面，我也常在你們裡面。" (約翰福音 15:4) “Abide in me, and I in you.”(John 15:4)._

## Getting Started

This project is a starting point for the AbideVerse App (abideverse).

---

## Project Setup

- `flutter create abideverse --org com.joyolord`
- `cd abideverse`

### Add Dependencies

- Add Dev Dependencies for Router and Riverpod code generation

  - `flutter pub add go_router`

  - `flutter pub add flutter_riverpod riverpod_annotation`
  - `flutter pub add --dev riverpod_generator`
  - `flutter pub add hooks_riverpod flutter_hooks`
  - `flutter pub add google_fonts shared_preferences equatable`

- Add more Dev Dependencies
- `flutter pub add --dev build_runner custom_lint`

### Useful Tools

- `flutter clean`
- `flutter test`
- `flutter build -v web --release`
- `flutter upgrade`
- `flutter pub get`

---

## Adding Firebase Support

### Install and update the Firebase CLI

- `npm install -g firebase-tools`
- `firebase --version`

- Install the core plugin and the Firebase AI Logic plugin:
- The recommended, secure SDK for client-side Gemini access
  - `flutter pub add firebase_core firebase_auth firebase_ai`

### Firebase Login

- `firebase logout`
- `firebase login`
  - **Enable Gemini in Firebase features?** Yes
  - **Allow Firebase to collect CLI and Emulator Suite usage and error reporting information? (Y/n)** Yes
  -

```
  Woohoo! Firebase CLI Login Successful

  Success! Logged in as chiachang100@gmail.com
```

### Add Firebase Packages

- `flutter pub add firebase_core cloud_firestore firebase_auth`
- `flutter pub get`

### Install the FlutterFire CLI

- `dart pub global activate flutterfire_cli`

- Add FlutterFire to your system PATH
  - On Windows, add this to your PATH:
    - `C:\Users\<YourUsername>\AppData\Local\Pub\Cache\bin`
  - On macOS/Linux, add this to your shell profile (e.g., .bashrc, .zshrc):
    - `export PATH="$PATH":"$HOME/.pub-cache/bin"`
  - hen restart your terminal or run source ~/.bashrc (or equivalent) to apply the changes.
- Verify Installation
  - `flutterfire --version`

### From Firebase Console: Add the support for iOS, Android, and Web

- From browser, access `https://console.firebase.google.com/`
- Add iOS, Android, and Web

### Auto-generate firebase_options.dart

- `flutterfire configure`

```
✅ Choose your Firebase project (AbideVerse)
✅ Select the platforms (Web, iOS, Android)
✅ This command will create a file:

lib/firebase_options.dart


This file safely stores your config (apiKey, projectId, etc.) and is automatically imported above.
```

### Test Firebase Connection

- Serve and test your Firebase project locally
  - `firebase serve --only hosting`
- To deploy to your site to firebase hosting:

  - `firebase deploy --only hosting`

- Edit your `lib/app/app.dart` and add a small test call:

```
import 'package:cloud_firestore/cloud_firestore.dart';

  Future<void> _testFirestore() async {
    final doc = await FirebaseFirestore.instance.collection('test').doc('ping').get();
    debugPrint('Firestore connected: ${doc.exists}');
  }


  @override
  Widget build(BuildContext context) {
    _testFirestore(); // test connection
    return MaterialApp(
...

```

- Then in the Firebase Console → Firestore Database → Start in test mode
  → Create a collection test, add a doc ping.

  - Click `+ Start collection`
    - Collection: `test`
    - Document ID: `ping`
    - Field: `ok`
    - Type: `boolean`
    - String: `true`

- You should see in your Flutter logs:

```
Firestore connected: true
```

- Firebase is now working!

---

## Full Deployment Build

1. Clean the workspace

- `flutter clean`

2. Get the packages

- `flutter pub get`

3. Localization Code Generation

- `dart run easy_localization:generate -S assets\translations -O lib/shared/localization`
- `dart run easy_localization:generate -S assets\translations -f keys -O lib/shared/localization -o locale_keys.g.dart`

4. Generate Splash Screen

- `dart run flutter_native_splash:create`

```
- pubspec.yaml
flutter_native_splash:
  color: "#E6EBEB" #light
  #color: "#241E30" #dark
  image: "assets/logos/abideverse_splash_logo.png"
  web_image_mode: center
  android_gravity: center
  ios_content_mode: center
```

5. Run Tests

- `flutter test`

6. Run `AbideVerse` Web App Locally with Web Server or Browser

- `flutter build web`
- `flutter run -d web-server --web-port=5100`
- OR `flutter run -d chrome --web-port=5100`

  - Web: `flutter run -d web-server --web-hostname=192.168.1.100 --web-port=5100`

7. Run `AbideVerse` Android App in Local Android Emulator

- `flutter build apk`
- `flutter run -d emulator-5554`

8. Run `AbideVerse` iOS App in Local iOS Simulator

- You have to use a macOS to ruilb iOS App.
- `flutter build ios`
- `flutter run -d [iOS Simulator]`

9. Serve and test `AbideVerse` with Firebase Hosting locally

- Build and test Firebase Hosting locally
- `flutter build -v web --release`
- `firebase serve --only hosting`
- Deploy to Firebase manually
- `firebase deploy --only hosting`
  - Local server: `http://localhost:5000`

10. Check the Code into GitHub

- `git status`
- `git add .`
- `git commit -m "New checkin"`
- `git push`

11. Check the Auto Deployment via GitHub Action

- Please use your web browser to visit: `https://github.com/chiachang100/abideverse/actions`

12. Final Check `AbideVerse`

- Please use your web browser to visit: `https://abideverse.web.app`.

---

## Firebase Deployment Instructions

1. Get Your Gemini API Key

- Go to [Google AI Studio](https://aistudio.google.com/api-keys)
- `Create API key` for Gemini Pro
- Replace YOUR_GEMINI_API_KEY in gemini_service.dart

1. Firebase Setup Commands

- Install Firebase CLI
  - `npm install -g firebase-tools`
- Login to Firebase
  - `firebase login`
- Configure Flutter for Firebase
  - `dart pub global activate flutterfire_cli`
  - `flutterfire configure`

### Deploy to Firebase Hosting (for web)

- `flutter build web`
- `firebase deploy`

### Run the App

- Install dependencies

  - `flutter pub get`

- Run on device/emulator

  - `flutter run -d web-server --web-port=5100`

- Build for production
  - `flutter build apk`
  - `flutter build ios`
  - `flutter build web`

---

## Add Google's Firebase AI Logic

### Setup Gemini Developer API

Gemini Developer API is recommended for first-time users.

- Sign Up Gemini Developer API
  - Enable the Gemini Developer API
  - Enable AI monitoring (optional)
  - Add the Firebase AI Logic SDK

---

## Miscellaneous

### Flutter Useful Commands

- `flutter pub outdated`
- To update:
  - Edit `pubspec.yaml`
  - OR run: `flutter pub upgrade --major-versions`

### Change the domain name of Android, iOS, and acOmS

- cd to the root folder
  - `cd abideverse`
- Remove Android, iOS, macOS folders
  - `rm -rf android`
  - `rm -rf ios`
  - `rm -rf macos`
- Recreate Android, iOS, macOS
  - `flutter create . --org com.joyolord`

---

### For Secrets or Keys (e.g., Gemini API key)

Never hardcode them in the source code. Instead:

1. Use `.env` files with `flutter_dotenv` package.

1. Install `flutter_dotenv` package.

- `flutter pub add flutter_dotenv`

```
pubspec.yaml
dependencies:
  flutter_dotenv: ^5.1.0
```

1. Create `.env` file in your root directory

```
GEMINI_API_KEY=your_secret_key_here
```

1. Create `lib/config/env.dart` file:

```
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
}
```

1. Initialize in `main.dart`

```
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}
```

1. Use it anywhere:

```
import 'package:abideverse/config/env.dart';

print(Env.geminiApiKey);
```

---

### Create a config.dart file

1. Create a file in your project like: `lib/config/app_config.dart`

1. Define your constants

```
// lib/config/app_config.dart

class AppConfig {
  static const String appName = "abideverse";
  static const String version = "1.0.0";

  // Firebase collections
  static const String usersCollection = "users";
  static const String versesCollection = "verses";
  static const String quizzesCollection = "quizzes";

  // Google Gemini model
  static const String geminiModel = "gemini-1.5-pro";

  // Feature toggles
  static const bool enableAIHints = true;
  static const bool enableVerseCompletion = true;
}
```

1. Use it anywhere in your app

```
import 'package:abideverse/config/app_config.dart';

print(AppConfig.appName);
FirebaseFirestore.instance.collection(AppConfig.usersCollection);
```

---

### Why You Shouldn’t Commit .env

- Your `.env` file often contains:

  - API keys (e.g., Gemini, Firebase, OpenAI)
  - Database URLs
  - Secrets, tokens, and other private credentials

- If you push it to GitHub (especially in a public repo), those credentials can be harvested by bots within seconds — even if you delete it later.
  Google, Firebase, and OpenAI keys are automatically scanned by their services and may be revoked immediately when leaked.

#### Best Practice Setup

1. Add `.env` to `.gitignore`
   At your project root, in `.gitignore`:

```
# Environment files
.env
.env.*
```

This ensures Git ignores them completely.

1. Create a `.env.example` File

- You do want to check in a template for teammates or CI/CD.
- Example:

```
# .env.example
GEMINI_API_KEY=your_api_key_here
FIREBASE_PROJECT_ID=your_project_id_here
```

This shows others what keys are expected, but contains no real values.

1. Share Securely

- Share the real `.env` file only through:
  - Private channels (e.g., `1Password`, `Bitwarden`, `Google Secret Manager`)
- CI/CD secrets (e.g., `GitHub Actions → “Repository Settings → Secrets”`)
- Encrypted messaging or team vaults (never email or chat attachments)

1. Use CI/CD Secrets for Production Builds

- If you build or deploy with `GitHub Actions`, `Firebase Hosting`, or `Google Cloud`, you can inject secrets safely.
  - Example (GitHub Actions):

```
env:
  GEMINI_API_KEY: ${{ secrets.GEMINI_API_KEY }}
```

Your Flutter app can then read it via `--dart-define`:

- `flutter build apk --dart-define=GEMINI_API_KEY=$GEMINI_API_KEY`

**NOTE:** If you ever accidentally committed your `.env` before adding it to `.gitignore`:

- `git rm --cached .env`
- `git commit -m "Remove .env from tracking"`

Then push again — the file will stay local but not be tracked anymore.

---

---

### Flutter Packages

#### YouTube Player packages: youtube_player_flutter, flutter_inappwebview, and youtube_player_iframe

- [youtube_player_flutter](youtube_player_flutter)
  - `flutter pub add youtube_player_flutter`
  - `youtube_player_flutter` depends on `flutter_inappwebview`
    - [flutter_inappwebview](https://pub.dev/packages/flutter_inappwebview)
      - `flutter pub add flutter_inappwebview`
    - [flutter_inappwebview: Getting Started](https://inappwebview.dev/docs/intro/)
  - NOTE:
    - For Android & iOS: it seems to work fine.
    - For Web: it didn't work. The follow errors were thrown:

```
"Error: UnimplementedError: addJavaScriptHandler is not implemented on the current platform."
...
```

- [youtube_player_iframe](https://pub.dev/packages/youtube_player_iframe)
  - [Depends on webview_flutter (Android & iOS)](https://pub.dev/packages/webview_flutter)
- [Material Icons](https://fonts.google.com/icons)
- [flutter_native_splash](https://pub.dev/packages/flutter_native_splash)

  - After adding your settings to pubspec.yaml, run the following command in the terminal:
    - `dart run flutter_native_splash:create`

- IMPORTANT NOTES:
  - For Web: use `youtube_player_iframe`.
  - For Android and iOS: use `youtube_player_flutter` and `flutter_inappwebview`.

---

## Add Firebase to your Flutter app

- Source: [Add Firebase to your Flutter app](https://firebase.google.com/docs/flutter/setup?platform=android#available-plugins)

### Prequisites

- Install IDE.
- Set up a device or emulator.
- Install FLuter.
- [Install the Firebase CLI](https://firebase.google.com/docs/cli#setup_update_cli).
- Sign into Firebase.

### Step 1: Install the required command line tools

- `firebase login`
- Insall the FlutterFire CLI
  - `dart pub global activate flutterfire_cli`

### Step 2: Configure your apps to use Firebase

- `flutterfire configure -i com.joyolord.abideverse -a com.joyolord.abideverse`
  - Select the platforms (iOS, Android, Web) in your Flutter app.
  - Create a Firebase configuration file
    - `lib/firebase_options.dart`

### Step 3: Initialize Firebase in your app

- From your Flutter project, install the core plugin:
  - `flutter pub add firebase_core`
- From your Flutter project, ensure your Flutter app's Firebase configuration is up-to-date
  - `flutterfire configure -i com.joyolord.app.abideverse -a com.joyolord.app.abideverse`

```
✔ Which platforms should your configuration support (use arrow keys & space to select)? · android, ios, web
i Firebase android app com.joyolord.xlcdapp registered.
i Firebase ios app com.joyolord.xlcdapp registered.
i Firebase web app abideverse (web) registered.

Firebase configuration file lib\firebase_options.dart generated successfully with the following Firebase apps:

Platform  Firebase App Id
web       1:613422672008:web:b2ccf3a963676d8a25573d
android   1:613422672008:android:35cf1831d54b20fc25573d
ios       1:613422672008:ios:7c5735d8ef3e17a325573d
```

- In your `lib/main.dart` file, import Firebase core plugin and the configuration file you generated earlier:

```
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
```

- Also in your lib/main.dart file, initialize Firebase using teh **DefaultFirebaseOptions** object

```
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

- Rebuild your Flutter application
  - `flutter pub get`
  - Web: `flutter run -d web-server --web-port=5100`
  - Web: `flutter run -d chrome --web-hostname=192.168.1.100 --web-port=5100`
  - Android Emulator: `flutter run -d emulator-5554`
  - iOS Simulator: `flutter run -d [TBS]`

### Step 4: Add Firebase plugins

- From your Flutter project directory, run the following commands:
  - `flutter pub add firebase_analytics`
  - `flutter pub add firebase_auth`
  - `flutter pub add cloud_firestore`
- From your Flutter project, ensure your Flutter app's Firebase configuration is up-to-date
  - `flutterfire configure -i com.joyolord.app.abideverse -a com.joyolord.app.abideverse`
- Rebuild your Flutter application
  - `flutter pub get`
  - Web: `flutter run -d chrome --web-port=5100`
  - Android Emulator: `flutter run -d emulator-5554`
  - iOS Simulator: `flutter run -d [TBS]`

### Step 5: Add Firebase Hosting

- Source: [Firebase CLI reference](https://firebase.google.com/docs/cli)
- Install Node.js using NVM (Node Version Manager))
  - Linux/MacOS: [Node Version Manager](https://github.com/nvm-sh/nvm)
  - Windows: [nvm-windows](https://github.com/coreybutler/nvm-windows).
- Install Firebase tools
  - `npm install -g firebase-tools`
- Log into Firebase
  - `firebase login`
- [Use the CLI with CI systems](https://firebase.google.com/docs/cli#cli-ci-systems)
  - `firebase login:ci`
- Listing your Firebase projects
  - `firebase projects:list`
- Initialize a Firebase project
  - Run the following command from within your app's directory:
  - `firebase init`
  - It will create `firebase.json` config file.
- Use project aliases
  - `firebase use`
  - `firebase use xlcdapp (<PROJECT_ID|ALIAS>)`
- Serve and test your Firebase project locally
  - `flutter build -v web --release`
  - `firebase serve --only hosting`
- Test from other local devices
  - `firebase serve --host 0.0.0.0  --only hosting` // accepts requests to any host
- Deploy to a Firebase project
  - `firebase deploy`
  - OR `firebase deploy --only hosting`

---

## Add Firebase packages for iOS

- Firebase iOS SDK
  - Using [Swift Package Manager](https://github.com/firebase/firebase-ios-sdk/blob/main/SwiftPackageManager.md).
  - Installing from Xcode
  - Add a package by selecting File → Add Packages… in Xcode’s menu bar.
  - Search for the Firebase Apple SDK using the repo's URL:
    - `https://github.com/firebase/firebase-ios-sdk.git`
  - Next, set the Dependency Rule to be Up to Next Major Version.
    - Then, select Add Package.
    - Choose the Firebase products that you want installed in your app.
    - If you've installed FirebaseAnalytics, add the `-ObjC` option to Other Linker Flags in the Build Settings tab.
- Flutterfire iOS SDK
  - Follow the instructions describe in the **Firebase iOS SDK** section with the follow repo's URL:
    - `https://github.com/firebase/flutterfire.git`

---

## Store key-value data on disk

- [Store key-value data on disk](https://docs.flutter.dev/cookbook/persistence/key-value)
- `flutter pub add shared_preferences`

## Setup firebaseServiceAccount on GitHub

- Follow the following instructions to setup `firebaseServiceAccount` on GitHub for `.github/workflow/firebase-hosting-merge.yml`:
- [Firebase Hosting with GitHub Actions. Prachit Suhas Patil](https://dev.to/pprachit09/firebase-hosting-with-github-actions-55ka)

```
        firebaseServiceAccount: '${{ secrets.FIREBASE_SERVICE_ACCOUNT_ABIDEVERSE }}'
```

### Generate Firebase Service Account

- Console > project > Project settings > Service accounts
  - `https://console.firebase.google.com/project/abideverse/settings/serviceaccounts/adminsdk`
    - Generate new private key > Generate Key
    - A new JSON key file will be downloaded.
- GitHub

  - Go to `Settings` tab of your repository.
  - Select `Secrets and variables > Actions` from the left menu.
  - From Actions secrets and variables, select `Secrets > Repository secrets` tab, click `New repository secret`.
    - Name: `FIREBASE_SERVICE_ACCOUNT_ABIDEVERSE`
    - Secret: Paste the JSON key file.

- Example of the JSON (structure only)
  It will look something like this (your actual values will differ):

```
json
{
  "type": "service_account",
  "project_id": "your-project-id",
  "private_key_id": "abcdef1234567890abcdef1234567890abcdef12",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEv...snip...\n-----END PRIVATE KEY-----\n",
  "client_email": "firebase-adminsdk-xyz@your-project-id.iam.gserviceaccount.com",
  "client_id": "123456789012345678901",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-xyz%40your-project-id.iam.gserviceaccount.com"
}
```

- ⚠️ Important Notes
  - Do not edit the JSON — paste it exactly as downloaded.
  - Keep line breaks in the private key (\n markers are correct).
  - Paste the entire JSON into the GitHub Secret named:

```
Code
FIREBASE_SERVICE_ACCOUNT_ABIDEVERSE
GitHub Secrets expect raw JSON text, not YAML.
Make sure GitHub doesn’t add --- or dashes at the start.
```

---

## Youtube Player plugins

- Use `youtube_player_flutter`
- `flutter pub add youtube_player_flutter`

- Use `youtube_player_iframe`
- `flutter pub add youtube_player_iframe`

---

## Local Firebase Emulator

- [Get Started with Firebase Authentication on Flutter](https://firebase.google.com/docs/auth/flutter/start)

- Start Emulator
  - `firebase emulators:start`

---

## Troubleshooting

### Troubleshooting on iOS

- Error: `Module 'flutter_inappwebview_ios' not found`
  - `flutter clean`
  - `flutter pub get`
- Error: `Error (Xcode): redefinition of module 'Firebase'`

```
Error (Xcode): redefinition of module 'Firebase'
/Users/chiachang/src/git/chiachang100/xlcdapp/ios/Pods/Firebase/CoreOnly/Sources/module.modulemap:0:7
```

- `vi /Users/chiachang/src/git/chiachang100/xlcdapp/ios/Pods/Firebase/CoreOnly/Sources/module.modulemap`
- Replace `module Firebase` with `module FirebaseCoreOnly`

```
module FirebaseCoreOnly {
  export *
  header "Firebase.h"
}
```

---

## Add Change Notification

- [Simple app state management](https://docs.flutter.dev/data-and-backend/state-mgmt/simple)

  - With provider, you need to understand 3 concepts:
    - ChangeNotifier
    - ChangeNotifierProvider
    - Consumer

- `flutter pub add provider`
- `import 'package:provider/provider.dart';`

---

## Internationalizing (I18N) Flutter apps

- [Internationalizing Flutter apps](https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization)

  - [flutter_localizations]()
  - [intl](https://pub.dev/packages/intl)
  - [intl_translation](https://pub.dev/packages/intl_translation)

- `flutter pub add flutter_localizations --sdk=flutter`
- `flutter pub add intl:any`
- `flutter pub add intl_translation`

---

Copyright 2024 Chia Chang. Apache License, Version 2.0 (the "License").

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

Copyright 2021, the Flutter project authors. Please see the AUTHORS file
for details. All rights reserved. Use of this source code is governed by a
BSD-style license that can be found in the LICENSE file.

---

- Convert PNG file to animated PNG (APNG) or GIF file.
- [Ezgif](https://ezgif.com/)
  - First create 4 images:
    1. one straight up
    2. one rotated 90 degrees
    3. one rortated 180 degrees
    4. on rotated counter-clock 90 degrees
  - Upload the above four images and arrange the order of them correctly.
  - Generate an animated PNG file and convert it to a GIF file.

---

### easy_localization

- [easy_localization](https://pub.dev/packages/easy_localization)
  - [easy_localization](https://github.com/aissat/easy_localization)
- [easy_localization_loader](https://pub.dev/packages/easy_localization_loader)

  - [easy_localization_loader](https://github.com/aissat/easy_localization_loader)

- `flutter pub add easy_localization`
- Add to your package's `pubspec.yaml` (and run an implicit `flutter pub get`)

```
dependencies:
  easy_localization: ^3.0.7
```

- Create a folder and add translation files:
  - assets
    - translations
      - en.json
      - en-US.json
      - zh.json # same as zh-TW.json
      - zh-CN.json
      - zh-TW.json
- Declare the assets localization directory in `pubsec.yaml`
  - flutter:
    assets: - assets/translations/

```
import 'package:easy_localization/easy_localization.dart';
```

## Code generation

- [easy_localization: Code generation](https://pub.dev/packages/easy_localization)
- `dart run easy_localization:generate -h`
- `dart run easy_localization:generate -S assets\translations -O lib/shared/localization`

```
import 'l10n/codegen_loader.g.dart';
```

- `dart run easy_localization:generate -S assets\translations -f keys -O lib/shared/localization -o locale_keys.g.dart`

- Add supported locales to the `ios/Runner/Info.plist` file

```
		<key>CFBundleLocalizations</key>
		<array>
			<string>en</string>
			<string>en-US</string>
			<string>zh</string>
			<string>zh-CN</string>
			<string>zh-TW</string>
		</array>
```

---

## Misc Configurations

- Add the following in `android/app/build.gradle`

```
dependencies {
    ...
    implementation 'com.android.support:multidex:1.0.3'
}
```

- Add the following in `android/app/build.gradle`

```
defaultConfig {
    ...
    multiDexEnabled true
}
```

---

## Access Package Version

- Access `pubspec.yaml`
- [package_info_plus](https://pub.dev/packages/package_info_plus/install)

  - `flutter pub add package_info_plus`

- [pubspec_parse](https://pub.dev/packages/pubspec_parse)
  - [pubspec_parse@GitHub](https://github.com/dart-lang/pubspec_parse)
  - [Pubspec class](https://pub.dev/documentation/pubspec_parse/latest/pubspec_parse/Pubspec-class.html)
- `flutter pub add pubspec_parse`

```
import 'dart:io';
import 'package:pubspec_parse/pubspec_parse.dart';

final pubspecFile = File('pubspec.yaml').readAsStringSync();
final pubspec = Pubspec.parse(pubspecFile);
final appName = pubspec.name;
final appVersion = pubspec.version.toString();
```

---

## Resources

### Flutter

- [Flutter orientation lock: portrait only](https://greymag.medium.com/flutter-orientation-lock-portrait-only-c98910ebd769)
- [Flutter website](https://flutter.dev/)
- [Flutter samples](https://flutter.github.io/samples/#)
  - [Flutter samples: Navigation and Routing](https://flutter.github.io/samples/navigation_and_routing.html)
  - [How to add a YouTube video to your Flutter app? by
    Walnut Software](https://walnutistanbul.medium.com/how-to-add-a-youtube-video-to-your-flutter-app-40c0125414ba)
- [Internationalizing Flutter apps](https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization)
- [Store key-value data on disk](https://docs.flutter.dev/cookbook/persistence/key-value)
- [Simple app state management](https://docs.flutter.dev/data-and-backend/state-mgmt/simple)
- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)
- [Flutter online documentation](https://docs.flutter.dev/), which offers tutorials,
  samples, guidance on mobile development, and a full API reference.
- [Compile to WebAssembly rather than JavaScript](https://flutter.dev/to/wasm).

### Tools

- [go_router: Routing package for Flutter](https://pub.dev/packages/go_router)
- [Riverpod: Statement management](https://riverpod.dev/)
  - [riverpod_generator](https://pub.dev/packages/riverpod_generator)

### "笑裡藏道"

- [靈糧書房購買"笑裡藏道"書籍](https://www.rolcc.net/opencart/index.php?route=product/product&product_id=358)
- [笑裡藏道書籍作者曾興才牧師講道視頻@YouTube](https://www.youtube.com/results?search_query=%22%E6%9B%BE%E8%88%88%E6%89%8D%E7%89%A7%E5%B8%AB%22)
- [笑裡藏道](https://xlcdapp.web.app/)

---
