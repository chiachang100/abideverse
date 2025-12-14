import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'package:abideverse/app/router.dart';
import 'package:abideverse/shared/localization/locale_keys.g.dart';
import 'package:abideverse/shared/services/ai/ai_service.dart';
import 'package:abideverse/shared/services/ai/ai_factory.dart';

// --- Data Model for a Chat Message ---
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class BibleChatScreen extends StatefulWidget {
  // We can directly instantiate the service here, or pass it in.
  // Let's rely on the Factory for simplicity in the GoRouter setup.
  final AIService aiService;

  // The key is required by GoRouter's pageBuilder (fadePage)
  const BibleChatScreen({super.key, required this.aiService});

  @override
  State<BibleChatScreen> createState() => _BibleChatScreenState();
}

class _BibleChatScreenState extends State<BibleChatScreen> {
  // ... (Keep the rest of the implementation from the previous response,
  //      including _messages, _textController, _isLoading,
  //      _handleSubmitted, _buildMessage, and _buildTextComposer) ...

  final List<ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Optional: Add a welcoming message from the AI on load
    _messages.add(
      ChatMessage(
        text: LocaleKeys.bibleChatWelcomeMsg.tr(),
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  // --- Core Function to Send and Receive Messages (UPDATED to use widget.aiService) ---
  Future<void> _handleSubmitted(String text) async {
    _textController.clear();
    if (text.trim().isEmpty) return;

    final userMessage = ChatMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );
    setState(() {
      _messages.insert(0, userMessage);
      _isLoading = true;
    });

    try {
      // 2. Call the Firebase AI Service using the injected dependency

      // Original user text
      String userQuery = text;

      // The instruction to the model
      final instruction =
          "You are an AI biblical expert. For every statement, include at least one corresponding Scripture reference (e.g., John 3:16).";

      // Combine the instruction and the user query
      final textWithInstruction = "$instruction\n\nUser Query: $userQuery";
      final aiResponseText = await widget.aiService.generateText(text);

      if (aiResponseText != null && aiResponseText.isNotEmpty) {
        final aiMessage = ChatMessage(
          text: aiResponseText,
          isUser: false,
          timestamp: DateTime.now(),
        );
        setState(() {
          _messages.insert(0, aiMessage);
        });
      }
    } catch (e) {
      final errorMessage = ChatMessage(
        text:
            '${LocaleKeys.bibleChatErrorMsg.tr()}. AI Error: ${e.toString()}}',
        isUser: false,
        timestamp: DateTime.now(),
      );
      setState(() {
        _messages.insert(0, errorMessage);
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // --- UI Layout ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.bibleChatTitle.tr()),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Image.asset('assets/icons/abideverse-leading-icon.png'),
              onPressed: () {
                Routes(context).goJoys();
              },
            );
          },
        ),
      ),
      body: Column(
        children: <Widget>[
          // Message List Area
          Flexible(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              reverse: true, // Display newest messages at the bottom/top
              itemBuilder: (_, int index) => _buildMessage(_messages[index]),
              itemCount: _messages.length,
            ),
          ),
          // Loading Indicator
          if (_isLoading)
            const LinearProgressIndicator(color: Colors.lightGreen),
          const Divider(height: 1.0),
          // Input Field Area
          Container(
            decoration: BoxDecoration(color: Theme.of(context).cardColor),
            child: _buildTextComposer(),
          ),
        ],
      ),
    );
  }

  // --- Widget for a single message bubble (Implementation as before) ---
  Widget _buildMessage(ChatMessage message) {
    // ... (Implementation as before) ...
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: message.isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: <Widget>[
          if (!message.isUser) // AI Avatar/Icon on the left
            const Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: CircleAvatar(
                child: Icon(Icons.psychology_outlined, size: 20),
              ),
            ),

          // The message bubble
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: message.isUser
                  ? Theme.of(context)
                        .colorScheme
                        .primaryContainer // User color
                  : Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHigh, // AI color
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16.0),
                topRight: const Radius.circular(16.0),
                bottomLeft: Radius.circular(message.isUser ? 16.0 : 4.0),
                bottomRight: Radius.circular(message.isUser ? 4.0 : 16.0),
              ),
            ),
            child: message.isUser
                ? Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser
                          ? Theme.of(context).colorScheme.onPrimaryContainer
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  )
                : MarkdownBody(
                    // <-- Use MarkdownBody for AI response!
                    data: message.text,
                    selectable: true, // Allow selection of AI text
                    shrinkWrap:
                        true, // Essential for use inside a chat bubble/ListView.builder
                    styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context))
                        .copyWith(
                          // Customize the body text style to match your theme's non-user text
                          p: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                            fontSize: 16.0,
                          ),
                          // You can customize headings, lists, etc., here:
                          h1: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                          listIndent: 20.0, // Adjust list indentation
                          blockquote: TextStyle(fontStyle: FontStyle.italic),
                        ),
                  ),
          ),

          if (message.isUser) // User Avatar/Icon on the right
            const Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: CircleAvatar(child: Icon(Icons.person, size: 20)),
            ),
        ],
      ),
    );
  }

  // --- Widget for the Input Text Composer (Implementation as before) ---
  Widget _buildTextComposer() {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).colorScheme.secondary),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: <Widget>[
            Flexible(
              child: TextField(
                controller: _textController,
                onSubmitted: _handleSubmitted,
                decoration: InputDecoration.collapsed(
                  hintText: LocaleKeys.bibleChatHintText.tr(),
                ),
                enabled: !_isLoading,
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                icon: const Icon(Icons.send),
                onPressed: _isLoading
                    ? null
                    : () => _handleSubmitted(_textController.text),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
