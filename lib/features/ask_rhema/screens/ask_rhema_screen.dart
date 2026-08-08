import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:abideverse/features/ask_rhema/application/ask_rhema_controller.dart';

class AskRhemaScreen extends ConsumerStatefulWidget {
  const AskRhemaScreen({super.key});

  @override
  ConsumerState<AskRhemaScreen> createState() => _AskRhemaScreenState();
}

class _AskRhemaScreenState extends ConsumerState<AskRhemaScreen> {
  final _controller = TextEditingController();

  String _translationId = 'web';

  static const _translations = <String, String>{
    'web': 'WEB',
    'cuv_hant': '和合本（繁體）',
    'cuv_hans': '和合本（简体）',
  };

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _ask() async {
    final question = _controller.text.trim();

    if (question.isEmpty) return;

    await ref
        .read(askRhemaControllerProvider.notifier)
        .ask(question: question, translationId: _translationId);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(askRhemaControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AskRhema'),
        actions: [
          DropdownButton<String>(
            value: _translationId,
            underline: const SizedBox.shrink(),
            items: _translations.entries.map((entry) {
              return DropdownMenuItem<String>(
                value: entry.key,
                child: Text(entry.value),
              );
            }).toList(),
            onChanged: (value) {
              if (value == null) return;

              setState(() {
                _translationId = value;
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: state.when(
                data: (response) {
                  if (response == null) {
                    return const Center(
                      child: Text('Ask a question about Scripture.'),
                    );
                  }

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(response.answer),
                        const SizedBox(height: 24),
                        if (response.sources.isNotEmpty) ...[
                          const Text(
                            'Scripture Sources',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          ...response.sources.map(
                            (source) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${source.bookName} '
                                    '${source.chapter}:${source.verse}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(source.text),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(child: Text('Error: $error')),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _ask(),
              decoration: InputDecoration(
                hintText: 'Ask about Scripture...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _ask,
                ),
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
