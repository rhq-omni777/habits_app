// Modelo que representa el progreso de un hábito en un día concreto.

import '../../domain/entities/habit_progress_entity.dart';

// Modelo para guardar y leer progreso desde Firestore.
class HabitProgressModel extends HabitProgressEntity {
  const HabitProgressModel({required super.habitId, required super.date, required super.completed});

  factory HabitProgressModel.fromMap(Map<String, dynamic> map) => HabitProgressModel(
        habitId: map['habitId'] as String,
        date: DateTime.tryParse(map['date'] as String? ?? '') ?? DateTime.now().toUtc(),
        completed: map['completed'] as bool? ?? false,
      );

  // Ejecuta la lógica relacionada con to map.
  Map<String, dynamic> toMap() => {
        'habitId': habitId,
        'date': date.toIso8601String(),
        'completed': completed,
      };
}
