import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  static const AndroidNotificationChannel _driverNearbyChannel =
      AndroidNotificationChannel(
        'driver_nearby_channel',
        'Driver Nearby Alerts',
        description: 'Notificaciones cuando el conductor esta cerca.',
        importance: Importance.high,
      );
  static const AndroidNotificationChannel _paymentsChannel =
      AndroidNotificationChannel(
        'payments_channel',
        'Payment Alerts',
        description: 'Notificaciones sobre pagos de viajes.',
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

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidPlugin?.createNotificationChannel(_driverNearbyChannel);
    await androidPlugin?.createNotificationChannel(_paymentsChannel);
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
          channelDescription: 'Notificaciones cuando el conductor esta cerca.',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }

  Future<void> showPassengerPaymentSubmittedNotification({
    required int paymentId,
    required String riderName,
    required String rideLabel,
    required int amount,
    required String method,
  }) async {
    await _showPaymentNotification(
      id: paymentId,
      title: 'Pago por confirmar',
      body:
          '$riderName marco como pagado $amount por $rideLabel usando $method.',
    );
  }

  Future<void> showPaymentConfirmedNotification({
    required int paymentId,
    required String driverName,
    required int amount,
  }) async {
    await _showPaymentNotification(
      id: paymentId + 100000,
      title: 'Pago confirmado',
      body: '$driverName confirmo la recepcion de tu pago de $amount.',
    );
  }

  Future<void> showPaymentRejectedNotification({
    required int paymentId,
    required String driverName,
    required int amount,
  }) async {
    await _showPaymentNotification(
      id: paymentId + 200000,
      title: 'Pago no confirmado',
      body:
          '$driverName no confirmo la recepcion de tu pago de $amount. Revisa el metodo e intenta de nuevo.',
    );
  }

  Future<void> _showPaymentNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    await _plugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'payments_channel',
          'Payment Alerts',
          channelDescription: 'Notificaciones sobre pagos de viajes.',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }
}
