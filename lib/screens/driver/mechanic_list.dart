import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../utils/dummy_data.dart';
import '../../models/mechanic.dart';
import '../../services/location_service.dart';
import '../../services/communication_service.dart';

class MechanicListView extends StatefulWidget {
  const MechanicListView({super.key});

  @override
  State<MechanicListView> createState() => _MechanicListViewState();
}

class _MechanicListViewState extends State<MechanicListView> {
  final LocationService _locationService = LocationService();
  final CommunicationService _comm = CommunicationService();
  Position? _position;
  List<Mechanic> _items = dummyMechanics;
  bool _loading = true;
  String _search = '';
  double _radiusKm = 20;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final pos = await _locationService.getCurrentLocation();
      if (!mounted) return;
      setState(() {
        _position = pos;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Mechanic> _filtered() {
    final q = _search.trim().toLowerCase();
    var list = dummyMechanics.where((m) => q.isEmpty || m.area.toLowerCase().contains(q) || m.name.toLowerCase().contains(q)).toList();
    if (_position != null) {
      list = list
          .where((m) => _locationService.calculateDistance(_position!.latitude, _position!.longitude, m.latitude, m.longitude) <= _radiusKm)
          .toList();
      list.sort((a, b) {
        final da = _locationService.calculateDistance(_position!.latitude, _position!.longitude, a.latitude, a.longitude);
        final db = _locationService.calculateDistance(_position!.latitude, _position!.longitude, b.latitude, b.longitude);
        return da.compareTo(db);
      });
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    final items = _filtered();
    return RefreshIndicator(
      onRefresh: () async => setState(() {}),
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Row(children: [
            Expanded(
              child: TextField(
                decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search by area or name'),
                onChanged: (v) => setState(() => _search = v),
              ),
            ),
            const SizedBox(width: 8),
            DropdownButton<double>(
              value: _radiusKm,
              items: const [
                DropdownMenuItem(value: 5, child: Text('5km')),
                DropdownMenuItem(value: 10, child: Text('10km')),
                DropdownMenuItem(value: 20, child: Text('20km')),
              ],
              onChanged: (v) => setState(() => _radiusKm = v ?? 20),
            )
          ]),
          const SizedBox(height: 12),
          if (items.isEmpty) const Center(child: Padding(padding: EdgeInsets.all(24), child: Text('No mechanics found nearby.'))),
          ...items.map((m) => _MechanicCard(mechanic: m, position: _position, onCall: _comm.makePhoneCall, onSms: (p, msg) => _comm.sendSMS(p, msg))),
        ],
      ),
    );
  }
}

class _MechanicCard extends StatelessWidget {
  final Mechanic mechanic;
  final Position? position;
  final Future<void> Function(String) onCall;
  final Future<void> Function(String, String) onSms;
  const _MechanicCard({required this.mechanic, required this.position, required this.onCall, required this.onSms});

  @override
  Widget build(BuildContext context) {
    final service = LocationService();
    final distance = position == null
        ? null
        : service.calculateDistance(position!.latitude, position!.longitude, mechanic.latitude, mechanic.longitude);
    final eta = distance == null ? null : service.calculateETA(distance);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            children: [
              const Icon(Icons.handyman_rounded, color: Colors.orange),
              const SizedBox(width: 8),
              Expanded(child: Text(mechanic.name, style: const TextStyle(fontWeight: FontWeight.w600))),
              Text('⭐ ${mechanic.rating.toStringAsFixed(1)}'),
            ],
          ),
          const SizedBox(height: 6),
          Row(children: [
            const Icon(Icons.place_outlined, size: 18),
            const SizedBox(width: 4),
            Text(distance == null ? mechanic.area : '${distance.toStringAsFixed(1)} km away • ${eta ?? ''}')
          ]),
          const SizedBox(height: 6),
          Row(children: [
            const Icon(Icons.phone, size: 18),
            const SizedBox(width: 4),
            Text(mechanic.phone),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: mechanic.available ? Colors.green.withOpacity(0.15) : Colors.red.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(mechanic.available ? 'Available' : 'Busy', style: TextStyle(color: mechanic.available ? Colors.green : Colors.red)),
            )
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
              child: OutlinedButton.icon(onPressed: () => onCall(mechanic.phone), icon: const Icon(Icons.call), label: const Text('Call')),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => onSms(mechanic.phone, 'Hello, I need roadside assistance.'),
                icon: const Icon(Icons.sms),
                label: const Text('Message'),
              ),
            )
          ])
        ]),
      ),
    );
  }
}


