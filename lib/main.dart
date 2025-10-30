import 'package:flutter/material.dart';
import 'package:career_pilot/screens/login_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:career_pilot/screens/dashboard_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  late final GoRouter _router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final session = Supabase.instance.client.auth.currentSession;
      final isLoggedIn = session != null;
      final isLoginPage = state.matchedLocation == '/login';

      if (!isLoggedIn && !isLoginPage) {
        return '/login';
      }

      if (isLoggedIn && isLoginPage) {
        return '/dashboard';
      }

      if (isLoggedIn && state.matchedLocation == '/') {
        return '/dashboard';
      }

      if (!isLoggedIn && state.matchedLocation == '/') {
        return '/login';
      }

      return null;
    },

    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/',
        redirect: (context, state) {
          final session = Supabase.instance.client.auth.currentSession;
          return session != null ? '/dashboard' : '/login';
        },
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'CareerPilot',
      theme: FlexThemeData.light(scheme: FlexScheme.aquaBlue),
      darkTheme: FlexThemeData.dark(scheme: FlexScheme.aquaBlue),
      routerConfig: _router,
    );
  }
}
