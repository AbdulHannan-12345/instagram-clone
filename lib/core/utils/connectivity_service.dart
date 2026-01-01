import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:io';
import 'dart:async';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  /// Check if device has actual internet connectivity
  /// by checking connectivity status and attempting a lookup
  Future<bool> isConnected() async {
    try {
      // First check if device is connected to any network
      final result = await _connectivity.checkConnectivity();
      final hasConnection =
          result.contains(ConnectivityResult.mobile) ||
          result.contains(ConnectivityResult.wifi) ||
          result.contains(ConnectivityResult.ethernet);

      if (!hasConnection) {
        return false;
      }

      // Verify actual internet access by doing a DNS lookup with shorter timeout
      try {
        final lookupResult = await InternetAddress.lookup(
          'google.com',
        ).timeout(const Duration(milliseconds: 1500));
        return lookupResult.isNotEmpty && lookupResult[0].rawAddress.isNotEmpty;
      } on SocketException catch (_) {
        return false;
      } on TimeoutException catch (_) {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// Stream of connectivity changes
  Stream<List<ConnectivityResult>> get connectivityStream =>
      _connectivity.onConnectivityChanged;
}
