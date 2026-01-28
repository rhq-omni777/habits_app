import '../repositories/progress_repository.dart';

class UnmarkHabit {
  final ProgressRepository repo;
  UnmarkHabit(this.repo);
  Future<void> call(String userId, String habitId, DateTime day) => repo.unmark(userId, habitId, day);
}
