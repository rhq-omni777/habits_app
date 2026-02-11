import 'package:flutter_test/flutter_test.dart';
import 'package:habits_app/domain/usecases/mark_habit_done.dart';
import 'package:habits_app/data/repositories/in_memory_progress_repository.dart';
import 'package:habits_app/data/datasources/in_memory_store.dart';

void main() {
  test('MarkHabitDone marks a day as completed', () async {
    // Limpiar estado global antes del test
    InMemoryStore.instance.clear();
    final repo = InMemoryProgressRepository();
    final usecase = MarkHabitDone(repo);

    final today = DateTime.utc(2026, 2, 11);
    await usecase.call('user1', 'h1', today);

    final stream = repo.watchProgress('user1');
    final progress = await stream.first;
    expect(progress.any((p) => p.habitId == 'h1' && p.date.year == today.year && p.date.month == today.month && p.date.day == today.day), isTrue);
  });
}
