import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class NetworkChecker {
  final InternetConnection internetConnection;

  NetworkChecker({
    InternetConnection? internetConnection,
  }) : internetConnection = internetConnection ?? InternetConnection();

  Future<bool> get hasInternet => internetConnection.hasInternetAccess;
}
