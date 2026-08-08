import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

class BibleDatabase {
  BibleDatabase(this._database);

  final Database _database;

  Database get database => _database;

  static const assetPath = 'assets/bible/bible.sqlite';
  static const fileName = 'bible.sqlite';

  static Future<BibleDatabase> open({Directory? directory}) async {
    final dir = directory ?? await getApplicationSupportDirectory();
    final file = File('${dir.path}/$fileName');

    if (!await file.exists()) {
      final data = await rootBundle.load(assetPath);

      await file.writeAsBytes(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
        flush: true,
      );
    }

    return BibleDatabase(sqlite3.open(file.path, mode: OpenMode.readOnly));
  }

  void dispose() {
    _database.dispose();
  }
}
