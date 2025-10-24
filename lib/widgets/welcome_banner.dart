import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:career_pilot/providers/user_profile_notifier.dart';

class WelcomeBanner extends ConsumerWidget {
  const WelcomeBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileNotifierProvider);

    return profileAsync.when(
      loading: () => Text(
        'Greetings,',
        textAlign: TextAlign.start,
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      error: (_, __) => Text(
        'Greetings,',
        textAlign: TextAlign.start,
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      data: (profile) => Text(
        'Greetings, ${profile?.displayName ?? 'User'}',
        textAlign: TextAlign.start,
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}