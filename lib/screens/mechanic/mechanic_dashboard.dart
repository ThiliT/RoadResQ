import 'package:flutter/material.dart';
import '../../models/mechanic.dart';
import '../../services/storage_service.dart';
import '../../utils/constants.dart';

class MechanicDashboardScreen extends StatefulWidget {
  const MechanicDashboardScreen({super.key});

  @override
  State<MechanicDashboardScreen> createState() => _MechanicDashboardScreenState();
}

class _MechanicDashboardScreenState extends State<MechanicDashboardScreen> {
  final StorageService _storageService = StorageService();
  late Future<Mechanic?> _mechanicFuture;
  String _availability = 'Available';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _mechanicFuture = _storageService.getMechanic();
  }

  Future<void> _showEditProfile(BuildContext context, Mechanic? mechanic) async {
    if (mechanic == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mechanic profile not found')),
      );
      return;
    }

    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: mechanic.name);
    final phoneController = TextEditingController(text: mechanic.phone);
    String selectedArea = mechanic.area;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Edit Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    IconButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      icon: const Icon(Icons.close_rounded),
                    )
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) => (value == null || value.trim().isEmpty) ? 'Name is required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Phone number is required';
                    }
                    // Basic phone validation - at least 9 digits
                    final phoneRegex = RegExp(r'^[0-9]{9,}$');
                    final cleanedPhone = value.replaceAll(RegExp(r'[^\d]'), '');
                    if (!phoneRegex.hasMatch(cleanedPhone)) {
                      return 'Enter a valid phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                StatefulBuilder(
                  builder: (context, setState) {
                    return DropdownButtonFormField<String>(
                      value: selectedArea,
                      decoration: const InputDecoration(labelText: 'Service Area'),
                      items: const [
                        DropdownMenuItem(value: 'Colombo', child: Text('Colombo')),
                        DropdownMenuItem(value: 'Galle', child: Text('Galle')),
                        DropdownMenuItem(value: 'Kandy', child: Text('Kandy')),
                        DropdownMenuItem(value: 'Matara', child: Text('Matara')),
                        DropdownMenuItem(value: 'Jaffna', child: Text('Jaffna')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => selectedArea = value);
                        }
                      },
                      validator: (value) => (value == null || value.isEmpty) ? 'Service area is required' : null,
                    );
                  },
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _isSaving
                            ? null
                            : () async {
                                if (!formKey.currentState!.validate()) return;
                                setState(() => _isSaving = true);
                                
                                try {
                                  // Update mechanic data
                                  // final updated = mechanic.copyWith(
                                  //   name: nameController.text.trim(),
                                  //   phone: phoneController.text.trim(),
                                  //   area: selectedArea,
                                  // );
                                  final updated = Mechanic(
                                    id: mechanic.id,
                                    name: nameController.text.trim(),
                                    phone: phoneController.text.trim(),
                                    latitude: mechanic.latitude,
                                    longitude: mechanic.longitude,
                                    area: selectedArea,
                                    available: mechanic.available,
                                    rating: mechanic.rating,
                                  );
                                  
                                  // Save to local storage
                                  await _storageService.saveMechanic(updated);
                                  
                                  // TODO: Replace with actual API call
                                  // Example: await _updateMechanicProfile(updated);
                                  // await _apiService.updateMechanicProfile(mechanic.id, {
                                  //   'name': updated.name,
                                  //   'phone': updated.phone,
                                  //   'area': updated.area,
                                  // });
                                  
                                  if (!mounted) return;
                                  setState(() {
                                    _mechanicFuture = _storageService.getMechanic();
                                    _isSaving = false;
                                  });
                                  Navigator.of(ctx).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Profile updated successfully'),
                                      backgroundColor: AppColors.success,
                                    ),
                                  );
                                } catch (e) {
                                  if (!mounted) return;
                                  setState(() => _isSaving = false);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Failed to update profile: ${e.toString()}'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('Save'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mechanic Dashboard')),
      body: FutureBuilder<Mechanic?>(
        future: _mechanicFuture,
        builder: (context, snapshot) {
          final mechanic = snapshot.data;
          final name = mechanic?.name ?? 'Mechanic';
          final phone = mechanic?.phone ?? 'Add phone';
          final area = mechanic?.area ?? 'Add service area';

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _mechanicFuture = _storageService.getMechanic();
              });
              await _mechanicFuture;
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.orange.shade100,
                      child: const Icon(Icons.handyman_rounded),
                    ),
                    title: Text(name),
                    subtitle: Text('$phone • $area'),
                    trailing: IconButton(
                      onPressed: () => _showEditProfile(context, mechanic),
                      icon: const Icon(Icons.edit_outlined),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(children: [
                      const Text('Availability'),
                      const Spacer(),
                      DropdownButton<String>(
                        value: _availability,
                        items: const [
                          DropdownMenuItem(value: 'Available', child: Text('Available')),
                          DropdownMenuItem(value: 'Busy', child: Text('Busy')),
                          DropdownMenuItem(value: 'Offline', child: Text('Offline')),
                        ],
                        onChanged: (v) => setState(() => _availability = v ?? 'Available'),
                      )
                    ]),
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(children: const [
                      Expanded(child: _StatTile(label: 'Requests today', value: '0')),
                      Expanded(child: _StatTile(label: 'Distance', value: '0 km')),
                      Expanded(child: _StatTile(label: 'Rating', value: '⭐⭐⭐⭐⭐')),
                    ]),
                  ),
                ),
                const SizedBox(height: 8),
                const Text('Incoming Requests', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                ...List.generate(3, (i) => _RequestCard(index: i + 1)),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.my_location),
                  label: const Text('Update Current Location'),
                ),

          
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  const _StatTile({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: Colors.black54)),
      const SizedBox(height: 6),
      Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
    ]);
  }
}

class _RequestCard extends StatelessWidget {
  final int index;
  const _RequestCard({required this.index});
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Text(index.toString())),
        title: Text('Driver #$index'),
        subtitle: const Text('2.5 km away • 10:30 AM'),
        trailing: Wrap(spacing: 8, children: [
          TextButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Declined'))), child: const Text('Decline')),
          ElevatedButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Accepted'))), child: const Text('Accept')),
        ]),
      ),
    );
  }
}



