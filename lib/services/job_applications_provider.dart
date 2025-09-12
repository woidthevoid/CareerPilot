import 'package:flutter/material.dart';
import 'package:job_tracker/models/job_application.dart';
import 'package:job_tracker/services/supabase_service.dart';

class JobApplicationsProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  List<JobApplication> _applications = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<JobApplication> get applications => _applications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchApplications() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _applications = await _supabaseService.fetchCardData();
    } catch (e) {
      _errorMessage = 'Failed to fetch applications: $e';
      _applications = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

}