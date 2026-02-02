import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/config/app_config.dart';
import 'core/services/notifications_service.dart';
import 'core/services/location_service.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kUseFirebase) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  }
  final onSelect = (NotificationResponse response) async {
    final ctx = rootNavigatorKey.currentContext;
    if (ctx != null) {
      final payload = response.payload;
      if (payload != null && payload.isNotEmpty) {
        GoRouter.of(ctx).go('/home', extra: payload);
      } else {
        GoRouter.of(ctx).go('/home');
      }
    }
  };
  await NotificationsService.instance.init(onSelect: onSelect);
  // Request location once to align time/zone from device GPS if available.
  await LocationService.instance.ensureLocationAccess();
  runApp(const ProviderScope(child: HabitsApp()));
}

class HabitsApp extends ConsumerWidget {
  const HabitsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'Hábitos Saludables',
      routerConfig: router,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
    );
  }
}
