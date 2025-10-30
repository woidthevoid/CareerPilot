import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:career_pilot/models/job_application.dart';

class JobApplicationService {
  final SupabaseClient _client;
  final String? _testUserId; // For testing only

  JobApplicationService({
    SupabaseClient? client,
    String? testUserId, 
  })  : _client = client ?? Supabase.instance.client,
        _testUserId = testUserId;

  List<JobApplication>? _cachedApplications;

  Future<List<JobApplication>> get applications async {
    // ignore: prefer_conditional_assignment
    if (_cachedApplications == null) {
      _cachedApplications = await _fetchFromDatabase();
    }
    return List.unmodifiable(_cachedApplications!);
  }

  Future<List<JobApplication>> refresh() async {
    _cachedApplications = await _fetchFromDatabase();
    return List.unmodifiable(_cachedApplications!);
  }

  String? get _currentUserId {
    if (_testUserId != null) return _testUserId;
    return _client.auth.currentUser?.id;
  }

  Future<List<JobApplication>> _fetchFromDatabase() async {
    final userId = _currentUserId;
    if (userId == null) {
      throw StateError('No authenticated user');
    }

    try {
      final response = await _client
          .from('job_applications')
          .select(
            'id, user_id, company_name, title, description, job_link, created_at, application_status',
          )
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List).map<JobApplication>((item) {
        return JobApplication(
          id: item['id'].toString(),
          userId: item['user_id']?.toString() ?? '',
          companyName: item['company_name'] ?? '',
          title: item['title'] ?? '',
          description: item['description'] ?? '',
          jobLink: item['job_link'] ?? '',
          createdAt: DateTime.tryParse(item['created_at'] ?? '') ?? DateTime.now(),
          applicationStatus: item['application_status'] ?? 'not applied',
        );
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<JobApplication> addApplication(JobApplication application) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw StateError('No authenticated user');
    }

    try {
      final response = await _client
          .from('job_applications')
          .insert({
            'title': application.title,
            'user_id': userId,
            'company_name': application.companyName,
            'description': application.description,
            'job_link': application.jobLink,
            'application_status': application.applicationStatus,
            'created_at': application.createdAt.toIso8601String(),
          })
          .select()
          .single();

      final JobApplication created = JobApplication(
        id: response['id'].toString(),
        userId: response['user_id']?.toString() ?? '',
        companyName: response['company_name'] ?? '',
        title: response['title'] ?? '',
        description: response['description'] ?? '',
        jobLink: response['job_link'] ?? '',
        createdAt: DateTime.tryParse(response['created_at'] ?? '') ?? DateTime.now(),
        applicationStatus: response['application_status'] ?? 'not applied',
      );

      if (_cachedApplications != null) {
        _cachedApplications = [created, ..._cachedApplications!];
      }

      return created;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteApplication(String id) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw StateError('No authenticated user');
    }

    try {
      await _client
          .from('job_applications')
          .delete()
          .eq('id', id)
          .eq('user_id', userId);

      if (_cachedApplications != null) {
        _cachedApplications = _cachedApplications!
            .where((app) => app.id != id)
            .toList();
      }
    } catch (e) {
      rethrow;
    }
  }
  
  void resetCache() {
    _cachedApplications = null;
  }
}