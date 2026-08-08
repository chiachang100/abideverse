import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../bible/data/bible_database.dart';
import '../../bible/data/sqlite_bible_repository.dart';
import '../../bible/domain/bible_repository.dart';
import '../../../shared/services/ai/ai_factory.dart';
import '../../../shared/services/ai/ai_service.dart';
import '../data/ask_rhema_service_impl.dart';
import '../domain/ask_rhema_service.dart';

final bibleDatabaseProvider = FutureProvider<BibleDatabase>((ref) async {
  final database = await BibleDatabase.open();
  ref.onDispose(database.dispose);
  return database;
});

final bibleRepositoryProvider = Provider<BibleRepository>((ref) {
  final database = ref.watch(bibleDatabaseProvider);

  return database.when(
    data: (db) => SqliteBibleRepository(database: db),
    loading: () => throw StateError('Bible database is loading'),
    error: (error, _) =>
        throw StateError('Failed to open Bible database: $error'),
  );
});

final aiServiceProvider = Provider<AIService>((ref) {
  return AIFactory.create();
});

final askRhemaServiceProvider = Provider<AskRhemaService>((ref) {
  return AskRhemaServiceImpl(
    bibleRepository: ref.read(bibleRepositoryProvider),
    aiService: ref.read(aiServiceProvider),
  );
});
