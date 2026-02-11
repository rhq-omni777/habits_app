// Almacén en memoria usado por los repositorios `InMemory*` para pruebas y demo.
// Provee colecciones y streams que simulan una base de datos local.

import 'dart:async';
import '../models/achievement_model.dart';
import '../models/habit_model.dart';
import '../models/habit_progress_model.dart';
import '../models/user_model.dart';

class InMemoryStore {
  InMemoryStore._();
  static final InMemoryStore instance = InMemoryStore._();

  UserModel? currentUser;
  final _authController = StreamController<UserModel?>.broadcast();

  final List<HabitModel> habits = [];
  final _habitController = StreamController<List<HabitModel>>.broadcast();

  final List<HabitProgressModel> progress = [];
  final _progressController = StreamController<List<HabitProgressModel>>.broadcast();

  final List<AchievementModel> achievements = [];
  final _achievementController = StreamController<List<AchievementModel>>.broadcast();

  Stream<UserModel?> authChanges() => _authController.stream;
  Stream<List<HabitModel>> habitChanges() => _habitController.stream;
  Stream<List<HabitProgressModel>> progressChanges() => _progressController.stream;
  Stream<List<AchievementModel>> achievementChanges() => _achievementController.stream;

  void emitAuth(UserModel? user) => _authController.add(user);
  void emitHabits() => _habitController.add(List.unmodifiable(habits));
  void emitProgress() => _progressController.add(List.unmodifiable(progress));
  void emitAchievements() => _achievementController.add(List.unmodifiable(achievements));

  /// Limpia el estado interno del store y emite colecciones vacías.
  void clear() {
    currentUser = null;
    habits.clear();
    progress.clear();
    achievements.clear();
    // Emitir estados vacíos para que listeners reciban actualización.
    try {
      _authController.add(null);
    } catch (_) {}
    try {
      _habitController.add(List.unmodifiable(habits));
    } catch (_) {}
    try {
      _progressController.add(List.unmodifiable(progress));
    } catch (_) {}
    try {
      _achievementController.add(List.unmodifiable(achievements));
    } catch (_) {}
  }

  void dispose() {
    _authController.close();
    _habitController.close();
    _progressController.close();
    _achievementController.close();
  }
}
