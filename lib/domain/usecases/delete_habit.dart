// Caso de uso para eliminar un hábito.

import '../repositories/habit_repository.dart';

class DeleteHabit {
  final HabitRepository repo;
  DeleteHabit(this.repo);

  // Ejecuta la lógica relacionada con call.
  Future<void> call(String userId, String habitId) => repo.deleteHabit(userId, habitId);
}
