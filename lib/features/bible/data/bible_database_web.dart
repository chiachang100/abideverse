import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:sqlite3/common.dart';
import 'package:sqlite3/wasm.dart';

class BibleDatabase {
  BibleDatabase(this._database, this._sqlite);

  final CommonDatabase _database;
  final WasmSqlite3 _sqlite;

  CommonDatabase get database => _database;

  static Future<BibleDatabase> open({Directory? directory}) async {
    try {
      debugPrint('[BibleDatabase] Loading sqlite3.wasm...');

      final sqlite = await WasmSqlite3.loadFromUrlString('sqlite3.wasm');

      debugPrint('[BibleDatabase] sqlite3.wasm loaded.');

      debugPrint('[BibleDatabase] Opening IndexedDB filesystem...');

      final fileSystem = await IndexedDbFileSystem.open(
        dbName: 'abideverse_bible',
      );

      debugPrint('[BibleDatabase] IndexedDB filesystem opened.');

      sqlite.registerVirtualFileSystem(fileSystem, makeDefault: true);

      debugPrint('[BibleDatabase] Opening bible.sqlite...');

      final database = sqlite.open('bible.sqlite', mode: OpenMode.readOnly);

      debugPrint('[BibleDatabase] bible.sqlite opened.');

      return BibleDatabase(database, sqlite);
    } catch (e, stackTrace) {
      debugPrint('[BibleDatabase] FAILED: $e');
      debugPrint('$stackTrace');
      rethrow;
    }
  }

  void dispose() {
    _database.dispose();
  }
}
