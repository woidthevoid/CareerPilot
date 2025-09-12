import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:job_tracker/screens/login_screen.dart';
import 'package:job_tracker/widgets/application_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:job_tracker/models/job_application.dart';

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

  // Create a list of dummy data to display
  List<JobApplication> _getDummyData() {
    return [
      JobApplication(
          id: '1',
          title: 'Fullstack dev',
          description: 'Software Engineer',
          applicationStatus: 'Applied',
          createdAt: DateTime.now(),
          jobLink:
              'https://again.teamtailor.com/jobs/6191085-student-assistant-data-engineering?ittk=ICDJTPOTEU'),
      JobApplication(
          id: '2',
          title: 'Lol',
          description: 'Product Manager',
          applicationStatus: 'Interviewing',
          createdAt: DateTime.now(),
          jobLink:
              'https://again.teamtailor.com/jobs/6191085-student-assistant-data-engineering?ittk=ICDJTPOTEU'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final applications = _getDummyData();
    final colors = [
      Colors.red.shade400,
      Colors.blue.shade400,
      Colors.green.shade400,
      Colors.orange.shade400,
      Colors.purple.shade400,
      Colors.teal.shade400,
    ];
    return Scaffold(
        appBar: AppBar(
          title: Text('Dashboard'),
          actions: [
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () => _signOut(context),
            ),
          ],
        ),
        body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
                itemCount: applications.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: 1.5,
                ),
                itemBuilder: (context, index) {
                  final application = applications[index];
                  final color = colors[index % colors.length];
                  return ApplicationCard(application: application, cardColor: color);
                })));
  }
}
