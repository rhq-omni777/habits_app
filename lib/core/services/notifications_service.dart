import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationsService {
  NotificationsService._();
  static final NotificationsService instance = NotificationsService._();
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  static const String _channelId = 'habits_reminders';
  static const String _channelName = 'Recordatorios de hábitos';
  static const String _channelDescription = 'Notificaciones diarias para recordar tus hábitos';

  /// Deterministic notification id from habit id (stable across runs).
  int notificationId(String habitId) {
    var hash = 0;
    for (final codeUnit in habitId.codeUnits) {
      hash = (hash * 31 + codeUnit) & 0x7fffffff;
    }
    return hash;
  }

  Future<void> init({Future<void> Function(NotificationResponse response)? onSelect}) async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings = InitializationSettings(android: androidSettings, iOS: darwinSettings, macOS: darwinSettings);

    await _configureLocalTimezone();

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: onSelect ?? _defaultOnSelect,
    );
    await _ensureAndroidChannel();
    final granted = await requestPermission();
    debugPrint('[Notifications] permission=${granted ? 'granted' : 'denied'} zone=${tz.local.name}');
  }

  Future<void> _configureLocalTimezone() async {
    tz.initializeTimeZones();
    final timeZoneName = DateTime.now().timeZoneName;
    final offsetMinutes = DateTime.now().timeZoneOffset.inMinutes;

    // Fallback rápido por offset si el nombre no está en la base de datos.
    const offsetToZone = {
      -300: 'America/Guayaquil',
      -240: 'America/Bogota',
      -360: 'America/Mexico_City',
      0: 'UTC',
    };

    try {
      final loc = tz.getLocation(timeZoneName);
      tz.setLocalLocation(loc);
      debugPrint('[Notifications] set local zone by name: $timeZoneName (offset=$offsetMinutes)');
      return;
    } catch (_) {
      // Continúa con fallback por offset.
    }

    final fallbackZone = offsetToZone[offsetMinutes] ?? 'UTC';
    try {
      final loc = fallbackZone == 'UTC' ? tz.UTC : tz.getLocation(fallbackZone);
      tz.setLocalLocation(loc);
      debugPrint('[Notifications] fallback zone: $fallbackZone (offset=$offsetMinutes)');
    } catch (e) {
      tz.setLocalLocation(tz.UTC);
      debugPrint('[Notifications] fallback zone UTC (offset=$offsetMinutes) error=$e');
    }
  }

  /// Solicita permisos en Android 13+ y iOS/macOS.
  Future<bool> requestPermission() async {
    bool granted = true;

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      granted = (await androidPlugin.requestNotificationsPermission()) ?? granted;
    }

    final iosPlugin = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    if (iosPlugin != null) {
      final iosGranted = await iosPlugin.requestPermissions(alert: true, badge: true, sound: true);
      granted = granted && (iosGranted ?? false);
    }

    final macPlugin = _plugin.resolvePlatformSpecificImplementation<MacOSFlutterLocalNotificationsPlugin>();
    if (macPlugin != null) {
      final macGranted = await macPlugin.requestPermissions(alert: true, badge: true, sound: true);
      granted = granted && (macGranted ?? false);
    }

    return granted;
  }

  Future<void> scheduleDaily({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String? payload,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    debugPrint('[Notifications] scheduling id=$id at ${scheduled.toIso8601String()} local=${tz.local.name}');
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
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
      payload: payload,
    );
  }

  Future<void> cancel(int id) async {
    await _plugin.cancel(id);
  }

  Future<void> _ensureAndroidChannel() async {
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return;
    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.max,
    );
    await android.createNotificationChannel(channel);
  }

  Future<void> _defaultOnSelect(NotificationResponse response) async {
    debugPrint('[Notifications] tapped payload=${response.payload}');
  }
}
