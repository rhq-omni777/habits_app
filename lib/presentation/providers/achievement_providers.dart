import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/config/app_config.dart';
import '../../data/repositories/firebase_achievement_repository.dart';
import '../../data/repositories/in_memory_achievement_repository.dart';
import '../../domain/entities/achievement_entity.dart';
import '../../domain/repositories/achievement_repository.dart';
import '../providers/auth_providers.dart';
import '../providers/progress_providers.dart';

final achievementRepositoryProvider = Provider<AchievementRepository>((ref) {
  if (kUseFirebase) return FirebaseAchievementRepository();
  return InMemoryAchievementRepository();
});

final achievementsProvider = StateNotifierProvider<AchievementsNotifier, AsyncValue<List<AchievementEntity>>>((ref) {
  final auth = ref.watch(authStateProvider).valueOrNull;
  final repo = ref.watch(achievementRepositoryProvider);
  final progress = ref.watch(progressProvider).value ?? [];
  return AchievementsNotifier(repo: repo, userId: auth?.id, progressCount: progress.length);
});

class AchievementsNotifier extends StateNotifier<AsyncValue<List<AchievementEntity>>> {
  AchievementsNotifier({required this.repo, required this.userId, required this.progressCount})
      : super(const AsyncLoading()) {
    _init();
  }

  final AchievementRepository repo;
  final String? userId;
  final int progressCount;
  StreamSubscription<List<AchievementEntity>>? _sub;

  Future<void> _init() async {
    final base = _baseAchievements(progressCount);
    if (userId == null) {
      state = AsyncData(base);
      return;
    }
    _sub = repo.watchAchievements(userId!).listen((data) {
      final updated = (data.isEmpty ? base : data)
          .map((a) => AchievementEntity(
                id: a.id,
                title: a.title,
                description: a.description,
                threshold: a.threshold,
                unlocked: a.unlocked || progressCount >= a.threshold,
              ))
          .toList();
      state = AsyncData(updated);
    });
  }

  List<AchievementEntity> _baseAchievements(int progressCount) => const [
        AchievementEntity(
          id: 'first1',
          title: 'Primer paso',
          description: 'Completa tu primer hábito',
          threshold: 1,
          unlocked: false,
        ),
        AchievementEntity(
          id: 'streak3',
          title: 'Racha inicial',
          description: 'Completa 3 días seguidos',
          threshold: 3,
          unlocked: false,
        ),
        AchievementEntity(
          id: 'streak7',
          title: 'Constancia',
          description: 'Completa 7 días seguidos',
          threshold: 7,
          unlocked: false,
        ),
        AchievementEntity(
          id: 'streak14',
          title: 'Maestro semanal',
          description: '14 días con tus hábitos',
          threshold: 14,
          unlocked: false,
        ),
        AchievementEntity(
          id: 'streak30',
          title: 'Leyenda de la racha',
          description: '30 días de constancia',
          threshold: 30,
          unlocked: false,
        ),
        AchievementEntity(
          id: 'completions10',
          title: 'Pequeños pasos',
          description: '10 hábitos completados en total',
          threshold: 10,
          unlocked: false,
        ),
        AchievementEntity(
          id: 'completions25',
          title: 'Rutina firme',
          description: '25 hábitos completados en total',
          threshold: 25,
          unlocked: false,
        ),
        AchievementEntity(
          id: 'completions50',
          title: 'Cincuenta logros',
          description: '50 hábitos completados',
          threshold: 50,
          unlocked: false,
        ),
        AchievementEntity(
          id: 'completions75',
          title: 'Disciplina total',
          description: '75 hábitos completados',
          threshold: 75,
          unlocked: false,
        ),
        AchievementEntity(
          id: 'completions100',
          title: 'Centurion saludable',
          description: '100 hábitos completados',
          threshold: 100,
          unlocked: false,
        ),
        AchievementEntity(
          id: 'completions150',
          title: 'Héroe de hábitos',
          description: '150 hábitos completados',
          threshold: 150,
          unlocked: false,
        ),
        AchievementEntity(
          id: 'completions200',
          title: 'Maratón de constancia',
          description: '200 hábitos completados',
          threshold: 200,
          unlocked: false,
        ),
      ]
          .map((a) => AchievementEntity(
                id: a.id,
                title: a.title,
                description: a.description,
                threshold: a.threshold,
                unlocked: progressCount >= a.threshold,
              ))
          .toList();

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
