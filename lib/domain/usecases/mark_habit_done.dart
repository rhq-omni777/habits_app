import '../repositories/progress_repository.dart';

class MarkHabitDone {
  final ProgressRepository repo;
  MarkHabitDone(this.repo);
  Future<void> call(String userId, String habitId, DateTime day) => repo.markDone(userId, habitId, day);
}
