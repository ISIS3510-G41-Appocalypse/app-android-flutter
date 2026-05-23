import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/api_constants.dart';
import '../storage/session_storage.dart';

class SupabaseRealtimeService {
  static const String _schema = 'public';
  static const String _ridesTable = 'rides';
  static const String _reservationsTable = 'reservations';

  final SupabaseClient _client;

  SupabaseRealtimeService({
    required SessionStorage sessionStorage,
    SupabaseClient? client,
  })
    : _client =
          client ??
          SupabaseClient(
            ApiConstants.baseUrl,
            ApiConstants.apiKey,
            accessToken: sessionStorage.getAccessToken,
          );

  RealtimeSubscription watchDriverRide({
    required String rideId,
    required void Function() onChange,
  }) {
    return RealtimeSubscription([
      _watchTable(
        topic: 'driver-ride-$rideId',
        table: _ridesTable,
        filterColumn: 'id',
        filterValue: rideId,
        onChange: onChange,
      ),
      _watchTable(
        topic: 'driver-ride-reservations-$rideId',
        table: _reservationsTable,
        filterColumn: 'ride_id',
        filterValue: rideId,
        onChange: onChange,
      ),
    ], _client);
  }

  RealtimeSubscription watchRiderRide({
    required String rideId,
    required String reservationId,
    required void Function() onChange,
  }) {
    return RealtimeSubscription([
      _watchTable(
        topic: 'rider-ride-$rideId',
        table: _ridesTable,
        filterColumn: 'id',
        filterValue: rideId,
        onChange: onChange,
      ),
      _watchTable(
        topic: 'rider-reservation-$reservationId',
        table: _reservationsTable,
        filterColumn: 'id',
        filterValue: reservationId,
        onChange: onChange,
      ),
    ], _client);
  }

  RealtimeChannel _watchTable({
    required String topic,
    required String table,
    required String filterColumn,
    required String filterValue,
    required void Function() onChange,
  }) {
    return _client
        .channel(topic)
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: _schema,
          table: table,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: filterColumn,
            value: filterValue,
          ),
          callback: (_) => onChange(),
        )
        .subscribe();
  }
}

class RealtimeSubscription {
  final List<RealtimeChannel> _channels;
  final SupabaseClient _client;

  const RealtimeSubscription(this._channels, this._client);

  Future<void> cancel() async {
    for (final channel in _channels) {
      await _client.removeChannel(channel);
    }
  }
}
