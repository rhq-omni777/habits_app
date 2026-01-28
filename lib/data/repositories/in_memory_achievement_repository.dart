import '../../domain/entities/achievement_entity.dart';
import '../../domain/repositories/achievement_repository.dart';
import '../datasources/in_memory_store.dart';
import '../models/achievement_model.dart';

class InMemoryAchievementRepository implements AchievementRepository {
  final InMemoryStore _store = InMemoryStore.instance;

  @override
  Future<void> upsert(String userId, AchievementEntity achievement) async {
    final index = _store.achievements.indexWhere((a) => a.id == achievement.id);
    final model = AchievementModel(
      id: achievement.id,
      title: achievement.title,
      description: achievement.description,
      threshold: achievement.threshold,
      unlocked: achievement.unlocked,
    );
    if (index >= 0) {
      _store.achievements[index] = model;
    } else {
      _store.achievements.add(model);
    }
    _store.emitAchievements();
  }

  @override
  Stream<List<AchievementEntity>> watchAchievements(String userId) {
    if (_store.achievements.isEmpty) {
      _store.achievements.addAll([
        const AchievementModel(
          id: 'first1',
          title: 'Primer paso',
          description: 'Completa tu primer hábito',
          threshold: 1,
          unlocked: false,
        ),
        const AchievementModel(
          id: 'streak3',
          title: 'Racha inicial',
          description: 'Completa 3 días seguidos',
          threshold: 3,
          unlocked: false,
        ),
        const AchievementModel(
          id: 'streak7',
          title: 'Constancia',
          description: 'Completa 7 días seguidos',
          threshold: 7,
          unlocked: false,
        ),
        const AchievementModel(
          id: 'streak14',
          title: 'Maestro semanal',
          description: '14 días con tus hábitos',
          threshold: 14,
          unlocked: false,
        ),
        const AchievementModel(
          id: 'streak30',
          title: 'Leyenda de la racha',
          description: '30 días de constancia',
          threshold: 30,
          unlocked: false,
        ),
        const AchievementModel(
          id: 'completions10',
          title: 'Pequeños pasos',
          description: '10 hábitos completados en total',
          threshold: 10,
          unlocked: false,
        ),
        const AchievementModel(
          id: 'completions25',
          title: 'Rutina firme',
          description: '25 hábitos completados en total',
          threshold: 25,
          unlocked: false,
        ),
        const AchievementModel(
          id: 'completions50',
          title: 'Cincuenta logros',
          description: '50 hábitos completados',
          threshold: 50,
          unlocked: false,
        ),
        const AchievementModel(
          id: 'completions75',
          title: 'Disciplina total',
          description: '75 hábitos completados',
          threshold: 75,
          unlocked: false,
        ),
        const AchievementModel(
          id: 'completions100',
          title: 'Centurion saludable',
          description: '100 hábitos completados',
          threshold: 100,
          unlocked: false,
        ),
        const AchievementModel(
          id: 'completions150',
          title: 'Héroe de hábitos',
          description: '150 hábitos completados',
          threshold: 150,
          unlocked: false,
        ),
      ]);
    }
    Future.microtask(_store.emitAchievements);
    return _store.achievementChanges();
  }
}
