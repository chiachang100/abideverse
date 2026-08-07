import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/bible_database.dart';
import '../data/sqlite_bible_repository.dart';
import '../domain/bible_repository.dart';

final bibleDatabaseProvider = FutureProvider<BibleDatabase>((ref) async {
  final database = await BibleDatabase.open();
  ref.onDispose(database.dispose);
  return database;
});

final bibleRepositoryProvider = Provider<AsyncValue<BibleRepository>>((ref) {
  final database = ref.watch(bibleDatabaseProvider);
  return database.when(
    data: (db) => AsyncValue.data(SqliteBibleRepository(database: db)),
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});
