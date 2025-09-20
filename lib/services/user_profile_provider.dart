import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

class UserProfileProvider extends ChangeNotifier {
  final SupabaseClient _client = Supabase.instance.client;

  String? _firstName;
  String? _lastName;
  String? _profilePicture;
  DateTime? _birthday;
  bool _isLoading = false;
  bool _hasInitiallyFetched = false;
  String? _errorMessage;

  String? get firstName => _firstName;
  String? get lastName => _lastName;
  String? get profilePicture => _profilePicture;
  DateTime? get birthday => _birthday;
  bool get isLoading => _isLoading;
  bool get hasData => _firstName != null || _lastName != null;
  bool get hasInitiallyFetched => _hasInitiallyFetched;
  String? get errorMessage => _errorMessage;

  String get displayName {
    if (_firstName != null && _lastName != null) {
      return '$_firstName $_lastName';
    } else if (_firstName != null) {
      return _firstName!;
    } else if (_lastName != null) {
      return _lastName!;
    } else {
      return 'User';
    }
  }

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
    _firstName = null;
    _lastName = null;
    _profilePicture = null;
    _birthday = null;
    _hasInitiallyFetched = false;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> refreshProfile() async {
    await _fetchProfile();
  }

  Future<void> fetchProfile({bool force = false}) async {
    if (!force && _hasInitiallyFetched) {
      return;
    }

    await _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    _setLoading(true);
    _clearErrorMessage();

    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        _setError('No authenticated user');
        return;
      }

      final response = await _client
          .from('profiles')
          .select('first_name, last_name, birthday, profile_picture')
          .eq('user_id', user.id)
          .maybeSingle();

      if (response != null) {
        _firstName = response['first_name'];
        _lastName = response['last_name'];
        _profilePicture = response['profile_picture'];
        _birthday = response['birthday'] != null 
            ? DateTime.tryParse(response['birthday']) 
            : null;
      }

      _hasInitiallyFetched = true;
    } catch (e) {
      _setError('Failed to fetch profile: $e');
    } finally {
      _setLoading(false);
    }
  }

}