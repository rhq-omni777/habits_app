// Caso de uso para marcar un hábito como completado.

import '../repositories/progress_repository.dart';

class MarkHabitDone {
  final ProgressRepository repo;
  MarkHabitDone(this.repo);

  // Ejecuta la lógica relacionada con call.
  Future<void> call(String userId, String habitId, DateTime day) => repo.markDone(userId, habitId, day);
}
