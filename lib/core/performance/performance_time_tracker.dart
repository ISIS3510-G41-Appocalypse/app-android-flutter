import 'package:dio/dio.dart';

import '../network/network_checker.dart';

class PerformanceTimeTracker {
  static const String _performanceTimesPath = '/rest/v1/performance_times';
  static const String _defaultPlatform = 'FLUTTER';

  final Dio dio;
  final NetworkChecker networkChecker;

  PerformanceTimeTracker({
    required this.dio,
    required this.networkChecker,
  });

  Future<void> track({
    required String feature,
    required double duration,
    required String source,
    String platform = _defaultPlatform,
  }) async {
    try {
      if (!await networkChecker.hasInternet) {
        return;
      }

      await dio.post(
        _performanceTimesPath,
        data: {
          'feature': feature,
          'duration': duration,
          'platform': platform,
          'source': source,
        },
      );
    } catch (_) {
      // Performance tracking should never break the user flow.
    }
  }
}
