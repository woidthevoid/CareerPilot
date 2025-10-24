import 'package:flutter/material.dart';
import 'package:career_pilot/models/job_application.dart';

extension JobApplicationStatusHelpers on JobApplication {
  Color get statusColor {
    switch (applicationStatus.toLowerCase()) {
      case 'applied':
        return Colors.orange;
      case 'interview':
        return Colors.green;
      case 'declined':
        return Colors.red;
      case 'accepted':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData get statusIcon {
    switch (applicationStatus.toLowerCase()) {
      case 'applied':
        return Icons.send;
      case 'interview':
        return Icons.person;
      case 'declined':
        return Icons.close;
      case 'accepted':
        return Icons.check;
      default:
        return Icons.help;
    }
  }

  String get statusLabel {
    switch (applicationStatus.toLowerCase()) {
      case 'applied':
        return 'Applied';
      case 'interview':
        return 'Interview';
      case 'declined':
        return 'Declined';
      case 'accepted':
        return 'Accepted';
      case 'not_applied':
        return 'Not Applied';
      default:
        return 'Unknown';
    }
  }
}