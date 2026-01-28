enum HabitFrequency { daily, weekly }

class HabitEntity {
  final String id;
  final String title;
  final String description;
  final HabitFrequency frequency;
  final List<int> weekDays; // 1=Monday...7=Sunday for weekly
  final int reminderMinutes; // minutes from midnight
  final bool notificationsEnabled;
  final DateTime createdAt;
  final int iconCodePoint; // stores material icon code point
  final String iconFontFamily;
  final String? iconFontPackage;

  const HabitEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.frequency,
    required this.weekDays,
    required this.reminderMinutes,
    required this.notificationsEnabled,
    required this.createdAt,
    required this.iconCodePoint,
    this.iconFontFamily = 'MaterialIcons',
    this.iconFontPackage,
  });
}
