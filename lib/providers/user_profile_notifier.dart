import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:career_pilot/services/user_profile_service.dart';
import 'package:career_pilot/models/user_profile.dart';

final userProfileServiceProvider =
    Provider<UserProfileService>((ref) => UserProfileService());

class UserProfileNotifier extends StateNotifier<AsyncValue<UserProfile?>> {
  final Ref ref;
  UserProfileNotifier(this.ref) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load({bool force = false}) async {
    if (!force && state is AsyncData && (state as AsyncData).value != null) {
      return;
    }

    state = const AsyncValue.loading();
    try {
      final service = ref.read(userProfileServiceProvider);
      final profile = await service.fetchProfile(force: force);
      state = AsyncValue.data(profile);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() => load(force: true);

  void reset() {
    ref.read(userProfileServiceProvider).reset();
    state = const AsyncValue.data(null);
  }
}

final userProfileNotifierProvider = StateNotifierProvider.autoDispose<
    UserProfileNotifier, AsyncValue<UserProfile?>>(
  (ref) => UserProfileNotifier(ref),
);