import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

enum ConnectivityStatus { wifi, mobile, offline }

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final StreamController<ConnectivityStatus> _connectionStatusController =
      StreamController<ConnectivityStatus>.broadcast();

  Stream<ConnectivityStatus> get connectivityStream =>
      _connectionStatusController.stream;

  ConnectivityService() {
    _init();
  }

  void _init() async {
    List<ConnectivityResult> results = await _connectivity.checkConnectivity();
    _setStatus(results.isNotEmpty ? results.first : ConnectivityResult.none);

    _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      _setStatus(results.isNotEmpty ? results.first : ConnectivityResult.none);
    });
  }

  void _setStatus(ConnectivityResult result) {
    ConnectivityStatus status;

    switch (result) {
      case ConnectivityResult.wifi:
        status = ConnectivityStatus.wifi;
        break;
      case ConnectivityResult.mobile:
        status = ConnectivityStatus.mobile;
        break;
      case ConnectivityResult.none:
        status = ConnectivityStatus.offline;
        break;
      default:
        status = ConnectivityStatus.offline;
        break;
    }

    _connectionStatusController.add(status);
  }

  Future<bool> isConnected() async {
    List<ConnectivityResult> results = await _connectivity.checkConnectivity();
    return results.isNotEmpty && results.first != ConnectivityResult.none;
  }

  void dispose() {
    _connectionStatusController.close();
  }
}
