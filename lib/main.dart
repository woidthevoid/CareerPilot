import 'package:flutter/material.dart';
import 'package:job_tracker/screens/login_screen.dart';
import 'package:job_tracker/services/job_applications_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:job_tracker/screens/dashboard_screen.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
      url: 'https://znlyezdoxqdkravzrqhy.supabase.co',
      anonKey: 'sb_publishable_4p0QTK3wL1-OaKkMMGLa2w_rMOdBcCD');
  runApp(
    ChangeNotifierProvider(
      create: (context) => JobApplicationsProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;
    return MaterialApp(
      title: 'Career Pilot',
      theme: FlexThemeData.light(scheme: FlexScheme.aquaBlue) ,
      darkTheme: FlexThemeData.dark(scheme: FlexScheme.aquaBlue),
      home: session != null ? const DashboardScreen() : const LoginScreen(),
    );
  }
}
