import '../repositories/habit_repository.dart';

class DeleteHabit {
  final HabitRepository repo;
  DeleteHabit(this.repo);
  Future<void> call(String userId, String habitId) => repo.deleteHabit(userId, habitId);
}
