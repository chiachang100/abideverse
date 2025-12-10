import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:abideverse/shared/services/ai/ai_service.dart';
import 'package:logging/logging.dart';

final logAIServices = Logger('ai_services');

class GenAIService implements AIService {
  final GenerativeModel _model;

  GenAIService(String apiKey)
    : _model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);

  @override
  Future<String?> generateText(String prompt) async {
    FirebaseAnalytics.instance.logEvent(
      name: 'genai_service',
      parameters: {
        'genai_service': 'GenAIService',
        'genai_service_class': 'GenAIService',
      },
    );

    logAIServices.info('[GenAIService] generateText: $prompt');

    final response = await _model.generateContent([Content.text(prompt)]);
    return response.text;
  }
}
