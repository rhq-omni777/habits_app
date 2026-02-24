// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habits_app/main.dart';
import 'package:habits_app/presentation/providers/achievement_providers.dart';
import 'package:habits_app/presentation/providers/auth_providers.dart';
import 'package:habits_app/presentation/providers/habit_providers.dart';
import 'package:habits_app/presentation/providers/progress_providers.dart';
import 'package:habits_app/data/repositories/in_memory_auth_repository.dart';
import 'package:habits_app/data/repositories/in_memory_habit_repository.dart';
import 'package:habits_app/data/repositories/in_memory_progress_repository.dart';
import 'package:habits_app/data/repositories/in_memory_achievement_repository.dart';
import 'package:habits_app/data/datasources/in_memory_store.dart';
import 'package:habits_app/domain/entities/user_entity.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Carga inicial redirige al login sin sesión', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(InMemoryAuthRepository()),
          authChangesProvider.overrideWithValue(Stream<UserEntity?>.value(null)),
          habitRepositoryProvider.overrideWithValue(InMemoryHabitRepository()),
          progressRepositoryProvider.overrideWithValue(InMemoryProgressRepository()),
          achievementRepositoryProvider.overrideWithValue(InMemoryAchievementRepository()),
        ],
        child: const HabitsApp(),
      ),
    );

    // Emitir estado inicial de autenticación (null) después de montar la app
    // para que los listeners del Stream broadcast lo reciban.
    InMemoryStore.instance.emitAuth(null);

    // Espera navegación inicial.
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Otra espera corta por si hay microtasks asíncronas.
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Bienvenido de vuelta'), findsOneWidget);
  });
}
