import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationsService {
  NotificationsService._();
  static final NotificationsService instance = NotificationsService._();
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  /// Deterministic notification id from habit id (stable across runs).
  int notificationId(String habitId) {
    var hash = 0;
    for (final codeUnit in habitId.codeUnits) {
      hash = (hash * 31 + codeUnit) & 0x7fffffff;
    }
    return hash;
  }

  Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(initSettings);
    tz.initializeTimeZones();
    _configureLocalTimezone();
    final granted = await requestPermission();
    // Debug trace: permission and zone
    // ignore: avoid_print
    print('[Notifications] permission=${granted ? 'granted' : 'denied'} zone=${tz.local.name}');
  }

  void _configureLocalTimezone() {
    final offsetMinutes = DateTime.now().timeZoneOffset.inMinutes;

    // Quick mapping by offset to stable IANA zone ids (extend as needed).
    const offsetToZone = {
      -300: 'America/Guayaquil', // Ecuador (UTC-5)
      -240: 'America/Bogota',
      -360: 'America/Mexico_City',
      0: 'UTC',
    };

    final zoneId = offsetToZone[offsetMinutes] ?? 'UTC';
    try {
      if (zoneId == 'UTC') {
        tz.setLocalLocation(tz.UTC);
      } else {
        final loc = tz.getLocation(zoneId);
        tz.setLocalLocation(loc);
      }
      // ignore: avoid_print
      print('[Notifications] set local zone to $zoneId (offset minutes=$offsetMinutes)');
    } catch (e) {
      tz.setLocalLocation(tz.UTC);
      // ignore: avoid_print
      print('[Notifications] fallback zone UTC (offset minutes=$offsetMinutes) error=$e');
    }
  }

  /// Requests runtime notification permission on Android 13+.
  Future<bool> requestPermission() async {
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin == null) return false;
    final granted = await androidPlugin.requestNotificationsPermission();
    return granted ?? false;
  }

  Future<void> scheduleDaily({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    // ignore: avoid_print
    print('[Notifications] scheduling id=$id at ${scheduled.toIso8601String()} local=${tz.local.name}');
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'habits_reminders',
          'Recordatorios de hábitos',
          channelDescription: 'Notificaciones diarias para recordar tus hábitos',
          importance: Importance.max,
          priority: Priority.high,
          enableVibration: true,
          playSound: true,
          icon: 'ic_stat_habit',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.wallClockTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancel(int id) async {
    await _plugin.cancel(id);
  }
}
