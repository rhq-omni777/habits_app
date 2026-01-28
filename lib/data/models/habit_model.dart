import '../../domain/entities/habit_entity.dart';

// Code point for Material Icons "check_circle_outline"
const int _defaultHabitIcon = 0xe86c;
const String _defaultHabitFontFamily = 'MaterialIcons';

class HabitModel extends HabitEntity {
  const HabitModel({
    required super.id,
    required super.title,
    required super.description,
    required super.frequency,
    required super.weekDays,
    required super.reminderMinutes,
    required super.notificationsEnabled,
    required super.createdAt,
    required super.iconCodePoint,
    super.iconFontFamily = _defaultHabitFontFamily,
    super.iconFontPackage,
  });

  factory HabitModel.fromMap(Map<String, dynamic> map) => HabitModel(
        id: map['id'] as String,
        title: map['title'] as String,
        description: map['description'] as String? ?? '',
        frequency: HabitFrequency.values.firstWhere(
          (f) => f.name == (map['frequency'] as String?),
          orElse: () => HabitFrequency.daily,
        ),
        weekDays: List<int>.from(map['weekDays'] as List? ?? const []),
        reminderMinutes: map['reminderMinutes'] as int? ?? 480,
        notificationsEnabled: map['notificationsEnabled'] as bool? ?? false,
        createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
        iconCodePoint: map['iconCodePoint'] as int? ?? _defaultHabitIcon,
        iconFontFamily: map['iconFontFamily'] as String? ?? _defaultHabitFontFamily,
        iconFontPackage: map['iconFontPackage'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'frequency': frequency.name,
        'weekDays': weekDays,
        'reminderMinutes': reminderMinutes,
        'notificationsEnabled': notificationsEnabled,
        'createdAt': createdAt.toIso8601String(),
        'iconCodePoint': iconCodePoint,
        'iconFontFamily': iconFontFamily,
        'iconFontPackage': iconFontPackage,
      };
}
