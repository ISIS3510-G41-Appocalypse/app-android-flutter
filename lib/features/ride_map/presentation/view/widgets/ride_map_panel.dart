import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../driver_rides/domain/entities/driver_ride.dart';
import '../../../../rider_rides/domain/entities/rider_ride.dart';
import '../../../../user/domain/entities/user.dart';
import '../../view_model/ride_map_cubit.dart';
import '../../view_model/ride_map_state.dart';

class RideMapPanel extends StatefulWidget {
  const RideMapPanel({super.key, required this.ride, required this.user});

  final DriverRide ride;
  final User? user;

  @override
  State<RideMapPanel> createState() => _RideMapPanelState();
}

class _RideMapPanelState extends State<RideMapPanel> {
  late final RideMapCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = GetIt.instance<RideMapCubit>();
    _load();
  }

  @override
  void didUpdateWidget(covariant RideMapPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ride.id != widget.ride.id ||
        _acceptedPassengerSignature(oldWidget.ride) !=
            _acceptedPassengerSignature(widget.ride)) {
      _load();
    }
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  void _load() {
    final passengerNamesByUserId = {
      for (final reservation in widget.ride.acceptedReservations)
        if (reservation.riderUserId > 0)
          reservation.riderUserId: reservation.riderName,
    };

    _cubit.loadDriverRideMap(
      rideId: widget.ride.id,
      driverUserId: widget.user?.id,
      passengerNamesByUserId: passengerNamesByUserId,
    );
  }

  String _acceptedPassengerSignature(DriverRide ride) {
    final ids = ride.acceptedReservations
        .map((reservation) => reservation.riderUserId)
        .where((riderUserId) => riderUserId > 0)
        .toList()
      ..sort();

    return ids.join('|');
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocBuilder<RideMapCubit, RideMapState>(
        builder: (context, state) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Mapa del viaje',
                        style: AppTextStyles.primary.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.slate900,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Actualizar ubicaciones',
                      onPressed: state.status == RideMapStatus.loading
                          ? null
                          : _load,
                      icon: const Icon(Icons.refresh_rounded),
                      color: AppColors.blue900,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (state.isOffline)
                  const _MapNotice(
                    text:
                        'Sin internet. Mostrando ultimas posiciones guardadas.',
                    color: Color(0xFF92400E),
                    background: Color(0xFFFFFBEB),
                    border: Color(0xFFFDE68A),
                  )
                else if (state.message != null)
                  _MapNotice(
                    text: state.message!,
                    color: AppColors.blue900,
                    background: const Color(0xFFEFF6FF),
                    border: const Color(0xFFBFDBFE),
                  ),
                if (state.message != null || state.isOffline)
                  const SizedBox(height: 12),
                SizedBox(
                  height: 320,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: _RideMapCanvas(
                      state: state,
                      currentLabel: 'Conductor',
                      currentMeta: 'Tu ubicacion',
                      currentInitial: 'C',
                      currentColor: AppColors.blue900,
                      remoteColor: AppColors.amber700,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _RideMapCanvas extends StatefulWidget {
  const _RideMapCanvas({
    required this.state,
    required this.currentLabel,
    required this.currentMeta,
    required this.currentInitial,
    required this.currentColor,
    required this.remoteColor,
  });

  final RideMapState state;
  final String currentLabel;
  final String currentMeta;
  final String currentInitial;
  final Color currentColor;
  final Color remoteColor;

  @override
  State<_RideMapCanvas> createState() => _RideMapCanvasState();
}

class _RideMapCanvasState extends State<_RideMapCanvas> {
  MapboxMap? _mapboxMap;
  PointAnnotationManager? _annotationManager;
  final Map<String, Uint8List> _markerImageCache = {};

  @override
  void didUpdateWidget(covariant _RideMapCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_mapboxMap != null && oldWidget.state != widget.state) {
      _syncAnnotations();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS)) {
      return const _MapFallback(
        message: 'El mapa esta disponible en Android y iOS.',
      );
    }

    if (widget.state.status == RideMapStatus.loading) {
      return const _MapFallback.loading();
    }

    final accessToken =
        dotenv.env['MAPBOX_ACCESS_TOKEN'] ??
        const String.fromEnvironment('ACCESS_TOKEN');
    if (accessToken.isEmpty) {
      return const _MapFallback(
        message:
            'Configura MAPBOX_ACCESS_TOKEN en .env o ACCESS_TOKEN con --dart-define.',
      );
    }

    return MapWidget(
      key: const ValueKey('driverRideMap'),
      cameraOptions: CameraOptions(center: _centerPoint(), zoom: 13),
      gestureRecognizers: {
        Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
      },
      styleUri: MapboxStyles.MAPBOX_STREETS,
      onMapCreated: (mapboxMap) async {
        _mapboxMap = mapboxMap;
        await _enableMapGestures(mapboxMap);
        _annotationManager = await mapboxMap.annotations
            .createPointAnnotationManager();
        await _syncAnnotations();
      },
    );
  }

  Future<void> _enableMapGestures(MapboxMap mapboxMap) async {
    await mapboxMap.gestures.updateSettings(
      GesturesSettings(
        pinchToZoomEnabled: true,
        pinchPanEnabled: true,
        scrollEnabled: true,
        rotateEnabled: true,
        pitchEnabled: true,
        doubleTapToZoomInEnabled: true,
        doubleTouchToZoomOutEnabled: true,
        quickZoomEnabled: true,
        pinchToZoomDecelerationEnabled: true,
        scrollDecelerationEnabled: true,
        rotateDecelerationEnabled: true,
      ),
    );
  }

  Point _centerPoint() {
    final lat =
        widget.state.driverLatitude ??
        (widget.state.locations.isNotEmpty
            ? widget.state.locations.first.latitude
            : 4.7110);
    final lng =
        widget.state.driverLongitude ??
        (widget.state.locations.isNotEmpty
            ? widget.state.locations.first.longitude
            : -74.0721);

    return Point(coordinates: Position(lng, lat));
  }

  Future<void> _syncAnnotations() async {
    final manager = _annotationManager;
    final map = _mapboxMap;
    if (manager == null || map == null) {
      return;
    }

    await manager.deleteAll();

    if (widget.state.driverLatitude != null &&
        widget.state.driverLongitude != null) {
      await manager.create(
        PointAnnotationOptions(
          geometry: Point(
            coordinates: Position(
              widget.state.driverLongitude!,
              widget.state.driverLatitude!,
            ),
          ),
          image: await _markerImage(
            label: widget.currentLabel,
            meta: widget.currentMeta,
            initial: widget.currentInitial,
            color: widget.currentColor,
          ),
          iconAnchor: IconAnchor.BOTTOM,
          iconSize: 1,
        ),
      );
    }

    for (final location in widget.state.locations) {
      await manager.create(
        PointAnnotationOptions(
          geometry: Point(
            coordinates: Position(location.longitude, location.latitude),
          ),
          image: await _markerImage(
            label: _shortName(location.participantName),
            meta: _distanceLabel(location.distanceMeters),
            initial: _initial(location.participantName),
            color: widget.remoteColor,
          ),
          iconAnchor: IconAnchor.BOTTOM,
          iconSize: 1,
        ),
      );
    }

    await map.flyTo(
      CameraOptions(center: _centerPoint(), zoom: 13),
      MapAnimationOptions(duration: 650),
    );
  }

  Future<Uint8List> _markerImage({
    required String label,
    required String meta,
    required String initial,
    required Color color,
  }) async {
    final cacheKey = '$label|$meta|${color.toARGB32()}';
    final cached = _markerImageCache[cacheKey];
    if (cached != null) {
      return cached;
    }

    const width = 250.0;
    const height = 118.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final labelPainter = TextPainter(
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '...',
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: Color(0xFF0F172A),
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
      ),
    )..layout(maxWidth: 142);
    final metaPainter = TextPainter(
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '...',
      text: TextSpan(
        text: meta,
        style: const TextStyle(
          color: Color(0xFF475569),
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    )..layout(maxWidth: 142);

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.22)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    final bubbleRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(14, 10, 222, 72),
      const Radius.circular(22),
    );
    canvas.drawRRect(bubbleRect.shift(const Offset(0, 5)), shadowPaint);

    final bubblePaint = Paint()..color = Colors.white;
    canvas.drawRRect(bubbleRect, bubblePaint);
    canvas.drawRRect(
      bubbleRect,
      Paint()
        ..color = color.withValues(alpha: 0.28)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    final pinCenter = Offset(width / 2, 78);
    final pinPath = Path()
      ..moveTo(pinCenter.dx, 112)
      ..cubicTo(104, 94, 86, 78, 86, 56)
      ..cubicTo(86, 30, 104, 14, pinCenter.dx, 14)
      ..cubicTo(146, 14, 164, 30, 164, 56)
      ..cubicTo(164, 78, 146, 94, pinCenter.dx, 112)
      ..close();
    canvas.drawPath(pinPath.shift(const Offset(0, 4)), shadowPaint);
    canvas.drawPath(pinPath, Paint()..color = color);
    canvas.drawPath(
      pinPath,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5,
    );

    canvas.drawCircle(
      pinCenter.translate(0, -24),
      22,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      pinCenter.translate(0, -24),
      17,
      Paint()..color = color.withValues(alpha: 0.14),
    );

    final initialPainter = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        text: initial,
        style: TextStyle(
          color: color,
          fontSize: 20,
          fontWeight: FontWeight.w900,
        ),
      ),
    )..layout();
    initialPainter.paint(
      canvas,
      pinCenter.translate(
        -initialPainter.width / 2,
        -24 - initialPainter.height / 2,
      ),
    );

    labelPainter.paint(canvas, const Offset(26, 21));
    metaPainter.paint(canvas, const Offset(26, 48));

    final picture = recorder.endRecording();
    final image = await picture.toImage(width.toInt(), height.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final markerBytes = bytes!.buffer.asUint8List();
    _markerImageCache[cacheKey] = markerBytes;
    return markerBytes;
  }

  String _shortName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return 'Pasajero';
    }

    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts.first;
    }

    return '${parts.first} ${_firstChar(parts.last)}.';
  }

  String _initial(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return 'P';
    }

    return _firstChar(trimmed).toUpperCase();
  }

  String _firstChar(String value) {
    if (value.isEmpty) {
      return '';
    }

    return String.fromCharCode(value.runes.first);
  }

  String _distanceLabel(double? distanceMeters) {
    if (distanceMeters == null) {
      return 'Pasajero';
    }

    if (distanceMeters >= 1000) {
      return '${(distanceMeters / 1000).toStringAsFixed(1)} km';
    }

    return '${distanceMeters.toStringAsFixed(0)} m';
  }
}

