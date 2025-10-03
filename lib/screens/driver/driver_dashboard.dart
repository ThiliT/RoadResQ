import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../services/connectivity_service.dart';
import '../../services/location_service.dart';
import '../../services/communication_service.dart';
import '../../widgets/status_card.dart';
import 'map_view.dart';
import 'mechanic_list.dart';

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
  List<Map<String, String>> _smsMechanics = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _online = await _connectivity.isOnline();
    _connectivity.connectivityStream.listen((event) {
      final isOnline = event == ConnectivityResult.mobile || event == ConnectivityResult.wifi || event == ConnectivityResult.ethernet;
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Offline Mode: Sending SMS...')));
      try {
        final pos = await _locationService.getCurrentLocation();
        final response = await _comm.simulateSMSSend(pos);
        final list = _parseSmsResponse(response);
        if (!mounted) return;
        setState(() => _smsMechanics = list);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('SMS simulation failed: $e')));
      }
    }
  }

  List<Map<String, String>> _parseSmsResponse(String text) {
    // Format: "Mechanics near you: 1.Sunil-0771234567-3km, 2.Kamal-0772345678-5km"
    final parts = text.split(':');
    if (parts.length < 2) return [];
    final items = parts[1].split(',');
    return items.map((s) {
      final t = s.trim().replaceAll(RegExp(r'^[0-9]+\.'), '');
      final seg = t.split('-');
      if (seg.length >= 3) {
        return {'name': seg[0], 'phone': seg[1], 'distance': seg[2]};
      }
      return {'name': t, 'phone': '', 'distance': ''};
    }).toList();
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
          child: const Text('Offline Mode: SMS will be used to find nearby mechanics'),
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
        if (_smsModeActive)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text('Mock SMS format: "HELP <lat>,<lng>"'),
          ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: _smsMechanics.length,
            itemBuilder: (_, i) {
              final it = _smsMechanics[i];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.handyman_outlined),
                  title: Text(it['name'] ?? ''),
                  subtitle: Text((it['distance'] ?? '').isEmpty ? 'SMS Mode Active' : it['distance']!),
                  trailing: Wrap(spacing: 8, children: const [Icon(Icons.call), Icon(Icons.sms)]),
                ),
              );
            },
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
      const Center(child: Text('Profile (coming soon)')),
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


