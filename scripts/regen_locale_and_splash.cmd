REM 3. Localization Code Generation
cmd/c rm -rf lib/shared/localization/*
cmd/c dart run easy_localization:generate -S assets\translations -O lib/shared/localization
cmd/c dart run easy_localization:generate -S assets\translations -f keys -O lib/shared/localization -o locale_keys.g.dart

REM 4. Generate Splash Screen
REM cmd/c dart run flutter_native_splash:create
