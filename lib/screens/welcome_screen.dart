import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'registration/driver_registration.dart';
import 'registration/mechanic_registration.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.deepOcean),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Welcome to',
                  style: TextStyle(color: Colors.white70, fontSize: 18),
                ),
                const SizedBox(height: 4),
                const Text(
                  AppStrings.appName,
                  style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text(
                  'On-demand roadside assistance. Fast. Reliable. Nearby.',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const Spacer(),
                _RoleCard(
                  title: "I'm a Driver",
                  icon: Icons.directions_car_rounded,
                  color: AppColors.primary,
                  onTap: () {
                    Navigator.of(context).push(_fade(const DriverRegistrationScreen()));
                  },
                ),
                const SizedBox(height: 16),
                _RoleCard(
                  title: "I'm a Mechanic",
                  icon: Icons.handyman_rounded,
                  color: AppColors.accent,
                  onTap: () {
                    Navigator.of(context).push(_fade(const MechanicRegistrationScreen()));
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PageRouteBuilder _fade(Widget page) => PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child),
      );
}

class _RoleCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _RoleCard({required this.title, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Colors.white.withOpacity(0.08),
          border: Border.all(color: Colors.white24),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        child: Row(
          children: [
            CircleAvatar(radius: 28, backgroundColor: color.withOpacity(0.2), child: Icon(icon, color: Colors.white, size: 28)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                const Text('Register and get started', style: TextStyle(color: Colors.white70)),
              ]),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70),
          ],
        ),
      ),
    );
  }
}

// Removed temporary ComingSoon widget now that flows are wired.


