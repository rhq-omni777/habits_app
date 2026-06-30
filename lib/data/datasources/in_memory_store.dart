// Almacén en memoria usado por los repositorios `InMemory*` para pruebas y demo.
// Provee colecciones y streams que simulan una base de datos local.

import 'dart:async';
import '../models/achievement_model.dart';
import '../models/habit_model.dart';
import '../models/habit_progress_model.dart';
import '../models/user_model.dart';

// Almacena datos temporales en memoria para pruebas o respaldo.
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

  // Ejecuta la lógica relacionada con auth changes.
  Stream<UserModel?> authChanges() => _authController.stream;

  // Ejecuta la lógica relacionada con habit changes.
  Stream<List<HabitModel>> habitChanges() => _habitController.stream;

  // Ejecuta la lógica relacionada con progress changes.
  Stream<List<HabitProgressModel>> progressChanges() => _progressController.stream;

  // Ejecuta la lógica relacionada con achievement changes.
  Stream<List<AchievementModel>> achievementChanges() => _achievementController.stream;

  // Ejecuta la lógica relacionada con emit auth.
  void emitAuth(UserModel? user) => _authController.add(user);

  // Ejecuta la lógica relacionada con emit habits.
  void emitHabits() => _habitController.add(List.unmodifiable(habits));

  // Ejecuta la lógica relacionada con emit progress.
  void emitProgress() => _progressController.add(List.unmodifiable(progress));

  // Ejecuta la lógica relacionada con emit achievements.
  void emitAchievements() => _achievementController.add(List.unmodifiable(achievements));

  /// Limpia el estado interno del store y emite colecciones vacías.

  // Ejecuta la lógica relacionada con clear.
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

  // Libera los recursos cuando el widget deja de usarse.
  void dispose() {
    _authController.close();
    _habitController.close();
    _progressController.close();
    _achievementController.close();
  }
}
