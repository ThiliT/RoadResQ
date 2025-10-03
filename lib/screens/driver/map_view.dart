import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' as ll;
import '../../services/location_service.dart';
import '../../utils/dummy_data.dart';

class DriverMapView extends StatefulWidget {
  const DriverMapView({super.key});

  @override
  State<DriverMapView> createState() => _DriverMapViewState();
}

class _DriverMapViewState extends State<DriverMapView> {
  final LocationService _locationService = LocationService();
  final MapController _mapController = MapController();
  Position? _position;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final pos = await _locationService.getCurrentLocation();
      if (!mounted) return;
      setState(() {
        _position = pos;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Location error: $e')));
    }
  }

  List<Marker> _buildMarkers() {
    final markers = <Marker>[];
    if (_position != null) {
      markers.add(Marker(
        point: ll.LatLng(_position!.latitude, _position!.longitude),
        width: 40,
        height: 40,
        child: const Icon(Icons.my_location, color: Colors.blueAccent),
      ));
    }
    for (final m in dummyMechanics) {
      markers.add(Marker(
        point: ll.LatLng(m.latitude, m.longitude),
        width: 40,
        height: 40,
        child: Tooltip(
          message: '${m.name} • ${m.area}',
          child: const Icon(Icons.location_on, color: Colors.redAccent),
        ),
      ));
    }
    return markers;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    final center = _position != null
        ? ll.LatLng(_position!.latitude, _position!.longitude)
        : const ll.LatLng(6.9271, 79.8612);
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: center,
        initialZoom: 12,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: const ['a', 'b', 'c'],
          userAgentPackageName: 'com.example.road_resq',
        ),
        MarkerLayer(markers: _buildMarkers()),
      ],
    );
  }
}