class RiderRideMapPanel extends StatefulWidget {
  const RiderRideMapPanel({super.key, required this.ride, required this.user});

  final RiderRide ride;
  final User? user;

  @override
  State<RiderRideMapPanel> createState() => _RiderRideMapPanelState();
}

class _RiderRideMapPanelState extends State<RiderRideMapPanel> {
  late final RideMapCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = GetIt.instance<RideMapCubit>();
    _load();
  }

  @override
  void didUpdateWidget(covariant RiderRideMapPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ride.rideId != widget.ride.rideId ||
        oldWidget.ride.driverUserId != widget.ride.driverUserId) {
      _load();
    }
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  void _load() {
    _cubit.loadRiderRideMap(
      rideId: widget.ride.rideId,
      riderUserId: widget.user?.id,
      driverUserId: widget.ride.driverUserId,
      driverName: widget.ride.driverName.isEmpty
          ? 'Conductor'
          : widget.ride.driverName,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocBuilder<RideMapCubit, RideMapState>(
        builder: (context, state) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Mapa del viaje iniciado',
                        style: AppTextStyles.primary.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.slate900,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Actualizar ubicaciones',
                      onPressed: state.status == RideMapStatus.loading
                          ? null
                          : _load,
                      icon: const Icon(Icons.refresh_rounded),
                      color: AppColors.blue900,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const _MapNotice(
                  text:
                      'Viaje iniciado. Tu ubicacion se comparte con el conductor.',
                  color: Color(0xFF047857),
                  background: Color(0xFFECFDF5),
                  border: Color(0xFFA7F3D0),
                ),
                if (state.isOffline || state.message != null) ...[
                  const SizedBox(height: 12),
                  if (state.isOffline)
                    const _MapNotice(
                      text:
                          'Sin internet. Mostrando ultimas posiciones guardadas.',
                      color: Color(0xFF92400E),
                      background: Color(0xFFFFFBEB),
                      border: Color(0xFFFDE68A),
                    )
                  else
                    _MapNotice(
                      text: state.message!,
                      color: AppColors.blue900,
                      background: const Color(0xFFEFF6FF),
                      border: const Color(0xFFBFDBFE),
                    ),
                ],
                const SizedBox(height: 12),
                SizedBox(
                  height: 320,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: _RideMapCanvas(
                      state: state,
                      currentLabel: 'Tu',
                      currentMeta: 'Tu ubicacion',
                      currentInitial: 'T',
                      currentColor: AppColors.amber700,
                      remoteColor: AppColors.blue900,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MapNotice extends StatelessWidget {
  const _MapNotice({
    required this.text,
    required this.color,
    required this.background,
    required this.border,
  });

  final String text;
  final Color color;
  final Color background;
  final Color border;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Text(
        text,
        style: AppTextStyles.primary.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _MapFallback extends StatelessWidget {
  const _MapFallback({required this.message}) : isLoading = false;

  const _MapFallback.loading()
    : message = 'Cargando mapa del viaje...',
      isLoading = true;

  final String message;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8FAFC),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLoading)
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: AppColors.amber700,
              ),
            )
          else
            const Icon(Icons.map_outlined, size: 36, color: AppColors.blue900),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.primary.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}
