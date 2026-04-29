REM flutter run -d web-server --web-port=5100
REM flutter build web --wasm
flutter run --dart-define-from-file=config.json -d web-server --web-port=5100 --wasm
