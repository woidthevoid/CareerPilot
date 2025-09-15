import 'package:flutter/material.dart';
import 'package:CareerPilot/screens/dashboard_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_login/flutter_login.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  Duration get loginTime => const Duration(milliseconds: 2250);

  // Login with supabase
  Future<String?> _authUser(LoginData data) async {
    try {
      final res = await Supabase.instance.client.auth.signInWithPassword(
        email: data.name,
        password: data.password,
      );

      if (res.user == null) {
        return 'Login failed';
      }
      return null; // success
    } on AuthException catch (e) {
      return e.message; // shows in the login widget
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  // recover password with email
  Future<String?> _recoverPassword(String email) async {
    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(email);
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  Future<String?> _signupUser(SignupData data) async {
    try {
      await Supabase.instance.client.auth
          .signUp(password: data.password!, email: data.name!);
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Unexpected error: $e';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      title: 'Login',
      logo: AssetImage('assets/logo.png'),
      onLogin: _authUser,
      onRecoverPassword: _recoverPassword,
      onSignup: _signupUser,
      onSubmitAnimationCompleted: () {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => const DashboardScreen(),
        ));
      },
      theme: LoginTheme(
        logoWidth: 1,
      ),
    );
  }
}
