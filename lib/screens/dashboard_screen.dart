import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:job_tracker/screens/login_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  Future<void> _signOut(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();
    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
      ),
      body: const Center(
        child: Text(
          'dashboard',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _signOut(context),
        child: const Icon(Icons.logout),
      ),
    );
  }
}
