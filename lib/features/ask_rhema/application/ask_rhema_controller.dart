import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/ask_rhema_message.dart';
import '../domain/ask_rhema_request.dart';
import '../domain/ask_rhema_response.dart';
import '../domain/ask_rhema_service.dart';
import 'ask_rhema_providers.dart';

final askRhemaControllerProvider =
    AsyncNotifierProvider<AskRhemaController, AskRhemaResponse?>(
      AskRhemaController.new,
    );

class AskRhemaController extends AsyncNotifier<AskRhemaResponse?> {
  AskRhemaService get _service => ref.read(askRhemaServiceProvider);

  @override
  FutureOr<AskRhemaResponse?> build() {
    return null;
  }

  Future<void> ask({
    required String question,
    required String translationId,
    List<AskRhemaMessage> history = const [],
  }) async {
    final trimmed = question.trim();

    if (trimmed.isEmpty) return;

    state = const AsyncLoading();

    final request = AskRhemaRequest(
      question: trimmed,
      translationId: translationId,
      history: history,
    );

    state = await AsyncValue.guard(() => _service.ask(request));
  }

  void clear() {
    state = const AsyncData(null);
  }
}
