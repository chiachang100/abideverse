import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:abideverse/app/more_menu.dart';
import 'package:abideverse/app/router.dart';
import 'package:abideverse/features/ask_rhema/screens/ask_rhema_screen.dart';

void main() {
  testWidgets('More menu opens AskRhema', (tester) async {
    final router = GoRouter(
      initialLocation: AppRoutes.more,
      routes: [
        GoRoute(
          path: AppRoutes.more,
          builder: (context, state) => const MoreMenuScreen(),
        ),
        GoRoute(
          path: AppRoutes.askRhema,
          builder: (context, state) => const AskRhemaScreen(),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(child: MaterialApp.router(routerConfig: router)),
    );

    expect(find.text('AskRhema'), findsOneWidget);

    await tester.tap(find.text('AskRhema'));
    await tester.pumpAndSettle();

    expect(find.byType(AskRhemaScreen), findsOneWidget);
  });
}
