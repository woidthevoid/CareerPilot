import 'package:flutter/material.dart';

import '../models/job_application.dart';
import 'build_stat_item.dart';

class StatsHeader extends StatelessWidget {
  final List<JobApplication> applications;

  const StatsHeader({
    super.key,
    required this.applications,
  });

  @override
  Widget build(BuildContext context) {
    final totalCount = applications.length;
    final appliedCount = applications.where((app) =>
    app.applicationStatus.toLowerCase() == 'applied').length;
    final interviewingCount = applications.where((app) =>
    app.applicationStatus.toLowerCase() == 'interview').length;
    final rejectedCount = applications.where((app) =>
    app.applicationStatus.toLowerCase() == 'declined').length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Application Overview',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: StatItem(
                  label: 'Total',
                  value: totalCount.toString(),
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatItem(
                  label: 'Applied',
                  value: appliedCount.toString(),
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatItem(
                  label: 'Interview',
                  value: interviewingCount.toString(),
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatItem(
                  label: 'Declined',
                  value: rejectedCount.toString(),
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}