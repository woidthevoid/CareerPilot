
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:career_pilot/models/job_application.dart';

class JobApplicationService {
  final SupabaseClient _client;

  JobApplicationService({SupabaseClient? client})
  : _client = client ?? Supabase.instance.client;

  final List<JobApplication> _cache = [];
  bool _hasFetched = false;
  Future<List<JobApplication>>? _ongoingFetch;

  List<JobApplication> get cachedApplications => List.unmodifiable(_cache);

  Future<List<JobApplication>> fetchApplications({bool force = false}) async {

    if (!force && _hasFetched) {
      return Future.value(List.unmodifiable(_cache));
    }

    _ongoingFetch ??= _doFetch().whenComplete(() => _ongoingFetch = null);
    return _ongoingFetch!;
  }

  Future<List<JobApplication>> _doFetch() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw StateError('No authenticated user');
    }

    try {
      final response = await _client
          .from('job_applications')
          .select(
            'id, user_id, company_name, title, description, job_link, created_at, application_status',
          )
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      if (response.isEmpty) return List.unmodifiable(_cache);

      final List<JobApplication> fetched = (response as List).map<JobApplication>((item) {
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

      if (!_hasFetched || _cache.isEmpty) {
        _cache
          ..clear()
          ..addAll(fetched);
        _hasFetched = true;
      } else {
        final cachedIds = _cache.map((e) => e.id).toSet();
        final newItems = fetched.where((f) => !cachedIds.contains(f.id)).toList();
        if (newItems.isNotEmpty) {
          _cache.insertAll(0, newItems);
        }
        final fetchedIds = fetched.map((e) => e.id).toSet();
        _cache.removeWhere((c) => !fetchedIds.contains(c.id));
      }

      return List.unmodifiable(_cache);
    } catch (e) {
      rethrow;
    }
  }

  Future<JobApplication> addApplication(JobApplication application) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw StateError('No authenticated user');
    }

    try {
      final inserted = await _client
          .from('job_applications')
          .insert({
            'title': application.title,
            'user_id': user.id,
            'company_name': application.companyName,
            'description': application.description,
            'job_link': application.jobLink,
            'application_status': application.applicationStatus,
            'created_at': application.createdAt.toIso8601String(),
          })
          .select()
          .single();

      final JobApplication created = JobApplication(
        id: inserted['id'].toString(),
        userId: inserted['user_id']?.toString() ?? '',
        companyName: inserted['company_name'] ?? '',
        title: inserted['title'] ?? '',
        description: inserted['description'] ?? '',
        jobLink: inserted['job_link'] ?? '',
        createdAt: DateTime.tryParse(inserted['created_at'] ?? '') ?? DateTime.now(),
        applicationStatus: inserted['application_status'] ?? 'not applied',
      );

      _cache.insert(0, created);
      _hasFetched = true;
      return created;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteApplication(String id) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw StateError('No authenticated user');
    }

    try {
      await _client
          .from('job_applications')
          .delete()
          .eq('id', id)
          .eq('user_id', user.id);

      _cache.removeWhere((app) => app.id == id);
    } catch (e) {
      rethrow;
    }
  }

  void resetCache() {
    _cache.clear();
    _hasFetched = false;
    _ongoingFetch = null;
  }

}