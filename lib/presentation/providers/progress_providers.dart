import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/config/app_config.dart';
import '../../data/repositories/firebase_progress_repository.dart';
import '../../data/repositories/in_memory_progress_repository.dart';
import '../../domain/entities/habit_progress_entity.dart';
import '../../domain/repositories/progress_repository.dart';
import '../../domain/usecases/mark_habit_done.dart';
import '../../domain/usecases/unmark_habit.dart';
import '../providers/auth_providers.dart';

final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  if (kUseFirebase) return FirebaseProgressRepository();
  return InMemoryProgressRepository();
});

final progressProvider = StateNotifierProvider<ProgressNotifier, AsyncValue<List<HabitProgressEntity>>>((ref) {
  final auth = ref.watch(authStateProvider).valueOrNull;
  final repo = ref.watch(progressRepositoryProvider);
  return ProgressNotifier(
    repo: repo,
    markHabitDone: MarkHabitDone(repo),
    unmarkHabit: UnmarkHabit(repo),
    userId: auth?.id,
  );
});

class ProgressNotifier extends StateNotifier<AsyncValue<List<HabitProgressEntity>>> {
  ProgressNotifier({
    required this.repo,
    required this.markHabitDone,
    required this.unmarkHabit,
    required this.userId,
  }) : super(const AsyncLoading()) {
    _init();
  }

  final ProgressRepository repo;
  final MarkHabitDone markHabitDone;
  final UnmarkHabit unmarkHabit;
  final String? userId;
  StreamSubscription<List<HabitProgressEntity>>? _sub;

  Future<void> _init() async {
    if (userId == null) {
      state = const AsyncData([]);
      return;
    }
    _sub = repo.watchProgress(userId!).listen((data) => state = AsyncData(data));
  }

  Future<void> toggleToday(String habitId) async {
    if (userId == null) return;
    final today = DateTime.now().toUtc();
    final normalized = DateTime.utc(today.year, today.month, today.day);
    final list = state.value ?? [];
    final exists = list.any((p) => p.habitId == habitId && p.date == normalized && p.completed);
    if (exists) {
      await unmarkHabit(userId!, habitId, normalized);
    } else {
      await markHabitDone(userId!, habitId, normalized);
    }
  }

  int streakForHabit(String habitId) {
    final list = state.value ?? [];
    final dates = list.where((p) => p.habitId == habitId && p.completed).map((p) => p.date).toSet();
    int streak = 0;
    DateTime cursor = DateTime.utc(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    while (dates.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
