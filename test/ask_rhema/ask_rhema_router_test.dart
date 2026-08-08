import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:abideverse/app/router.dart';
import 'package:abideverse/features/ask_rhema/screens/ask_rhema_screen.dart';

void main() {
  testWidgets('AskRhema route opens AskRhemaScreen', (tester) async {
    final router = GoRouter(
      initialLocation: AppRoutes.askRhema,
      routes: [
        GoRoute(
          path: AppRoutes.askRhema,
          builder: (context, state) => const AskRhemaScreen(),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(child: MaterialApp.router(routerConfig: router)),
    );

    expect(find.byType(AskRhemaScreen), findsOneWidget);
  });
}
