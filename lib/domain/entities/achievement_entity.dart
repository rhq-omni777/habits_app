class AchievementEntity {
  final String id;
  final String title;
  final String description;
  final int threshold;
  final bool unlocked;

  const AchievementEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.threshold,
    required this.unlocked,
  });
}
