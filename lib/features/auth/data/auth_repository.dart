import 'package:flutter/widgets.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:abideverse/shared/services/firebase/firebase_service.dart';

/// A mock authentication service
class JoystoreAuth extends ChangeNotifier {
  bool _signedIn = false;

  bool get signedIn => _signedIn;

  Future<void> signOut() async {
    FirebaseAnalytics.instance.logEvent(
      name: 'signin_view',
      parameters: {
        'abideverse_screen': 'SignOut',
        'abideverse_screen_class': 'JoystoreAuthClass',
      },
    );

    await FirebaseService.instance.auth.signOut();
    await GoogleSignIn().signOut();

    await Future<void>.delayed(const Duration(milliseconds: 200));
    // Sign out.
    _signedIn = false;
    notifyListeners();
  }

  Future<bool> signIn(String email, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));

    // Sign in. Allow any password.
    _signedIn = true;
    notifyListeners();

    // // TODO: hardcode them for now
    // if ((email == "g") && (password == "r")) {
    //   _signedIn = true;
    //   notifyListeners();
    // }

    return _signedIn;
  }

  @override
  bool operator ==(Object other) =>
      other is JoystoreAuth && other._signedIn == _signedIn;

  @override
  int get hashCode => _signedIn.hashCode;

  static JoystoreAuth of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<JoystoreAuthScope>()!
      .notifier!;
}

class JoystoreAuthScope extends InheritedNotifier<JoystoreAuth> {
  const JoystoreAuthScope({
    required super.notifier,
    required super.child,
    super.key,
  });
}
