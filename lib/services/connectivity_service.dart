import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  Future<bool> isOnline() async {
    final results = await Connectivity().checkConnectivity();
    return results.contains(ConnectivityResult.mobile) ||
        results.contains(ConnectivityResult.wifi) ||
        results.contains(ConnectivityResult.ethernet);
  }

  Stream<List<ConnectivityResult>> get connectivityStream => Connectivity().onConnectivityChanged;
}


