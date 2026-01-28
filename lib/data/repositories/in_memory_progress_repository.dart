import '../../domain/entities/habit_progress_entity.dart';
import '../../domain/repositories/progress_repository.dart';
import '../datasources/in_memory_store.dart';
import '../models/habit_progress_model.dart';

class InMemoryProgressRepository implements ProgressRepository {
  final InMemoryStore _store = InMemoryStore.instance;

  @override
  Future<void> markDone(String userId, String habitId, DateTime day) async {
    final normalized = DateTime.utc(day.year, day.month, day.day);
    _store.progress.removeWhere((p) => p.habitId == habitId && p.date == normalized);
    _store.progress.add(HabitProgressModel(habitId: habitId, date: normalized, completed: true));
    _store.emitProgress();
  }

  @override
  Future<void> unmark(String userId, String habitId, DateTime day) async {
    final normalized = DateTime.utc(day.year, day.month, day.day);
    _store.progress.removeWhere((p) => p.habitId == habitId && p.date == normalized);
    _store.emitProgress();
  }

  @override
  Stream<List<HabitProgressEntity>> watchProgress(String userId) {
    Future.microtask(_store.emitProgress);
    return _store.progressChanges();
  }
}
