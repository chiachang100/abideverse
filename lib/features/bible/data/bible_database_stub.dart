import 'dart:io';

class BibleDatabase {
  static Future<BibleDatabase> open({Directory? directory}) async {
    throw UnsupportedError('SQLite is not supported on this platform.');
  }

  dynamic get database {
    throw UnsupportedError('SQLite is not supported on this platform.');
  }

  void dispose() {}
}
