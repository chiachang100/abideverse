import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:abideverse/features/ask_rhema/application/ask_rhema_controller.dart';
import 'package:abideverse/features/ask_rhema/domain/ask_rhema_message.dart';
import 'package:abideverse/features/ask_rhema/domain/ask_rhema_response.dart';

class _AskRhemaTurn {
  const _AskRhemaTurn({required this.question, required this.response});

  final String question;
  final AskRhemaResponse response;
}

class AskRhemaScreen extends ConsumerStatefulWidget {
  const AskRhemaScreen({super.key});

  @override
  ConsumerState<AskRhemaScreen> createState() => _AskRhemaScreenState();
}

class _AskRhemaScreenState extends ConsumerState<AskRhemaScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  final List<_AskRhemaTurn> _turns = [];

  String _translationId = 'web';

  static const _translations = <String, String>{
    'web': 'WEB',
    'cuv_hant': '和合本（繁體）',
    'cuv_hans': '和合本（简体）',
  };

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<AskRhemaMessage> _history() {
    return [
      for (final turn in _turns) ...[
        AskRhemaMessage(role: AskRhemaRole.user, text: turn.question),
        AskRhemaMessage(
          role: AskRhemaRole.assistant,
          text: turn.response.answer,
        ),
      ],
    ];
  }

  Future<void> _ask() async {
    final question = _textController.text.trim();

    if (question.isEmpty) return;

    final history = _history();

    _textController.clear();

    await ref
        .read(askRhemaControllerProvider.notifier)
        .ask(
          question: question,
          translationId: _translationId,
          history: history,
        );

    if (!mounted) return;

    final state = ref.read(askRhemaControllerProvider);

    if (state.hasValue && state.value != null) {
      setState(() {
        _turns.add(_AskRhemaTurn(question: question, response: state.value!));
      });

      await _scrollToBottom();
    }
  }

  Future<void> _scrollToBottom() async {
    await Future<void>.delayed(Duration.zero);

    if (!_scrollController.hasClients) return;

    await _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  void _clearConversation() {
    ref.read(askRhemaControllerProvider.notifier).clear();

    setState(() {
      _turns.clear();
      _textController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(askRhemaControllerProvider);
    final isLoading = state.isLoading;

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
            onChanged: isLoading
                ? null
                : (value) {
                    if (value == null) return;

                    setState(() {
                      _translationId = value;
                    });
                  },
          ),
          if (_turns.isNotEmpty)
            IconButton(
              tooltip: 'Clear conversation',
              icon: const Icon(Icons.delete_outline),
              onPressed: isLoading ? null : _clearConversation,
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _buildConversation(state)),
          _buildComposer(isLoading),
        ],
      ),
    );
  }

  Widget _buildConversation(AsyncValue state) {
    if (_turns.isEmpty && !state.isLoading && !state.hasError) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Ask a question about Scripture.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      children: [
        for (final turn in _turns) _buildTurn(turn),
        if (state.isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 12),
                  Text('AskRhema is thinking...'),
                ],
              ),
            ),
          ),
        if (state.hasError) _buildError(state.error),
      ],
    );
  }

  Widget _buildTurn(_AskRhemaTurn turn) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(turn.question),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(turn.response.answer),
                  if (turn.response.sources.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 8),
                    const Text(
                      'Scripture Sources',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    for (final source in turn.response.sources)
                      Padding(
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
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(Object? error) {
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.onErrorContainer,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Unable to answer right now.\n$error',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComposer(bool isLoading) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                enabled: !isLoading,
                minLines: 1,
                maxLines: 5,
                textInputAction: TextInputAction.send,
                onSubmitted: isLoading ? null : (_) => _ask(),
                decoration: const InputDecoration(
                  hintText: 'Ask about Scripture...',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              tooltip: 'Ask',
              icon: const Icon(Icons.send),
              onPressed: isLoading ? null : _ask,
            ),
          ],
        ),
      ),
    );
  }
}
