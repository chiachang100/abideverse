import 'package:abideverse/startup/startup_service.dart';

class AppInitializer {
  static Future<void> initialize() async {
    await StartupService.instance.run();
  }
}
