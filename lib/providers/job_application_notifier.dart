import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:career_pilot/models/job_application.dart';
import 'package:career_pilot/services/jobapplication_service.dart';

final jobApplicationServiceProvider =
    Provider<JobApplicationService>((ref) => JobApplicationService());

final jobApplicationsFutureProvider =
    FutureProvider.autoDispose<List<JobApplication>>((ref) async {
  final svc = ref.read(jobApplicationServiceProvider);
  return svc.applications;
});

class JobApplicationNotifier
    extends StateNotifier<AsyncValue<List<JobApplication>>> {
  final Ref ref;

  JobApplicationNotifier(this.ref) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load({bool force = false}) async {
    if (!force && state is AsyncData && (state as AsyncData).value.isNotEmpty) {
      return;
    }

    state = const AsyncValue.loading();
    try {
      final svc = ref.read(jobApplicationServiceProvider);
      final list = force ? await svc.refresh() : await svc.applications;
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addApplication(JobApplication app) async {
    final prev = state;
    try {
      final created =
          await ref.read(jobApplicationServiceProvider).addApplication(app);
      final current = (state is AsyncData)
          ? (state as AsyncData<List<JobApplication>>).value
          : <JobApplication>[];
      final updated = [created, ...current];
      state = AsyncValue.data(updated);
    } catch (e, st) {
      state = prev;
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> deleteApplication(String id) async {
    final previous = state;
    if (state is AsyncData) {
      final newList = List<JobApplication>.from((state as AsyncData).value)
        ..removeWhere((a) => a.id == id);
      state = AsyncValue.data(newList);
    }

    try {
      await ref.read(jobApplicationServiceProvider).deleteApplication(id);
    } catch (e, st) {
      state = previous;
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  void reset() {
    ref.read(jobApplicationServiceProvider).resetCache();
    state = const AsyncValue.data([]);
  }
}

final jobApplicationsNotifierProvider = StateNotifierProvider.autoDispose<
    JobApplicationNotifier, AsyncValue<List<JobApplication>>>(
  (ref) => JobApplicationNotifier(ref),
);
