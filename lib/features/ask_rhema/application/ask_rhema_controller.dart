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
  Future<AskRhemaService> get _service async {
    return ref.read(askRhemaServiceProvider.future);
  }

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

    state = await AsyncValue.guard(() async {
      final service = await _service;
      return service.ask(request);
    });
  }

  void clear() {
    state = const AsyncData(null);
  }
}
