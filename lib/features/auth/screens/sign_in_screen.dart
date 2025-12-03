import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logging/logging.dart';

import 'package:easy_localization/easy_localization.dart';

import 'package:abideverse/shared/localization/locale_keys.g.dart';
import 'package:abideverse/services/firebase/firebase_service.dart';

final abideverselogSignIn = Logger('sign_in');

typedef OAuthSignIn = void Function();

class Credentials {
  final String email;
  final String password;

  Credentials(this.email, this.password);
}

/// Helper class to show a snackbar using the passed context.
class ScaffoldSnackbar {
  // ignore: public_member_api_docs
  ScaffoldSnackbar(this._context);

  /// The scaffold of current context.
  factory ScaffoldSnackbar.of(BuildContext context) {
    return ScaffoldSnackbar(context);
  }

  final BuildContext _context;

  /// Helper method to show a SnackBar.
  void show(String message) {
    ScaffoldMessenger.of(_context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }
}

/// The mode of the current auth session, either [AuthMode.login] or [AuthMode.register].
// ignore: public_member_api_docs
enum AuthMode { login, register }

extension on AuthMode {
  String get label => this == AuthMode.login ? 'Sign in' : 'Register';
}

class SignInScreen extends StatefulWidget {
  final ValueChanged<Credentials> onSignIn;

