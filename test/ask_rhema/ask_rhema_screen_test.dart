import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:abideverse/features/ask_rhema/application/ask_rhema_controller.dart';
import 'package:abideverse/features/ask_rhema/application/ask_rhema_providers.dart';
import 'package:abideverse/features/ask_rhema/domain/ask_rhema_message.dart';
import 'package:abideverse/features/ask_rhema/domain/ask_rhema_request.dart';
import 'package:abideverse/features/ask_rhema/domain/ask_rhema_response.dart';
import 'package:abideverse/features/ask_rhema/domain/ask_rhema_service.dart';
import 'package:abideverse/features/ask_rhema/screens/ask_rhema_screen.dart';
import 'package:abideverse/features/bible/domain/bible_translation.dart';
import 'package:abideverse/features/bible/domain/bible_verse.dart';

class FakeAskRhemaService implements AskRhemaService {
  final List<AskRhemaRequest> requests = [];

  bool shouldFail = false;
  Completer<void>? pending;

  @override
  Future<AskRhemaResponse> ask(AskRhemaRequest request) async {
    requests.add(request);

    if (shouldFail) {
      throw StateError('Test error');
    }

    final completer = pending;

    if (completer != null) {
      await completer.future;
    }

    return const AskRhemaResponse(
      answer: 'God loves the world.',
      sources: [
        BibleVerse(
          id: 1,
          bookId: 'john',
          bookName: 'John',
          chapter: 3,
          verse: 16,
          text: 'For God so loved the world...',
          translation: BibleTranslation(
            id: 'web',
            name: 'World English Bible',
            languageCode: 'en',
          ),
        ),
      ],
    );
  }
}

Widget buildTestApp(FakeAskRhemaService service) {
  return ProviderScope(
    overrides: [askRhemaServiceProvider.overrideWith((ref) async => service)],
    child: const MaterialApp(home: AskRhemaScreen()),
  );
}

void main() {
  testWidgets('complete AskRhema conversation flow', (tester) async {
    final service = FakeAskRhemaService();

    await tester.pumpWidget(buildTestApp(service));

    expect(find.text('Ask a question about Scripture.'), findsOneWidget);

    await tester.enterText(
      find.byType(TextField),
      'What does the Bible say about love?',
    );

    await tester.tap(find.byIcon(Icons.send));
    await tester.pumpAndSettle();

    expect(find.text('What does the Bible say about love?'), findsOneWidget);

    expect(find.text('God loves the world.'), findsOneWidget);

    expect(find.text('Scripture Sources'), findsOneWidget);

    expect(find.text('John 3:16'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'What does that mean?');

    await tester.tap(find.byIcon(Icons.send));
    await tester.pumpAndSettle();

    expect(service.requests, hasLength(2));

    final secondRequest = service.requests[1];

    expect(secondRequest.question, 'What does that mean?');

    expect(secondRequest.translationId, 'web');

    expect(secondRequest.history, hasLength(2));

    expect(secondRequest.history[0].role, AskRhemaRole.user);

    expect(
      secondRequest.history[0].text,
      'What does the Bible say about love?',
    );

    expect(secondRequest.history[1].role, AskRhemaRole.assistant);

    expect(secondRequest.history[1].text, 'God loves the world.');

    expect(find.text('What does that mean?'), findsOneWidget);
  });

  testWidgets('AskRhema changes translation for the conversation', (
    tester,
  ) async {
    final service = FakeAskRhemaService();

    await tester.pumpWidget(buildTestApp(service));

    await tester.tap(find.text('WEB'));
    await tester.pump();

    await tester.tap(find.text('和合本（繁體）'));
    await tester.pump();

    await tester.enterText(find.byType(TextField), '神愛世人');

    await tester.tap(find.byIcon(Icons.send));
    await tester.pumpAndSettle();

    expect(service.requests.single.translationId, 'cuv_hant');
  });

  testWidgets('AskRhema shows loading and disables input', (tester) async {
    final service = FakeAskRhemaService()..pending = Completer<void>();

    await tester.pumpWidget(buildTestApp(service));

    await tester.enterText(find.byType(TextField), 'What is faith?');

    await tester.tap(find.byIcon(Icons.send));
    await tester.pump();

    expect(find.text('AskRhema is thinking...'), findsOneWidget);

    expect(find.byIcon(Icons.send), findsOneWidget);

    final textField = tester.widget<TextField>(find.byType(TextField));

    expect(textField.enabled, isFalse);

    service.pending!.complete();

    await tester.pumpAndSettle();

    expect(find.text('God loves the world.'), findsOneWidget);
  });

  testWidgets('AskRhema preserves conversation after an error', (tester) async {
    final service = FakeAskRhemaService();

    await tester.pumpWidget(buildTestApp(service));

    await tester.enterText(find.byType(TextField), 'What is love?');

    await tester.tap(find.byIcon(Icons.send));
    await tester.pumpAndSettle();

    expect(find.text('What is love?'), findsOneWidget);

    expect(find.text('God loves the world.'), findsOneWidget);

    service.shouldFail = true;

    await tester.enterText(find.byType(TextField), 'Tell me more.');

    await tester.tap(find.byIcon(Icons.send));
    await tester.pumpAndSettle();

    expect(find.text('What is love?'), findsOneWidget);

    expect(find.text('God loves the world.'), findsNWidgets(2));
  });

  testWidgets('AskRhema clears the conversation', (tester) async {
    final service = FakeAskRhemaService();

    await tester.pumpWidget(buildTestApp(service));

    await tester.enterText(find.byType(TextField), 'What is love?');

    await tester.tap(find.byIcon(Icons.send));
    await tester.pumpAndSettle();

    expect(find.text('God loves the world.'), findsOneWidget);

    await tester.tap(find.byTooltip('Clear conversation'));

    await tester.pump();

    expect(find.text('Ask a question about Scripture.'), findsOneWidget);

    expect(find.text('What is love?'), findsNothing);

    expect(find.text('God loves the world.'), findsNothing);
  });
}
