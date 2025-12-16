import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/location_service.dart';
import '../../utils/constants.dart';
import '../mechanic/mechanic_dashboard.dart';

class MechanicRegistrationScreen extends StatefulWidget {
  const MechanicRegistrationScreen({super.key});

  @override
  State<MechanicRegistrationScreen> createState() => _MechanicRegistrationScreenState();
}

class _MechanicRegistrationScreenState extends State<MechanicRegistrationScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String _serviceArea = 'Colombo';
  Position? _position;
  bool _available = true;
  bool _loadingLocation = false;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.normal,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: AppAnimations.defaultCurve),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _detectLocation() async {
    setState(() => _loadingLocation = true);
    try {
      _position = await LocationService().getCurrentLocation();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Location updated successfully'),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to get location: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _loadingLocation = false);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        transitionDuration: AppAnimations.normal,
        pageBuilder: (_, __, ___) => const MechanicDashboardScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mechanic Registration'),
        elevation: 0,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).scaffoldBackgroundColor,
                Theme.of(context).scaffoldBackgroundColor.withOpacity(0.95),
              ],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppSpacing.md),
                    // Header
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.accentOrange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                          ),
                          child: const Icon(
                            Icons.handyman_rounded,
                            color: AppColors.accentOrange,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        const Text(
                          'Join as Mechanic',
                          style: TextStyle(
                            fontSize: AppText.h2,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Connect with drivers and grow your business',
                          style: TextStyle(
                            fontSize: AppText.body,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    // Name field
                    TextFormField(
                      controller: _nameController,
                      textInputAction: TextInputAction.next,
                      style: const TextStyle(fontSize: AppText.bodyLarge),
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        hintText: 'Enter your full name',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter your name' : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    // Phone field
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      style: const TextStyle(fontSize: AppText.bodyLarge),
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        hintText: '0712345678',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                      validator: (v) => (v == null || v.trim().length < 9)
                          ? 'Please enter a valid phone number'
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    // Service area dropdown
                    DropdownButtonFormField<String>(
                      value: _serviceArea,
                      style: const TextStyle(fontSize: AppText.bodyLarge),
                      decoration: const InputDecoration(
                        labelText: 'Service Area',
                        prefixIcon: Icon(Icons.location_city_outlined),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Colombo', child: Text('Colombo')),
                        DropdownMenuItem(value: 'Galle', child: Text('Galle')),
                        DropdownMenuItem(value: 'Kandy', child: Text('Kandy')),
                        DropdownMenuItem(value: 'Matara', child: Text('Matara')),
                        DropdownMenuItem(value: 'Jaffna', child: Text('Jaffna')),
                      ],
                      onChanged: (v) => setState(() => _serviceArea = v ?? 'Colombo'),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    // Location button
                    Container(
                      decoration: BoxDecoration(
                        color: _position != null
                            ? AppColors.success.withOpacity(0.1)
                            : AppColors.info.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(
                          color: _position != null
                              ? AppColors.success
                              : AppColors.info,
                          width: 1.5,
                        ),
                      ),
                      child: OutlinedButton.icon(
                        onPressed: _loadingLocation ? null : _detectLocation,
                        icon: _loadingLocation
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Icon(
                                _position != null
                                    ? Icons.check_circle
                                    : Icons.my_location,
                                color: _position != null
                                    ? AppColors.success
                                    : AppColors.info,
                              ),
                        label: Text(
                          _position == null
                              ? 'Detect Current Location'
                              : 'Location: ${_position!.latitude.toStringAsFixed(4)}, ${_position!.longitude.toStringAsFixed(4)}',
                          style: TextStyle(
                            color: _position != null
                                ? AppColors.success
                                : AppColors.info,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide.none,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    // Availability switch
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _available ? Icons.check_circle : Icons.cancel,
                            color: _available ? AppColors.success : AppColors.textSecondary,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Availability',
                                  style: TextStyle(
                                    fontSize: AppText.bodyLarge,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  _available ? 'Available for requests' : 'Currently unavailable',
                                  style: TextStyle(
                                    fontSize: AppText.bodySmall,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _available,
                            onChanged: (v) => setState(() => _available = v),
                            activeColor: AppColors.success,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    // Submit button
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.accentOrange, AppColors.warning],
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        boxShadow: AppShadows.lg,
                      ),
                      child: ElevatedButton.icon(
                        onPressed: _submit,
                        icon: const Icon(Icons.check_circle_outline, size: 24),
                        label: const Text(
                          'Register',
                          style: TextStyle(
                            fontSize: AppText.button,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    // Info text
                    Text(
                      'By registering, you agree to our terms of service',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: AppText.bodySmall,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


