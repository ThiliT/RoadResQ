import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:url_launcher/url_launcher.dart';

import '../../services/location_service.dart';
import '../../services/mechanics_service.dart';
import '../../models/mechanic.dart';
import '../../utils/constants.dart';

class DriverMapView extends StatefulWidget {
  const DriverMapView({super.key});

  @override
  State<DriverMapView> createState() => _DriverMapViewState();
}

class _DriverMapViewState extends State<DriverMapView> {
  final LocationService _locationService = LocationService();
  final MechanicsService _mechanicsService = MechanicsService();
  final MapController _mapController = MapController();

  Position? _position;
  List<Mechanic> _mechanics = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final pos = await _locationService.getCurrentLocation();
      final mechanics = await _mechanicsService.fetchMechanics();

      if (!mounted) return;

      setState(() {
        _position = pos;
        _mechanics = mechanics;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => _loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  /// 🔗 Open Google Maps
  Future<void> openInMaps(double lat, double lng) async {
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng',
    );

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open Google Maps")),
      );
    }
  }

  /// 📍 Build map markers
  List<Marker> _buildMarkers() {
    final markers = <Marker>[];

    // User location
    if (_position != null) {
      markers.add(
        Marker(
          point: ll.LatLng(
            _position!.latitude,
            _position!.longitude,
          ),
          width: 45,
          height: 45,
          child: const Icon(Icons.my_location, color: Colors.blue),
        ),
      );
    }

    // Mechanics
    for (final m in _mechanics) {
      markers.add(
        Marker(
          point: ll.LatLng(m.latitude, m.longitude),
          width: 50,
          height: 50,
          child: GestureDetector(
            onTap: () => _showMechanicBottomSheet(m),
            child: const Icon(
              Icons.location_on,
              color: Colors.red,
              size: 35,
            ),
          ),
        ),
      );
    }

    return markers;
  }

  /// 🗺️ MAIN BUILD (MAP VIEW)
  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final initialCenter = _position != null
        ? ll.LatLng(_position!.latitude, _position!.longitude)
        : const ll.LatLng(6.9271, 79.8612); // Colombo

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: initialCenter,
        initialZoom: 12,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: const ['a', 'b', 'c'],
        ),
        MarkerLayer(markers: _buildMarkers()),
      ],
    );
  }

  /// 📌 Bottom Sheet
  void _showMechanicBottomSheet(Mechanic m) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadius.xl),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius:
                          BorderRadius.circular(AppRadius.round),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.accentOrange.withOpacity(0.2),
                            AppColors.warning.withOpacity(0.1),
                          ],
                        ),
                        borderRadius:
                            BorderRadius.circular(AppRadius.md),
                      ),
                      child: const Icon(
                        Icons.handyman_rounded,
                        color: AppColors.accentOrange,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            m.shopName.isNotEmpty
                                ? m.shopName
                                : m.name,
                            style: const TextStyle(
                              fontSize: AppText.h4,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (m.shopName.isNotEmpty)
                            Text(
                              m.name,
                              style: TextStyle(
                                fontSize: AppText.body,
                                color: AppColors.textSecondary,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          final Uri callUri = Uri(scheme: 'tel', path: m.phone);
                          launchUrl(callUri); // requires url_launcher
                        },
                        icon: const Icon(Icons.call_rounded, size: 18),
                        label: const Text('Call'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          final Uri smsUri = Uri(
                            scheme: 'sms',
                            path: m.phone,
                            queryParameters: {'body': 'Hello, I need roadside assistance.'},
                          );
                          launchUrl(smsUri); // requires url_launcher
                        },
                        icon: const Icon(Icons.sms_rounded, size: 18),
                        label: const Text('Message'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    openInMaps(m.latitude, m.longitude);
                  },
                  icon: const Icon(Icons.directions_rounded),
                  label: const Text('Get Directions'),
                ),

                SizedBox(
                  height: MediaQuery.of(context).padding.bottom,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// ℹ️ Info Row Widget
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: AppSpacing.sm),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: AppText.body,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: AppText.body,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
