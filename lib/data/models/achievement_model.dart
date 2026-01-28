import '../../domain/entities/achievement_entity.dart';

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

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'threshold': threshold,
        'unlocked': unlocked,
      };
}
