// Caso de uso para actualizar un hábito existente.

import '../entities/habit_entity.dart';
import '../repositories/habit_repository.dart';

class UpdateHabit {
  final HabitRepository repo;
  UpdateHabit(this.repo);

  // Ejecuta la lógica relacionada con call.
  Future<void> call(String userId, HabitEntity habit) => repo.updateHabit(userId, habit);
}
