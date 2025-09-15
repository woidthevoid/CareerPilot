import 'package:flutter/material.dart';
import 'package:CareerPilot/screens/login_screen.dart';
import 'package:CareerPilot/services/job_applications_provider.dart';
import 'package:CareerPilot/widgets/application_card.dart';
import 'package:CareerPilot/widgets/stats_header.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Dashboard'),
          elevation: 0,
          backgroundColor: Theme.of(context).colorScheme.primary,
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
                        child: ListView.builder(
                          itemCount: provider.applications.length,
                          itemBuilder: (context, index) {
                            final application = provider.applications[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: ApplicationCard(
                                application: application,
                                cardColor: Theme.of(context).colorScheme.surfaceContainer,
                              ),
                            );
                          },
                        ),
                      )
                    ],
                  )));
        }));
  }
}
