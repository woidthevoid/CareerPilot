import 'package:flutter/material.dart';
import 'package:job_tracker/models/job_application.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class JobApplicationsProvider extends ChangeNotifier {
  final SupabaseClient _client = Supabase.instance.client;

  List<JobApplication> _applications = [];
  bool _isLoading = false;
  bool _hasInitiallyFetched = false;
  String? _errorMessage;

  List<JobApplication> get applications => _applications;
  bool get isLoading => _isLoading;
  bool get hasData => _applications.isNotEmpty;
  bool get hasInitiallyFetched => _hasInitiallyFetched;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearErrorMessage() {
    _errorMessage = null;
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void reset() {
    _applications = [];
    _hasInitiallyFetched = false;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> refreshApplications() async {
    await _fetchApplications();
  }

  Future<void> fetchApplications({bool force = false}) async {
    if(!force && _hasInitiallyFetched) {
      return;
}

    await _fetchApplications();
}

Future<void> _fetchApplications() async {
    _setLoading(true);
    _clearErrorMessage();

    try {
      final response = await _client
          .from('job_applications')
          .select('id, title, description, job_link, created_at, application_status')
          .order('created_at', ascending: false);

      _applications = response.map<JobApplication>((item) => JobApplication(
        id: item['id'].toString(),
        title: item['title'] ?? '',
        description: item['description'] ?? '',
        jobLink: item['job_link'] ?? '',
        createdAt: DateTime.tryParse(item['created_at'] ?? '') ?? DateTime.now(),
        applicationStatus: item['application_status'] ?? 'not applied'
      )).toList();

      _hasInitiallyFetched = true;
    } catch (e) {
      _setError('Failed to fetch applications: $e');
    } finally {
      _setLoading(false);
    }

}

}