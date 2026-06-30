// Modelo que representa un logro para convertirlo a y desde datos.

import '../../domain/entities/achievement_entity.dart';

// Modelo para guardar y leer logros desde Firestore.
class AchievementModel extends AchievementEntity {
  const AchievementModel({
    required super.id,
    required super.title,
    required super.description,
    required super.threshold,
    required super.unlocked,
  });

  factory AchievementModel.fromMap(Map<String, dynamic> map) => AchievementModel(
        id: map['id'] as String,
        title: map['title'] as String,
        description: map['description'] as String? ?? '',
        threshold: map['threshold'] as int? ?? 0,
        unlocked: map['unlocked'] as bool? ?? false,
      );

  // Ejecuta la lógica relacionada con to map.
  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'threshold': threshold,
        'unlocked': unlocked,
      };
}
