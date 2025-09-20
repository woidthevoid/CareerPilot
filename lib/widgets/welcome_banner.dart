import 'package:flutter/material.dart';
import 'package:CareerPilot/services/user_profile_provider.dart';
import 'package:provider/provider.dart';

class WelcomeBanner extends StatelessWidget {
  const WelcomeBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProfileProvider>(
      builder: (context, profileProvider, child) {
        return Text(
          'Greetings, ${profileProvider.displayName}',
          textAlign: TextAlign.start,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        );
      },
    );
  }
}