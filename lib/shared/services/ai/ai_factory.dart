import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:abideverse/core/config/app_config.dart';
import 'package:abideverse/shared/services/ai/ai_service.dart';
import 'package:abideverse/shared/services/ai/genai_service.dart';
import 'package:abideverse/shared/services/ai/firebase_ai_service.dart';
import 'package:logging/logging.dart';

final logAIServices = Logger('ai_services');

class AIFactory {
  static AIService create() {
    FirebaseAnalytics.instance.logEvent(
      name: 'ai_service',
      parameters: {'ai_service': 'AIFactory', 'ai_service_class': 'AIFactory'},
    );

    logAIServices.info('[AIFactory] AI Provider: $AppConfig.aiProvider');
    logAIServices.warning("This should show ✓");

    switch (AppConfig.aiProvider) {
      case AIProvider.genAI:
        return GenAIService('YOUR_API_KEY');
      case AIProvider.firebaseAI:
        return FirebaseAIService(Firebase.app());
    }
  }
}
