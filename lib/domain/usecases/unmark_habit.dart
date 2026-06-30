// Caso de uso para desmarcar un hábito completado.

import '../repositories/progress_repository.dart';

class UnmarkHabit {
  final ProgressRepository repo;
  UnmarkHabit(this.repo);

  // Ejecuta la lógica relacionada con call.
  Future<void> call(String userId, String habitId, DateTime day) => repo.unmark(userId, habitId, day);
}
