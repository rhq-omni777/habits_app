import '../entities/habit_progress_entity.dart';

abstract class ProgressRepository {
  Stream<List<HabitProgressEntity>> watchProgress(String userId);
  Future<void> markDone(String userId, String habitId, DateTime day);
  Future<void> unmark(String userId, String habitId, DateTime day);
}
