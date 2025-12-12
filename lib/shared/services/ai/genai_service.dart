import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:abideverse/shared/services/ai/ai_service.dart';
import 'package:logging/logging.dart';

final logAIServices = Logger('genai_services');

class GenAIService implements AIService {
  final GenerativeModel _model;

  GenAIService(String apiKey)
    : _model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);

  @override
  Future<String?> generateText(String prompt) async {
    FirebaseAnalytics.instance.logEvent(
      name: 'genai_services',
      parameters: {
        'genai_services': 'GenAIService',
        'ai_services_class': 'GenAIService',
      },
    );

    logAIServices.info('[GenAIService] generateText: $prompt');

    final response = await _model.generateContent([Content.text(prompt)]);
    return response.text;
  }
}
