import '../entities/achievement_entity.dart';

abstract class AchievementRepository {
  Stream<List<AchievementEntity>> watchAchievements(String userId);
  Future<void> upsert(String userId, AchievementEntity achievement);
}
