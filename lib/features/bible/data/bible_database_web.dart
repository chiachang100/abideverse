import 'package:logging/logging.dart';

import 'package:flutter/services.dart';
import 'package:sqlite3/wasm.dart';
import 'package:typed_data/typed_buffers.dart';

final logger = Logger('bible_database_web');

class BibleDatabase {
  BibleDatabase(this._database, this._sqlite);

  final CommonDatabase _database;
  final WasmSqlite3 _sqlite;

  CommonDatabase get database => _database;

  static const assetPath = 'assets/bible/bible.sqlite';
  static const fileName = '/bible.sqlite';

  static Future<BibleDatabase> open() async {
    try {
      logger.info('[BibleDatabase] Loading sqlite3.wasm...');

      final sqlite = await WasmSqlite3.loadFromUrlString('sqlite3.wasm');

      logger.info('[BibleDatabase] sqlite3.wasm loaded.');

      logger.info('[BibleDatabase] Loading $assetPath...');

      final data = await rootBundle.load(assetPath);

      final bytes = Uint8List.view(
        data.buffer,
        data.offsetInBytes,
        data.lengthInBytes,
      );

      logger.info('[BibleDatabase] Bible asset loaded: ${bytes.length} bytes.');

      final fileSystem = InMemoryFileSystem();

      final fileData = Uint8Buffer()..addAll(bytes);

      fileSystem.fileData[fileName] = fileData;

      logger.info('[BibleDatabase] Registered VFS file: $fileName');

      sqlite.registerVirtualFileSystem(fileSystem, makeDefault: true);

      logger.info('[BibleDatabase] Bible database loaded into memory.');

      final database = sqlite.open(fileName, mode: OpenMode.readOnly);

      logger.info('[BibleDatabase] bible.sqlite opened successfully.');

      return BibleDatabase(database, sqlite);
    } catch (e, stackTrace) {
      logger.info('[BibleDatabase] FAILED: $e');
      logger.info('$stackTrace');
      rethrow;
    }
  }

  void dispose() {
    _database.dispose();
  }
}
