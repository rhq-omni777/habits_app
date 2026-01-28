import '../../domain/entities/habit_entity.dart';
import '../../domain/repositories/habit_repository.dart';
import '../datasources/in_memory_store.dart';
import '../models/habit_model.dart';

class InMemoryHabitRepository implements HabitRepository {
  final InMemoryStore _store = InMemoryStore.instance;

  @override
  Future<void> addHabit(String userId, HabitEntity habit) async {
    final model = HabitModel(
      id: habit.id,
      title: habit.title,
      description: habit.description,
      frequency: habit.frequency,
      weekDays: habit.weekDays,
      reminderMinutes: habit.reminderMinutes,
      notificationsEnabled: habit.notificationsEnabled,
      createdAt: habit.createdAt,
      iconCodePoint: habit.iconCodePoint,
      iconFontFamily: habit.iconFontFamily,
      iconFontPackage: habit.iconFontPackage,
    );
    _store.habits.add(model);
    _store.emitHabits();
  }

  @override
  Future<void> deleteHabit(String userId, String habitId) async {
    _store.habits.removeWhere((h) => h.id == habitId);
    _store.emitHabits();
  }

  @override
  Future<void> updateHabit(String userId, HabitEntity habit) async {
    final index = _store.habits.indexWhere((h) => h.id == habit.id);
    if (index >= 0) {
      _store.habits[index] = HabitModel(
        id: habit.id,
        title: habit.title,
        description: habit.description,
        frequency: habit.frequency,
        weekDays: habit.weekDays,
        reminderMinutes: habit.reminderMinutes,
        notificationsEnabled: habit.notificationsEnabled,
        createdAt: habit.createdAt,
        iconCodePoint: habit.iconCodePoint,
        iconFontFamily: habit.iconFontFamily,
        iconFontPackage: habit.iconFontPackage,
      );
      _store.emitHabits();
    }
  }

  @override
  Stream<List<HabitEntity>> watchHabits(String userId) {
    Future.microtask(_store.emitHabits);
    return _store.habitChanges();
  }
}
