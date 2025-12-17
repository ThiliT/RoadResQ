import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/location_service.dart';
import '../../services/storage_service.dart';
import '../../models/mechanic.dart';
import '../mechanic/mechanic_dashboard.dart';

class MechanicRegistrationScreen extends StatefulWidget {
  const MechanicRegistrationScreen({super.key});

  @override
  State<MechanicRegistrationScreen> createState() => _MechanicRegistrationScreenState();
}

class _MechanicRegistrationScreenState extends State<MechanicRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String _serviceArea = 'Colombo';
  Position? _position;
  bool _available = true;
  bool _loadingLocation = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _detectLocation() async {
    setState(() => _loadingLocation = true);
    try {
      _position = await LocationService().getCurrentLocation();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location updated')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to get location: $e')));
    } finally {
      if (mounted) setState(() => _loadingLocation = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Require location to be set
    if (_position == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please detect your current location')),
      );
      return;
    }

    setState(() => _loadingLocation = true);
    try {
        final mechanic = Mechanic(
          id: DateTime.now().millisecondsSinceEpoch,
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          latitude: _position!.latitude,
          longitude: _position!.longitude,
          area: _serviceArea,
          district: 'Colombo',
          shopName: '',
          address: '',
          available: _available,
          rating: 0.0,
          email: '',
          services: '',
          contactVerified: false,
        );
      
      await StorageService().saveMechanic(mechanic);
      
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MechanicDashboardScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _loadingLocation = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mechanic Registration')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Name', prefixIcon: Icon(Icons.person_outline)),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter your name' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(Icons.phone_outlined)),
                  validator: (v) => (v == null || v.trim().length < 9) ? 'Enter a valid phone number' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _serviceArea,
                  decoration: const InputDecoration(labelText: 'Service Area', prefixIcon: Icon(Icons.location_city_outlined)),
                  items: const [
                    DropdownMenuItem(value: 'Colombo', child: Text('Colombo')),
                    DropdownMenuItem(value: 'Galle', child: Text('Galle')),
                    DropdownMenuItem(value: 'Kandy', child: Text('Kandy')),
                    DropdownMenuItem(value: 'Matara', child: Text('Matara')),
                    DropdownMenuItem(value: 'Jaffna', child: Text('Jaffna')),
                  ],
                  onChanged: (v) => setState(() => _serviceArea = v ?? 'Colombo'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _loadingLocation ? null : _detectLocation,
                        icon: _loadingLocation
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.my_location),
                        label: Text(_position == null
                            ? 'Detect Current Location'
                            : 'Lat: ${_position!.latitude.toStringAsFixed(4)}, Lng: ${_position!.longitude.toStringAsFixed(4)}'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  value: _available,
                  onChanged: (v) => setState(() => _available = v),
                  title: const Text('Availability'),
                  subtitle: Text(_available ? 'Available' : 'Unavailable'),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _loadingLocation ? null : _submit,
                  icon: _loadingLocation
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.check_circle_outline),
                  label: Text(_loadingLocation ? 'Registering...' : 'Register'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


