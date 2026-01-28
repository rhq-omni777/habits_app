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
