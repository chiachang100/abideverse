import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:abideverse/firebase_options.dart' as fbopts;

/// A small Firebase initialization wrapper/service.
/// Call AbideVerseFirebaseService.initialize(...) from main() before runApp().
class AbideVerseFirebaseService {
  AbideVerseFirebaseService._(); // private constructor

  static final AbideVerseFirebaseService instance =
      AbideVerseFirebaseService._();

  late final FirebaseApp app;
  late final FirebaseAuth auth;

  /// Initializes Firebase. If [options] is omitted, this uses the
  /// DefaultFirebaseOptions.currentPlatform if available.
  ///
  /// Example:
  ///   await AbideVerseFirebaseService.instance.initialize();
  /// or
  ///   await AbideVerseFirebaseService.instance.initialize(options: myOptions);
  Future<void> initialize({FirebaseOptions? options}) async {
    if (options != null) {
      app = await Firebase.initializeApp(options: options);
    } else {
      // Try to use generated firebase_options.dart if present.
      try {
        app = await Firebase.initializeApp(
          options: fbopts.DefaultFirebaseOptions.currentPlatform,
        );
      } catch (e) {
        // Fallback to default no-options initialization (works on some setups)
        app = await Firebase.initializeApp();
      }
    }

    auth = FirebaseAuth.instance;
  }
}
