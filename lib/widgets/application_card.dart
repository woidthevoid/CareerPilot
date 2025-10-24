import 'package:flutter/material.dart';
import 'package:career_pilot/models/job_application.dart';
import 'package:career_pilot/models/job_application_extensions.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:career_pilot/providers/job_application_notifier.dart';

class ApplicationCard extends ConsumerStatefulWidget {
  final JobApplication application;
  final Color cardColor;

  const ApplicationCard({
    super.key,
    required this.application,
    required this.cardColor,
  });

  @override
  ConsumerState<ApplicationCard> createState() => _ApplicationCardState();
}

class _ApplicationCardState extends ConsumerState<ApplicationCard> {
  JobApplication get application => widget.application;

  Future<void> _launchUrl(BuildContext context, String url) async {
    final messenger = ScaffoldMessenger.of(context);
    final uri = Uri.parse(url);

    try {
      if (!await canLaunchUrl(uri)) {
        if (!mounted) return;
        messenger.showSnackBar(const SnackBar(content: Text('Could not open URL')));
        return;
      }

      final launched = await launchUrl(uri);
      if (!mounted) return;

      if (!launched) {
        messenger.showSnackBar(const SnackBar(content: Text('Could not open URL')));
      }
    } catch (_) {
      if (!mounted) return;
      messenger.showSnackBar(const SnackBar(content: Text('Could not open URL')));
    }
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.warning, color: Colors.red),
              const SizedBox(width: 8),
              const Text('Delete application'),
            ],
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Are you sure you want to delete this application?'),
              const SizedBox(height: 8),
              Text(
                '"${application.title}"',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 4),
              const Text('This action cannot be undone', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              child: const Text('Delete'),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                final messenger = ScaffoldMessenger.of(context);
                final notifier = ref.read(jobApplicationsNotifierProvider.notifier);

                messenger.showSnackBar(const SnackBar(content: Text('Deleting application')));

                try {
                  await notifier.deleteApplication(application.id);
                  if (!mounted) return;
                  messenger.showSnackBar(const SnackBar(content: Text('Application deleted'), backgroundColor: Colors.green));
                } catch (_) {
                  if (!mounted) return;
                  messenger.showSnackBar(const SnackBar(content: Text('Failed to delete application'), backgroundColor: Colors.red));
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = application.statusColor;
    final statusIcon = application.statusIcon;
    final statusText = application.statusLabel;
    final formattedDate = DateFormat('dd MM, yyyy').format(application.createdAt);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {},
        onLongPress: () => _showDeleteDialog(context),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.cardColor.withValues(alpha: 0.10),
                widget.cardColor.withValues(alpha: 0.05),
              ],
            ),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(statusIcon, size: 12, color: statusColor),
                  const SizedBox(width: 4),
                  Text(statusText, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w600)),
                ]),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.access_time, size: 12, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(formattedDate, style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500, fontSize: 10)),
                ]),
              ),
            ]),
            const SizedBox(height: 12),
            Text(application.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            Text(application.companyName, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            Text(application.description, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)), maxLines: 3, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () => _launchUrl(context, application.jobLink),
                icon: const Icon(Icons.open_in_new, size: 16),
                label: const Text('View job in Browser'),
                style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
