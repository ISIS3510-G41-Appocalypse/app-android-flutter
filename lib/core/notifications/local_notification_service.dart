import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  static const AndroidNotificationChannel _driverNearbyChannel =
      AndroidNotificationChannel(
        'driver_nearby_channel',
        'Driver Nearby Alerts',
        description: 'Notificaciones cuando el conductor esta cerca.',
        importance: Importance.high,
      );

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initializationSettings = InitializationSettings(
      android: androidSettings,
    );

    await _plugin.initialize(initializationSettings);

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin
    >();

    await androidPlugin?.createNotificationChannel(_driverNearbyChannel);
    await androidPlugin?.requestNotificationsPermission();
  }

  Future<void> showDriverNearbyNotification({
    required String rideId,
    required String driverName,
    required double distanceMeters,
  }) async {
    final normalizedDistance = distanceMeters.clamp(0, 200).toDouble();
    final distanceLabel = normalizedDistance.toStringAsFixed(0);

    await _plugin.show(
      rideId.hashCode,
      'Tu conductor esta cerca',
      '$driverName esta a $distanceLabel m de ti. Alistate para ser recogido.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'driver_nearby_channel',
          'Driver Nearby Alerts',
          channelDescription:
              'Notificaciones cuando el conductor esta cerca.',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }
}
