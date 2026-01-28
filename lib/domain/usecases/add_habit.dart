import '../entities/habit_entity.dart';
import '../repositories/habit_repository.dart';

class AddHabit {
  final HabitRepository repo;
  AddHabit(this.repo);
  Future<void> call(String userId, HabitEntity habit) => repo.addHabit(userId, habit);
}
