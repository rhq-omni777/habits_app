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
  }

  void _configureLocalTimezone() {
    final offset = DateTime.now().timeZoneOffset;
    final offsetHours = offset.inHours;
    final etcName = 'Etc/GMT${offsetHours <= 0 ? '+' : '-'}${offsetHours.abs()}';
    try {
      tz.setLocalLocation(tz.getLocation(etcName));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('Etc/UTC'));
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
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'habits_channel',
          'Recordatorios de hábitos',
          importance: Importance.high,
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
