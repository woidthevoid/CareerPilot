import 'package:CareerPilot/services/user_profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:CareerPilot/screens/login_screen.dart';
import 'package:CareerPilot/services/job_applications_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:CareerPilot/screens/dashboard_screen.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
      url: 'https://znlyezdoxqdkravzrqhy.supabase.co',
      anonKey: 'sb_publishable_4p0QTK3wL1-OaKkMMGLa2w_rMOdBcCD');
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => JobApplicationsProvider()),
        ChangeNotifierProvider(create: (_) => UserProfileProvider()),
      ],
      child: MyApp(),
      )
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
      theme: FlexThemeData.light(scheme: FlexScheme.indigo) ,
      darkTheme: FlexThemeData.dark(scheme: FlexScheme.indigo),
      routerConfig: _router,
    );
  }
}
