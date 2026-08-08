import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:abideverse/features/ask_rhema/application/ask_rhema_controller.dart';
import 'package:abideverse/features/ask_rhema/application/ask_rhema_providers.dart';
import 'package:abideverse/features/ask_rhema/domain/ask_rhema_response.dart';
import 'package:abideverse/features/ask_rhema/domain/ask_rhema_service.dart';
import 'package:abideverse/features/ask_rhema/domain/ask_rhema_request.dart';
import 'package:abideverse/features/ask_rhema/screens/ask_rhema_screen.dart';
import 'package:abideverse/features/bible/domain/bible_verse.dart';
import 'package:abideverse/features/bible/domain/bible_translation.dart';

class FakeAskRhemaService implements AskRhemaService {
  AskRhemaRequest? request;

  @override
  Future<AskRhemaResponse> ask(AskRhemaRequest request) async {
    this.request = request;

    return AskRhemaResponse(
      answer: 'God loves the world.',
      sources: [
        BibleVerse(
          id: 1,
          bookId: 'john',
          bookName: 'John',
          chapter: 3,
          verse: 16,
          text: 'For God so loved the world...',
          translation: const BibleTranslation(
            id: 'web',
            name: 'World English Bible',
            languageCode: 'en',
          ),
        ),
      ],
    );
  }
}

void main() {
  testWidgets('AskRhema asks a question and displays answer', (tester) async {
    final fakeService = FakeAskRhemaService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [askRhemaServiceProvider.overrideWithValue(fakeService)],
        child: const MaterialApp(home: AskRhemaScreen()),
      ),
    );

    expect(find.text('Ask a question about Scripture.'), findsOneWidget);

    await tester.enterText(
      find.byType(TextField),
      'What does the Bible say about love?',
    );

    await tester.tap(find.byIcon(Icons.send));
    await tester.pumpAndSettle();

    expect(find.text('God loves the world.'), findsOneWidget);
    expect(find.text('Scripture Sources'), findsOneWidget);
    expect(find.text('John 3:16'), findsOneWidget);

    expect(
      fakeService.request?.question,
      'What does the Bible say about love?',
    );

    expect(fakeService.request?.translationId, 'web');
  });

  testWidgets('AskRhema can change translation', (tester) async {
    final fakeService = FakeAskRhemaService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [askRhemaServiceProvider.overrideWithValue(fakeService)],
        child: const MaterialApp(home: AskRhemaScreen()),
      ),
    );

    await tester.tap(find.text('WEB'));
    await tester.pump();

    await tester.tap(find.text('和合本（繁體）'));
    await tester.pump();

    await tester.enterText(find.byType(TextField), '神愛世人');

    await tester.tap(find.byIcon(Icons.send));
    await tester.pumpAndSettle();

    expect(fakeService.request?.translationId, 'cuv_hant');
  });
}