  const SignInScreen({required this.onSignIn, super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String error = '';
  String verificationId = '';

  AuthMode mode = AuthMode.login;

  bool isLoading = false;

  void setIsLoading() {
    setState(() {
      isLoading = !isLoading;
    });
  }

  late Map<Buttons, OAuthSignIn> authButtons;

  @override
  void initState() {
    super.initState();
    FirebaseAnalytics.instance.logEvent(
      name: 'signin_view',
      parameters: {
        'abideverse_screen': 'SignInScreen',
        'abideverse_screen_class': 'SignInScreenClass',
      },
    );

    // if (withSilentVerificationSMSMFA && !kIsWeb) {
    //   FirebaseMessaging messaging = FirebaseMessaging.instance;
    //   messaging.requestPermission();
    // }

    authButtons = {
      Buttons.Google: () => _handleMultiFactorException(_signInWithGoogle),
    };
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: FocusScope.of(context).unfocus,
      child: Scaffold(
        appBar: AppBar(
          leading: Image.asset('assets/photos/abideverse_photo_default.png'),
          leadingWidth: 100,
          centerTitle: true,
          // title: Text('笑裡藏道'),
          title: Text(LocaleKeys.appTitle.tr()),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SafeArea(
                  child: Form(
                    key: formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Visibility(
                            visible: error.isNotEmpty,
                            child: MaterialBanner(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.error,
                              content: SelectableText(error),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      error = '';
                                    });
                                  },
                                  child: const Text(
                                    'dismiss',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                              contentTextStyle: const TextStyle(
                                color: Colors.white,
                              ),
                              padding: const EdgeInsets.all(10),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Column(
                            children: [
                              TextFormField(
                                controller: emailController,
                                decoration: const InputDecoration(
                                  hintText: 'Email',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                autofillHints: const [AutofillHints.email],
                                validator: (value) =>
                                    value != null && value.isNotEmpty
                                    ? null
                                    : 'Required',
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: passwordController,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  hintText: 'Password',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) =>
                                    value != null && value.isNotEmpty
                                    ? null
                                    : 'Required',
                              ),
                              const SizedBox(height: 20),
                              /*
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    widget.onSignIn(Credentials(
                                        emailController.value.text,
                                        passwordController.value.text));
                                  },
                                  child: const Text('Sign in'),
                                ),
                              ),
                              */
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: isLoading
                                      ? null
                                      : () => _handleMultiFactorException(
                                          _emailAndPassword,
                                        ),
                                  child: isLoading
                                      ? const CircularProgressIndicator.adaptive()
                                      : Text(mode.label),
                                ),
                              ),
                              TextButton(
                                onPressed: _resetPassword,
                                child: const Text('Forgot password?'),
                              ),
                              ...authButtons.keys
                                  .map(
                                    (button) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 5,
                                      ),
                                      child: AnimatedSwitcher(
                                        duration: const Duration(
                                          milliseconds: 200,
                                        ),
                                        child: isLoading
                                            ? Container(
                                                color: Colors.grey[200],
                                                height: 50,
                                                width: double.infinity,
                                              )
                                            : SizedBox(
                                                width: double.infinity,
                                                height: 50,
                                                child: SignInButton(
                                                  button,
                                                  onPressed:
                                                      authButtons[button]!,
                                                ),
                                              ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              const SizedBox(height: 20),
                              RichText(
                                text: TextSpan(
                                  style: Theme.of(context).textTheme.bodyLarge,
                                  children: [
                                    TextSpan(
                                      text: mode == AuthMode.login
                                          ? "Don't have an account? "
                                          : 'You have an account? ',
                                    ),
                                    TextSpan(
                                      text: mode == AuthMode.login
                                          ? 'Register now'
                                          : 'Click to Sign in',
                                      style: const TextStyle(
                                        color: Colors.blue,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          setState(() {
                                            mode = mode == AuthMode.login
                                                ? AuthMode.register
                                                : AuthMode.login;
                                          });
                                        },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              RichText(
                                text: TextSpan(
                                  style: Theme.of(context).textTheme.bodyLarge,
                                  children: [
                                    const TextSpan(text: 'Or '),
                                    TextSpan(
                                      text: 'continue as guest',
                                      style: const TextStyle(
                                        color: Colors.blue,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () =>
                                            _handleMultiFactorException(
                                              _anonymousAuth,
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future _resetPassword() async {
    FirebaseAnalytics.instance.logEvent(
      name: 'signin_view',
      parameters: {
        'abideverse_screen': 'ResetPassword',
        'abideverse_screen_class': 'SignInScreenClass',
      },
    );

    String? email;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Send'),
            ),
          ],
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter your email'),
              const SizedBox(height: 20),
              TextFormField(
                onChanged: (value) {
                  email = value;
                },
              ),
            ],
          ),
        );
      },
    );

    if (email != null) {
      try {
        await FirebaseService.instance.auth.sendPasswordResetEmail(
          email: email!,
        );
        ScaffoldSnackbar.of(context).show('Password reset email is sent');
      } catch (e) {
        ScaffoldSnackbar.of(context).show('Error resetting');
      }
    }
  }

  /* 
  Future<void> _anonymousAuth() async {
    setIsLoading();

    try {
      await FirebaseService.instance.auth.signInAnonymously();
    } on FirebaseAuthException catch (e) {
      setState(() {
        error = '${e.message}';
      });
    } catch (e) {
      setState(() {
        error = '$e';
      });
    } finally {
      setIsLoading();
    }
  }
 */

  Future<void> _handleMultiFactorException(
    Future<void> Function() authFunction,
  ) async {
    setIsLoading();
    try {
      await authFunction();
    } on FirebaseAuthMultiFactorException catch (e) {
      setState(() {
        error = '${e.message}';
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        error = '${e.message}';
      });
    } catch (e) {
      setState(() {
        error = '$e';
      });
    } finally {
      setIsLoading();
    }
  }

  Future<void> _anonymousAuth() async {
    FirebaseAnalytics.instance.logEvent(
      name: 'signin_view',
      parameters: {
        'abideverse_screen': 'AnonymousAuth',
        'abideverse_screen_class': 'SignInScreenClass',
      },
    );

    await FirebaseService.instance.auth.signInAnonymously();
    abideverselogSignIn.info(
      '[SignIn] SingInAnonymously uid: ${FirebaseAuth.instance.currentUser?.uid}',
    );

    widget.onSignIn(
      Credentials(emailController.value.text, passwordController.value.text),
    );
  }

  Future<void> _emailAndPassword() async {
    FirebaseAnalytics.instance.logEvent(
      name: 'signin_view',
      parameters: {
        'abideverse_screen': 'EmailAndPassword',
        'abideverse_screen_class': 'SignInScreenClass',
      },
    );

    UserCredential userCredential;
    User? user;

    if (formKey.currentState?.validate() ?? false) {
      if (mode == AuthMode.login) {
        userCredential = await FirebaseService.instance.auth
            .signInWithEmailAndPassword(
              email: emailController.text,
              password: passwordController.text,
            );
        user = userCredential.user;

        FirebaseAnalytics.instance.logEvent(
          name: 'signin_view',
          parameters: {
            'abideverse_screen': 'SignInWithEmailAndPassword',
            'abideverse_screen_class': 'SignInScreenClass',
          },
        );
      } else {
        userCredential = await FirebaseService.instance.auth
            .createUserWithEmailAndPassword(
              email: emailController.text,
              password: passwordController.text,
            );
        user = userCredential.user;

        FirebaseAnalytics.instance.logEvent(
          name: 'signin_view',
          parameters: {
            'abideverse_screen': 'CreateUserWithEmailAndPassword',
            'abideverse_screen_class': 'SignInScreenClass',
          },
        );
      }
      if (user != null) {
        abideverselogSignIn.info(
          '[SignIn] SingInWithEmailAndPassword uid: ${FirebaseAuth.instance.currentUser?.uid}',
        );

        widget.onSignIn(
          Credentials(
            emailController.value.text,
            passwordController.value.text,
          ),
        );

        FirebaseAnalytics.instance.logEvent(
          name: 'signin_view',
          parameters: {
            'abideverse_screen': 'SuccessSignInWithEmailAndPassword',
            'abideverse_screen_class': 'SignInScreenClass',
          },
        );
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    FirebaseAnalytics.instance.logEvent(
      name: 'signin_view',
      parameters: {
        'abideverse_screen': 'SignInWithGoogl',
        'abideverse_screen_class': 'SignInScreenClass',
      },
    );

    UserCredential userCredential;
    User? user;

    // Trigger the authentication flow
    final googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final googleAuth = await googleUser?.authentication;

    if (googleAuth != null) {
      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      userCredential = await FirebaseService.instance.auth.signInWithCredential(
        credential,
      );
      user = userCredential.user;
      if (user != null) {
        abideverselogSignIn.info(
          '[SignIn] SingInWithGoogle uid: ${FirebaseAuth.instance.currentUser?.uid}',
        );

        widget.onSignIn(
          Credentials(
            emailController.value.text,
            passwordController.value.text,
          ),
        );

        FirebaseAnalytics.instance.logEvent(
          name: 'signin_view',
          parameters: {
            'abideverse_screen': 'SuccessSignInWithGoogl',
            'abideverse_screen_class': 'SignInScreenClass',
          },
        );
      }
    }
  }

  Future<void> signOut() async {
    FirebaseAnalytics.instance.logEvent(
      name: 'signin_view',
      parameters: {
        'abideverse_screen': 'SignOut',
        'abideverse_screen_class': 'SignInScreenClass',
      },
    );

    await FirebaseService.instance.auth.signOut();
    await GoogleSignIn().signOut();
  }
}
