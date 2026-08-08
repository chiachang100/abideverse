import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:abideverse/features/ask_rhema/application/ask_rhema_controller.dart';

void main() {
  test('controller starts with null response', () async {
    final container = ProviderContainer();

    addTearDown(container.dispose);

    final controller = container.read(askRhemaControllerProvider.notifier);

    final result = await controller.future;

    expect(result, isNull);
  });

  test('clear resets response to null', () async {
    final container = ProviderContainer();

    addTearDown(container.dispose);

    final controller = container.read(askRhemaControllerProvider.notifier);

    await controller.future;

    controller.clear();

    expect(container.read(askRhemaControllerProvider).value, isNull);
  });
}
