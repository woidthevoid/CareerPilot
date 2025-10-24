import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:career_pilot/models/user_profile.dart';

class UserProfileService {
  final SupabaseClient _client;

  UserProfileService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  UserProfile? _cache;
  bool _hasFetched = false;
  Future<UserProfile?>? _ongoingFetch;

  bool get hasData => _cache != null;
  UserProfile? get cachedProfile => _cache;

  Future<UserProfile?> fetchProfile({bool force = false}) {
    if (!force && _hasFetched && _ongoingFetch == null) {
      return Future.value(_cache);
    }

    _ongoingFetch ??= _doFetch().whenComplete(() => _ongoingFetch = null);
    return _ongoingFetch!;
  }

  Future<UserProfile?> _doFetch() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw StateError('No authenticated user');
    }

    try {
      final response = await _client
          .from('profiles')
          .select('first_name, last_name, birthday, profile_picture')
          .eq('user_id', user.id)
          .maybeSingle();

      if (response == null) {
        _hasFetched = true;
        return _cache;
      }

      final profile = UserProfile(
        firstName: response['first_name'] as String?,
        lastName: response['last_name'] as String?,
        profilePicture: response['profile_picture'] as String?,
        birthday: response['birthday'] != null
            ? DateTime.tryParse(response['birthday'] as String) : null,
      );

      _cache = profile;
      _hasFetched = true;
      return _cache;
    } catch (e) {
      rethrow;
    }
  }

  void reset() {
    _cache = null;
    _hasFetched = false;
    _ongoingFetch = null;
  }
}