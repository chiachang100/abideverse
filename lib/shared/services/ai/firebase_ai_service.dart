import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_ai/firebase_ai.dart'; // hypothetical import
import 'package:abideverse/shared/services/ai/ai_service.dart';
import 'package:logging/logging.dart';

final logAIServices = Logger('genai_services');

class FirebaseAIService implements AIService {
  final FirebaseAI _ai;

  FirebaseAIService(FirebaseApp app)
    : _ai = FirebaseAI.googleAI(
        // TO-DO: It seems that AppCheck needs more time to set it up correctly.
        // Will come back to it asap.
        //appCheck: FirebaseAppCheck.instance,
        //useLimitedUseAppCheckTokens: true,
      );

  static const String modelName = 'gemini-3.5-flash-lite';

  @override
  Future<String?> generateText(String prompt) async {
    FirebaseAnalytics.instance.logEvent(
      name: 'genai_services',
      parameters: {
        'genai_services': 'FirebaseAIService',
        'ai_services_class': 'FirebaseAIService',
      },
    );

    logAIServices.info('[FirebaseAIService] model: $modelName');

    final model = _ai.generativeModel(model: modelName);
    final response = await model
        .generateContent([Content.text(prompt)])
        .timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            throw TimeoutException(
              'FirebaseAIService took too long to respond.',
            );
          },
        );
    return response.text;
  }
}
