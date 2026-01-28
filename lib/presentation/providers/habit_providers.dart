import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/config/app_config.dart';
import '../../core/services/notifications_service.dart';
import '../../data/repositories/firebase_habit_repository.dart';
import '../../data/repositories/in_memory_habit_repository.dart';
import '../../domain/entities/habit_entity.dart';
import '../../domain/repositories/habit_repository.dart';
import '../../domain/usecases/add_habit.dart';
import '../../domain/usecases/delete_habit.dart';
import '../../domain/usecases/update_habit.dart';
import '../providers/auth_providers.dart';

final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  if (kUseFirebase) return FirebaseHabitRepository();
  return InMemoryHabitRepository();
});

final habitsProvider = StateNotifierProvider<HabitsNotifier, AsyncValue<List<HabitEntity>>>((ref) {
  final auth = ref.watch(authStateProvider).valueOrNull;
  final repo = ref.watch(habitRepositoryProvider);
  return HabitsNotifier(
    repo: repo,
    addHabit: AddHabit(repo),
    updateHabit: UpdateHabit(repo),
    deleteHabit: DeleteHabit(repo),
    userId: auth?.id,
  );
});

class HabitsNotifier extends StateNotifier<AsyncValue<List<HabitEntity>>> {
  HabitsNotifier({
    required this.repo,
    required this.addHabit,
    required this.updateHabit,
    required this.deleteHabit,
    required this.userId,
  }) : super(const AsyncLoading()) {
    _init();
  }

  final HabitRepository repo;
  final AddHabit addHabit;
  final UpdateHabit updateHabit;
  final DeleteHabit deleteHabit;
  final String? userId;
  StreamSubscription<List<HabitEntity>>? _sub;

  Future<void> _init() async {
    if (userId == null) {
      state = const AsyncData([]);
      return;
    }
    _sub = repo.watchHabits(userId!).listen((data) => state = AsyncData(data));
  }

  Future<void> createHabit(HabitEntity habit) async {
    if (userId == null) return;
    await addHabit(userId!, habit);
    if (habit.notificationsEnabled) {
      await NotificationsService.instance.scheduleDaily(
        id: habit.id.hashCode,
        title: 'Recordatorio: ${habit.title}',
        body: habit.description,
        hour: habit.reminderMinutes ~/ 60,
        minute: habit.reminderMinutes % 60,
      );
    }
  }

  Future<void> editHabit(HabitEntity habit) async {
    if (userId == null) return;
    await updateHabit(userId!, habit);
    if (habit.notificationsEnabled) {
      await NotificationsService.instance.scheduleDaily(
        id: habit.id.hashCode,
        title: 'Recordatorio: ${habit.title}',
        body: habit.description,
        hour: habit.reminderMinutes ~/ 60,
        minute: habit.reminderMinutes % 60,
      );
    } else {
      await NotificationsService.instance.cancel(habit.id.hashCode);
    }
  }

  Future<void> removeHabit(String habitId) async {
    if (userId == null) return;
    await deleteHabit(userId!, habitId);
    await NotificationsService.instance.cancel(habitId.hashCode);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
