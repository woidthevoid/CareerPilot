import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:career_pilot/providers/user_profile_notifier.dart';
import 'package:career_pilot/providers/job_application_notifier.dart';
import 'package:career_pilot/widgets/application_card.dart';
import 'package:career_pilot/widgets/stats_header.dart';
import 'package:career_pilot/widgets/welcome_banner.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:career_pilot/widgets/new_application_modal.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(jobApplicationsNotifierProvider.notifier).load();
      ref.read(userProfileNotifierProvider.notifier).load();
    });
  }

  Future<void> _signOut(BuildContext context) async {
    final router = GoRouter.of(context);

    await Supabase.instance.client.auth.signOut();
    if (!mounted) return;
    
    ref.read(jobApplicationsNotifierProvider.notifier).reset();
    ref.read(userProfileNotifierProvider.notifier).reset();
    router.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final appsAsync = ref.watch(jobApplicationsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        leading: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.menu),
          color: Theme.of(context).colorScheme.onPrimary,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _signOut(context),
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ],
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: WelcomeBanner(),
          ),
          Expanded(
            child: appsAsync.when(
              loading: () => const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading your applications...'),
                  ],
                ),
              ),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline,
                        size: 64, color: Colors.red.shade300),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => ref
                          .read(jobApplicationsNotifierProvider.notifier)
                          .load(force: true),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh'),
                    ),
                  ],
                ),
              ),
              data: (apps) {
                if (apps.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.work_outline,
                            size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text('No job applications yet',
                            style: Theme.of(context).textTheme.headlineSmall),
                        const SizedBox(height: 8),
                        Text('Add a new job application to get started',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: Colors.grey.shade600)),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) =>
                                    const NewApplicationModal());
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Add your first job'),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => ref
                      .read(jobApplicationsNotifierProvider.notifier)
                      .load(force: true),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        StatsHeader(applications: apps),
                        const SizedBox(height: 24),
                        Expanded(
                          child: ListView.builder(
                            itemCount: apps.length,
                            itemBuilder: (context, index) {
                              final application = apps[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: ApplicationCard(
                                  application: application,
                                  cardColor: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainer,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => const NewApplicationModal());
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        child: const Icon(Icons.add),
      ),
    );
  }
}
