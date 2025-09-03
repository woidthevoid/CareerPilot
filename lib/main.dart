import 'package:flutter/material.dart';
import 'package:job_tracker/screens/login_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:job_tracker/screens/dashboard_screen.dart';

Future<void> main() async {
  await Supabase.initialize(
      url: 'https://znlyezdoxqdkravzrqhy.supabase.co',
      anonKey: 'sb_publishable_4p0QTK3wL1-OaKkMMGLa2w_rMOdBcCD');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;
    return MaterialApp(
      title: 'Job Tracker',
      theme: FlexThemeData.light(scheme: FlexScheme.brandBlue) ,
      darkTheme: FlexThemeData.dark(scheme: FlexScheme.brandBlue),
      home: session != null ? const DashboardScreen() : const LoginScreen(),
    );
  }
}
