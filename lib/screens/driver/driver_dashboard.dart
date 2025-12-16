import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../services/connectivity_service.dart';
import '../../services/location_service.dart';
import '../../services/communication_service.dart';
import '../../services/storage_service.dart';
import '../../utils/constants.dart';
import '../../widgets/status_card.dart';
import 'map_view.dart';
import 'mechanic_list.dart';
import 'driver_profile.dart';

class DriverDashboardScreen extends StatefulWidget {
  const DriverDashboardScreen({super.key});

  @override
  State<DriverDashboardScreen> createState() => _DriverDashboardScreenState();
}

class _DriverDashboardScreenState extends State<DriverDashboardScreen> {
  final ConnectivityService _connectivity = ConnectivityService();
  final LocationService _locationService = LocationService();
  final CommunicationService _comm = CommunicationService();
  bool _online = true;
  int _tabIndex = 0; // 0=Home,1=Map,2=Profile placeholder
  String _locationText = 'Detecting location...';
  bool _smsModeActive = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _online = await _connectivity.isOnline();
    _connectivity.connectivityStream.listen((results) {
      // The stream emits List<ConnectivityResult>, not a single value
      final isOnline = results.contains(ConnectivityResult.mobile) ||
          results.contains(ConnectivityResult.wifi) ||
          results.contains(ConnectivityResult.ethernet);
      if (mounted) setState(() => _online = isOnline);
    });
    try {
      final pos = await _locationService.getCurrentLocation();
      if (!mounted) return;
      setState(() => _locationText = 'Lat ${pos.latitude.toStringAsFixed(4)}, Lng ${pos.longitude.toStringAsFixed(4)}');
    } catch (_) {
      if (mounted) setState(() => _locationText = 'Location unavailable');
    }
  }

  Future<void> _emergency() async {
    if (_online) {
      setState(() {
        _tabIndex = 1; // jump to map
        _smsModeActive = false;
      });
    } else {
      setState(() => _smsModeActive = true);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Offline Mode: Sending request to backend...')));
      try {
        // Get user's phone number from storage
        final storageService = StorageService();
        final driver = await storageService.getDriver();
        if (driver == null) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User information not found. Please register first.')));
          return;
        }

        // Get current location
        final pos = await _locationService.getCurrentLocation();
        
        // Format SMS message to send to backend
        // Format: "HELP <user_phone> <lat>,<lng>"
        // Backend will receive this, find nearby mechanics, and send SMS back to user
        final requestMessage = 'HELP ${driver.phone} ${pos.latitude.toStringAsFixed(4)},${pos.longitude.toStringAsFixed(4)}';
        
        // Send SMS to backend number - backend will process and send mechanics list back to user
        await _comm.sendSMS(AppStrings.backendSmsNumber, requestMessage);
        
        if (!mounted) return;
        
        // Show message that backend will send SMS with mechanics list
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request sent to backend. You will receive SMS with nearby mechanics list shortly.'),
            duration: Duration(seconds: 4),
          )
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to send request: $e')));
      }
    }
  }



  Widget _buildHome() {
    return Column(
      children: [
        StatusCard(location: _locationText, online: _online, onEmergency: _emergency),
        if (_online) const Expanded(child: MechanicListView()) else Expanded(child: _buildOfflineSms()),
      ],
    );
  }

  Widget _buildOfflineSms() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          color: Colors.orange.withOpacity(0.15),
          padding: const EdgeInsets.all(12),
          child: const Text('Offline Mode: Request sent to backend. You will receive SMS with nearby mechanics list.'),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: ElevatedButton.icon(
            onPressed: _emergency,
            icon: const Icon(Icons.sms_rounded),
            label: const Text('Send Emergency SMS'),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.sms_outlined, size: 64, color: Colors.orange),
                  const SizedBox(height: 16),
                  const Text(
                    'Waiting for backend response...',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Backend will send SMS to your registered phone number with the list of nearby mechanics.',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildHome(),
      const DriverMapView(),
      DriverProfileScreen(onRequestHelp: _emergency),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('RoadResQ')),
      body: AnimatedSwitcher(duration: const Duration(milliseconds: 250), child: pages[_tabIndex]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (i) => setState(() => _tabIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.map_outlined), selectedIcon: Icon(Icons.map), label: 'Map'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(onPressed: _emergency, icon: const Icon(Icons.emergency), label: const Text('Help')),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}


