import 'package:flutter/material.dart';
import 'package:job_tracker/screens/login_screen.dart';
import 'package:job_tracker/services/job_applications_provider.dart';
import 'package:job_tracker/widgets/application_card.dart';
import 'package:job_tracker/widgets/stats_header.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JobApplicationsProvider>().fetchApplications();
    });
  }

  Future<void> _signOut(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();
    if (context.mounted) {
      context.read<JobApplicationsProvider>().reset();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  final List<Color> _cardColors = [
    Colors.red.shade400,
    Colors.blue.shade400,
    Colors.green.shade400,
    Colors.orange.shade400,
    Colors.purple.shade400,
    Colors.teal.shade400,
    Colors.indigo.shade400,
    Colors.pink.shade400,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Dashboard'),
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () => _signOut(context),
            ),
          ],
        ),
        body: Consumer<JobApplicationsProvider>(
            builder: (context, provider, child) {
          if (provider.isLoading && !provider.hasInitiallyFetched) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loaing your applications...')
                ],
              ),
            );
          }

          if (provider.errorMessage != null) {
            return Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                const SizedBox(height: 8),
                Text(
                  provider.errorMessage!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => provider.refreshApplications(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                ),
              ],
            ));
          }

          if (provider.applications.isEmpty) {
            return Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.work_outline, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  'No job applications yet',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Add a new job application to get started',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add),
                    label: const Text('Add your first job')),
              ],
            ));
          }

          return RefreshIndicator(
              onRefresh: provider.refreshApplications,
              child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      StatsHeader(applications: provider.applications),
                      const SizedBox(height: 24),
                      Expanded(
                          child: LayoutBuilder(builder: (context, constraints) {
                        int crossAxisCount = 2;
                        if (constraints.maxWidth > 900) {
                          crossAxisCount = 4;
                        } else if (constraints.maxWidth > 600) {
                          crossAxisCount = 3;
                        }

                        return GridView.builder(
                          itemCount: provider.applications.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1.4,
                          ),
                          itemBuilder: (context, index) {
                            final application = provider.applications[index];
                            final color =
                                _cardColors[index % _cardColors.length];
                            return ApplicationCard(
                              application: application,
                              cardColor: color,
                            );
                          },
                        );
                      }))
                    ],
                  )));
        }));
  }
}
