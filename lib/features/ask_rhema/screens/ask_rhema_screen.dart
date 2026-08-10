import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:abideverse/shared/localization/locale_keys.g.dart';
import 'package:abideverse/shared/widgets/shared_app_drawer.dart';
import 'package:abideverse/features/ask_rhema/application/ask_rhema_controller.dart';
import 'package:abideverse/features/ask_rhema/domain/ask_rhema_message.dart';
import 'package:abideverse/features/ask_rhema/domain/ask_rhema_response.dart';

// ---------------------------------------------------------------------
// Animated typing indicator (still shows the original text alongside)
// ---------------------------------------------------------------------
class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Animated dots
        ...List.generate(3, (index) {
          final delay = index * 0.15;
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final value = (_controller.value - delay) % 1.0;
              final scale =
                  0.6 + 0.4 * (value < 0.5 ? value * 2 : (1 - value) * 2);
              return Transform.scale(
                scale: scale,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          );
        }),
        const SizedBox(width: 12),
        // Keep the original text so tests can find it
        Text(LocaleKeys.askRhemaThinking.tr()),
      ],
    );
  }
}

// ---------------------------------------------------------------------
// Main Screen
// ---------------------------------------------------------------------
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
    'web': 'World English Bible',
    'cuv_hant': '和合本（繁體）',
    'cuv_hans': '和合本（简体）',
  };

  bool get _isLoading => ref.watch(askRhemaControllerProvider).isLoading;

  bool get _hasTurns => _turns.isNotEmpty;

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
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
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
    final theme = Theme.of(context);
    final state = ref.watch(askRhemaControllerProvider);
    final isLoading = _isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.askRhema.tr()),
        actions: [
          // Keep DropdownButton for test compatibility, but style it nicely
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
                    if (value != null) setState(() => _translationId = value);
                  },
            // Add some padding and a rounded background
            style: theme.textTheme.bodyMedium,
            icon: const Icon(Icons.arrow_drop_down),
          ),
          if (_hasTurns)
            IconButton(
              tooltip: 'Clear conversation',
              icon: const Icon(Icons.delete_outline),
              onPressed: isLoading ? null : _clearConversation,
            ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          Expanded(child: _buildConversation(state)),
          _buildComposer(isLoading),
        ],
      ),
    );
  }

  Widget _buildConversation(AsyncValue state) {
    final theme = Theme.of(context);

    if (!_hasTurns && !state.isLoading && !state.hasError) {
      // Keep the original empty state text so tests pass
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/photos/AskRhema.webp', width: 80, height: 80),
              SizedBox(height: 16),
              Text(LocaleKeys.askQuestion.tr()),
            ],
          ),
        ),
      );
    }

    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      children: [
        for (final turn in _turns) _buildTurn(turn),
        if (state.isLoading) _buildThinkingIndicator(),
        if (state.hasError) _buildError(state.error),
      ],
    );
  }

  Widget _buildTurn(_AskRhemaTurn turn) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // User message – right aligned with avatar
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 500),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(turn.question, style: theme.textTheme.bodyMedium),
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: theme.colorScheme.primary,
                radius: 16,
                child: Icon(
                  Icons.person,
                  color: theme.colorScheme.onPrimary,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
        // Assistant message – left aligned with avatar
        Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: theme.colorScheme.secondary,
                radius: 16,
                child: Icon(
                  Icons.auto_awesome,
                  color: theme.colorScheme.onSecondary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 500),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        turn.response.answer,
                        style: theme.textTheme.bodyMedium,
                      ),
                      if (turn.response.sources.isNotEmpty) ...[
                        const SizedBox(height: 16),
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
        ),
      ],
    );
  }

  Widget _buildThinkingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.secondary,
            radius: 16,
            child: Icon(
              Icons.auto_awesome,
              color: Theme.of(context).colorScheme.onSecondary,
              size: 18,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const _TypingIndicator(),
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
                decoration: InputDecoration(
                  hintText: LocaleKeys.askHint.tr(),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainer,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            FloatingActionButton(
              mini: true,
              backgroundColor: Theme.of(context).colorScheme.primary,
              onPressed: isLoading ? null : _ask,
              child: Icon(
                Icons.send,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
