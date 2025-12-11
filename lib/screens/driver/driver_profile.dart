import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../services/storage_service.dart';
import '../../utils/constants.dart';
import '../welcome_screen.dart';

class DriverProfileScreen extends StatefulWidget {
  final VoidCallback onRequestHelp;

  const DriverProfileScreen({super.key, required this.onRequestHelp});

  @override
  State<DriverProfileScreen> createState() => _DriverProfileScreenState();
}

class _DriverProfileScreenState extends State<DriverProfileScreen> {
  final StorageService _storageService = StorageService();
  late Future<DriverUser?> _driverFuture;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _driverFuture = _storageService.getDriver();
  }

  Future<void> _showEditProfile(BuildContext context, DriverUser? driver) async {
    final formKey = GlobalKey<FormState>();
    final phoneController = TextEditingController(text: driver?.phone ?? '');
    final emailController = TextEditingController(text: driver?.email ?? '');
    final vehicleController = TextEditingController(text: driver?.vehicleType ?? '');
    final plateController = TextEditingController(text: driver?.plateNumber ?? '');

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
                    const Text('Edit profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    IconButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      icon: const Icon(Icons.close_rounded),
                    )
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Phone number'),
                  validator: (value) => (value == null || value.trim().isEmpty) ? 'Phone is required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return null;
                    final email = value.trim();
                    final isValid = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$').hasMatch(email);
                    return isValid ? null : 'Enter a valid email';
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: vehicleController,
                  decoration: const InputDecoration(labelText: 'Vehicle'),
                  validator: (value) => (value == null || value.trim().isEmpty) ? 'Vehicle is required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: plateController,
                  decoration: const InputDecoration(labelText: 'License plate'),
                  validator: (value) => (value == null || value.trim().isEmpty) ? 'License plate is required' : null,
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving
                        ? null
                        : () async {
                            if (!formKey.currentState!.validate()) return;
                            setState(() => _isSaving = true);
                            final updated = (driver ?? const DriverUser(name: 'Driver', phone: '', vehicleType: ''))
                                .copyWith(
                                  phone: phoneController.text.trim(),
                                  email: emailController.text.trim(),
                                  vehicleType: vehicleController.text.trim(),
                                  plateNumber: plateController.text.trim(),
                                );
                            await _storageService.saveDriver(updated);
                            if (!mounted) return;
                            setState(() {
                              _driverFuture = _storageService.getDriver();
                              _isSaving = false;
                            });
                            Navigator.of(ctx).pop();
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated')));
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
                        : const Text('Save changes'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _logout(BuildContext context) async {
    await _storageService.clear();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DriverUser?>(
      future: _driverFuture,
      builder: (context, snapshot) {
        final driver = snapshot.data;
        final name = driver?.name.isNotEmpty == true ? driver!.name : 'Driver';
        final phone = driver?.phone ?? 'Add phone';
        final vehicle = driver?.vehicleType ?? 'Add vehicle';
        final email = driver?.email ?? 'Add email';
        final plate = driver?.plateNumber ?? 'Add plate';
        const membership = 'Premium';

        return SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _driverFuture = _storageService.getDriver();
              });
              await _driverFuture;
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Column(
                children: [
                  _ProfileHeader(
                    name: name,
                    membership: membership,
                    phone: phone,
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    title: 'Contact details',
                    icon: Icons.contact_phone_rounded,
                    child: Column(
                      children: [
                        _InfoRow(icon: Icons.phone_rounded, label: 'Phone', value: phone),
                        const Divider(height: 20),
                        _InfoRow(icon: Icons.email_outlined, label: 'Email', value: email),
                        const Divider(height: 20),
                        _InfoRow(icon: Icons.directions_car_filled_rounded, label: 'Vehicle', value: vehicle),
                        const Divider(height: 20),
                        _InfoRow(icon: Icons.confirmation_number_outlined, label: 'License plate', value: plate),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    title: 'Service preferences',
                    icon: Icons.tune_rounded,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: const [
                            _ChipPill(label: 'Towing'),
                            _ChipPill(label: 'Battery jump'),
                            _ChipPill(label: 'Fuel delivery'),
                            _ChipPill(label: 'Flat tire'),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: const [
                            Icon(Icons.location_on_rounded, color: Colors.blueGrey, size: 22),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Default location: Use current location',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Padding(
                          padding: EdgeInsets.only(left: 32),
                          child: Text(
                            'Update from the map tab for better accuracy.',
                            style: TextStyle(color: Colors.black54),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    title: 'Account actions',
                    icon: Icons.manage_accounts_rounded,
                    child: Column(
                      children: [
                        _ActionButton(
                          icon: Icons.edit_rounded,
                          label: 'Edit profile',
                          onPressed: () => _showEditProfile(context, driver),
                        ),
                        // const SizedBox(height: 10),
                        // _ActionButton(
                        //   icon: Icons.lock_reset_rounded,
                        //   label: 'Change password',
                        //   onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                        //     const SnackBar(content: Text('Password change coming soon')),
                        //   ),
                        // ),
                        // const SizedBox(height: 10),
                        // _ActionButton(
                        //   icon: Icons.credit_card_rounded,
                        //   label: 'Payment methods',
                        //   onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                        //     const SnackBar(content: Text('Payment methods coming soon')),
                        //   ),
                        // ),
                        const SizedBox(height: 10),
                        _ActionButton(
                          icon: Icons.logout_rounded,
                          label: 'Logout',
                          isDestructive: true,
                          onPressed: () => _logout(context),
                        ),
                      ],
                    ),
                  ),
                  // const SizedBox(height: 16),
                  // _SectionCard(
                  //   title: 'Quick actions',
                  //   icon: Icons.flash_on_rounded,
                  //   child: Column(
                  //     crossAxisAlignment: CrossAxisAlignment.stretch,
                  //     children: [
                  //       ElevatedButton.icon(
                  //         onPressed: widget.onRequestHelp,
                  //         style: ElevatedButton.styleFrom(
                  //           backgroundColor: AppColors.primary,
                  //           padding: const EdgeInsets.symmetric(vertical: 14),
                  //           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  //         ),
                  //         icon: const Icon(Icons.emergency_outlined),
                  //         label: const Text('Request assistance now'),
                  //       ),
                  //       const SizedBox(height: 10),
                  //       OutlinedButton.icon(
                  //         onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  //           const SnackBar(content: Text('Share live location coming soon')),
                  //         ),
                  //         style: OutlinedButton.styleFrom(
                  //           padding: const EdgeInsets.symmetric(vertical: 14),
                  //           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  //           side: const BorderSide(color: Colors.blueGrey),
                  //         ),
                  //         icon: const Icon(Icons.share_location_rounded, color: Colors.blueGrey),
                  //         label: const Text('Share live location', style: TextStyle(color: Colors.blueGrey)),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    title: 'Recent activity',
                    icon: Icons.history_rounded,
                    child: Column(
                      children: const [
                        _ActivityTile(
                          title: 'Fuel delivery',
                          subtitle: 'Completed • 2 hours ago',
                          statusColor: AppColors.success,
                        ),
                        Divider(height: 18),
                        _ActivityTile(
                          title: 'Towing request',
                          subtitle: 'Cancelled • Yesterday',
                          statusColor: Colors.orangeAccent,
                        ),
                        Divider(height: 18),
                        _ActivityTile(
                          title: 'Battery jump',
                          subtitle: 'Completed • 3 days ago',
                          statusColor: AppColors.success,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final String name;
  final String membership;
  final String phone;

  const _ProfileHeader({required this.name, required this.membership, required this.phone});

  @override
  Widget build(BuildContext context) {
    final initials = name.isNotEmpty ? name.trim()[0].toUpperCase() : 'D';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        gradient: AppGradients.warmSunset,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.15),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: Colors.white.withOpacity(0.15),
            child: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white,
              child: Text(initials, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.secondary)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                const SizedBox(height: 6),
                Text(phone, style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 18),
                      const SizedBox(width: 6),
                      Text('$membership member', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Edit photo coming soon')),
            ),
            icon: const Icon(Icons.camera_alt_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: AppColors.primary),
                ),
                const SizedBox(width: 10),
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.blueGrey, size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 13, color: Colors.black54)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right_rounded, color: Colors.black38),
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Update $label coming soon')),
          ),
        ),
      ],
    );
  }
}

class _ChipPill extends StatelessWidget {
  final String label;

  const _ChipPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.secondary.withOpacity(0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_rounded, color: AppColors.secondary, size: 16),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool isDestructive;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? Colors.red : AppColors.secondary;
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color.withOpacity(0.35)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        ),
        icon: Icon(icon, color: color),
        label: Text(
          label,
          style: TextStyle(color: color, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color statusColor;

  const _ActivityTile({required this.title, required this.subtitle, required this.statusColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.local_activity_rounded, color: statusColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(color: Colors.black54)),
            ],
          ),
        ),
        const Icon(Icons.chevron_right_rounded, color: Colors.black26),
      ],
    );
  }
}


