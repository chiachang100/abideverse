import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_ai/firebase_ai.dart'; // hypothetical import
import 'package:abideverse/shared/services/ai/ai_service.dart';
import 'package:logging/logging.dart';

final logAIServices = Logger('ai_services');

class FirebaseAIService implements AIService {
  final FirebaseAI _ai;

  FirebaseAIService(FirebaseApp app) : _ai = FirebaseAI.googleAI();

  @override
  Future<String?> generateText(String prompt) async {
    FirebaseAnalytics.instance.logEvent(
      name: 'firebase_ai_service',
      parameters: {
        'firebase_ai_service': 'FirebaseAIService',
        'firebase_ai_service_class': 'FirebaseAIService',
      },
    );

    logAIServices.info('[FirebaseAIService] generateText: $prompt');

    final model = _ai.generativeModel(model: 'gemini-1.5-flash');
    final response = await model.generateContent([Content.text(prompt)]);
    return response.text;
  }
}
