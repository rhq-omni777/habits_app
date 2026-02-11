import 'package:flutter_test/flutter_test.dart';
import 'package:habits_app/domain/usecases/add_habit.dart';
import 'package:habits_app/data/repositories/in_memory_habit_repository.dart';
import 'package:habits_app/domain/entities/habit_entity.dart';
import 'package:habits_app/data/datasources/in_memory_store.dart';

void main() {
  test('AddHabit usecase adds a habit to in-memory repo', () async {
    // Limpiar estado global para evitar interferencias entre tests.
    InMemoryStore.instance.clear();
    final repo = InMemoryHabitRepository();
    final usecase = AddHabit(repo);

    final habit = HabitEntity(
      id: 'h1',
      title: 'Test Habit',
      description: 'desc',
      frequency: HabitFrequency.daily,
      weekDays: [],
      reminderMinutes: 8 * 60,
      notificationsEnabled: true,
      createdAt: DateTime.now(),
      iconCodePoint: 0xe7fd,
    );

    await usecase.call('user1', habit);

    final stream = repo.watchHabits('user1');
    final list = await stream.first;
    expect(list.any((h) => h.id == 'h1'), isTrue);
  });
}
