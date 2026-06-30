// Entidad de dominio que representa el progreso de un hábito.

// Representa si un hábito fue completado en un día.
class HabitProgressEntity {
  final String habitId;
  final DateTime date; // day in UTC
  final bool completed;

  const HabitProgressEntity({
    required this.habitId,
    required this.date,
    required this.completed,
  });
}
