import 'dart:nativewrappers/_internal/vm/lib/internal_patch.dart';

import 'package:job_tracker/models/job_application.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  Future<List<JobApplication>> fetchCardData() async {
    try {
      final response = await _supabaseClient.from('job_applications').select(
          'id, title, description, job_link, created_at, application_status');

      if (response.isNotEmpty) {
        return response.map((item) {
          return JobApplication(
            id: item['id'].toString(),
            title: item['title'] as String,
            description: item['description'] as String,
            jobLink: item['job_link'] as String,
            createdAt: DateTime.parse(item['created_at'] as String),
            applicationStatus: item['application_status'] as String,
          );
        }).toList();
      } else {
        printToConsole('No data found');
        return [];
      }
    } catch (e) {
      printToConsole('error fetching data: $e');
      rethrow;
    }
  }
}
