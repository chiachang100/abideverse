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

final bibleRepositoryProvider = FutureProvider<BibleRepository>((ref) async {
  final database = await ref.watch(bibleDatabaseProvider.future);

  return SqliteBibleRepository(database: database);
});

final aiServiceProvider = Provider<AIService>((ref) {
  return AIFactory.create();
});

final askRhemaServiceProvider = FutureProvider<AskRhemaService>((ref) async {
  final bibleRepository = await ref.watch(bibleRepositoryProvider.future);
  final aiService = ref.watch(aiServiceProvider);

  return AskRhemaServiceImpl(
    bibleRepository: bibleRepository,
    aiService: aiService,
  );
});
