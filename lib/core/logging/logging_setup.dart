import 'package:logging/logging.dart';
import 'package:flutter/foundation.dart';

void setupLogging() {
  Logger.root.level = kDebugMode ? Level.ALL : Level.WARNING;
  Logger.root.onRecord.listen((record) {
    debugPrint(
      '${record.level.name}: ${record.time}: ${record.loggerName} • ${record.message}',
    );
  });
}
