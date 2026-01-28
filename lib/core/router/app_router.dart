import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/habit_entity.dart';
import '../../presentation/pages/habit_form_page.dart';
import '../../presentation/pages/home_page.dart';
import '../../presentation/pages/login_page.dart';
import '../../presentation/pages/profile_page.dart';
import '../../presentation/pages/register_page.dart';
import '../../presentation/pages/splash_page.dart';
import '../../presentation/pages/stats_page.dart';
import '../../presentation/pages/wellness_library_page.dart';
import '../../presentation/pages/legal_page.dart';
import '../../presentation/providers/auth_providers.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authStream = ref.watch(authChangesProvider);
  final refresh = _StreamListenable(authStream);
  ref.onDispose(refresh.dispose);
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refresh,
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/habit/new',
        builder: (context, state) => const HabitFormPage(),
      ),
      GoRoute(
        path: '/habit/edit',
        builder: (context, state) => HabitFormPage(habit: state.extra as HabitEntity?),
      ),
      GoRoute(
        path: '/stats',
        builder: (context, state) => const StatsPage(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: '/library',
        builder: (context, state) => const WellnessLibraryPage(),
      ),
      GoRoute(
        path: '/legal',
        builder: (context, state) => const LegalPage(),
      ),
    ],
    redirect: (context, state) {
      final auth = ref.read(authStateProvider).valueOrNull;
      final loggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/register';
      if (auth == null && !loggingIn) return '/login';
      if (auth != null && (state.matchedLocation == '/login' || state.matchedLocation == '/register' || state.matchedLocation == '/splash')) {
        return '/home';
      }
      return null;
    },
  );
});

class _StreamListenable extends ChangeNotifier {
  _StreamListenable(Stream<dynamic> stream) {
    _sub = stream.listen((_) => notifyListeners());
  }
  late final StreamSubscription _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
