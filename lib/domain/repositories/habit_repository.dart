import '../entities/habit_entity.dart';

abstract class HabitRepository {
  Stream<List<HabitEntity>> watchHabits(String userId);
  Future<void> addHabit(String userId, HabitEntity habit);
  Future<void> updateHabit(String userId, HabitEntity habit);
  Future<void> deleteHabit(String userId, String habitId);
}
