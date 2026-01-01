import 'package:flutter/material.dart';
import 'package:flutter_test_app/features/auth/presentation/pages/sign_in_page.dart';
import 'package:flutter_test_app/features/auth/presentation/pages/sign_up_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _isSignIn = true;

  @override
  Widget build(BuildContext context) {
    return _isSignIn
        ? SignInPage(
            onSignUpTap: () {
              setState(() {
                _isSignIn = false;
              });
            },
          )
        : SignUpPage(
            onSignInTap: () {
              setState(() {
                _isSignIn = true;
              });
            },
          );
  }
}
