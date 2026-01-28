import '../entities/habit_entity.dart';
import '../repositories/habit_repository.dart';

class UpdateHabit {
  final HabitRepository repo;
  UpdateHabit(this.repo);
  Future<void> call(String userId, HabitEntity habit) => repo.updateHabit(userId, habit);
}
