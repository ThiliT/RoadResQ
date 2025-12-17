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

class _DriverDashboardScreenState extends State<DriverDashboardScreen> with SingleTickerProviderStateMixin {
  final ConnectivityService _connectivity = ConnectivityService();
  final LocationService _locationService = LocationService();
  final CommunicationService _comm = CommunicationService();
  bool _online = true;
  int _tabIndex = 0;
  String _locationText = 'Detecting location...';
  bool _smsModeActive = false;
  late AnimationController _fabController;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      duration: AppAnimations.normal,
      vsync: this,
    )..repeat(reverse: true);
    _init();
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    _online = await _connectivity.isOnline();
    _connectivity.connectivityStream.listen((results) {
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
        _tabIndex = 1;
        _smsModeActive = false;
      });
    } else {
      setState(() => _smsModeActive = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.white),
              SizedBox(width: 8),
              Expanded(child: Text('Offline Mode: Sending request to backend...')),
            ],
          ),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      );
      try {
        final storageService = StorageService();
        final driver = await storageService.getDriver();
        if (driver == null) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('User information not found. Please register first.'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
          );
          return;
        }

        final pos = await _locationService.getCurrentLocation();
        final requestMessage = 'HELP ${driver.phone} ${pos.latitude.toStringAsFixed(4)},${pos.longitude.toStringAsFixed(4)}';
        await _comm.sendSMS(AppStrings.backendSmsNumber, requestMessage);
        
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Expanded(child: Text('Request sent. You will receive SMS with nearby mechanics list shortly.')),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send request: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
        );
      }
    }
  }

  Widget _buildHome() {
    return Column(
      children: [
        StatusCard(location: _locationText, online: _online, onEmergency: _emergency),
        if (_online)
          const Expanded(child: MechanicListView())
        else
          Expanded(child: _buildOfflineSms()),
      ],
    );
  }

  Widget _buildOfflineSms() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.all(AppSpacing.md),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.warning.withOpacity(0.15),
                AppColors.accentOrange.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: AppColors.warning.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline_rounded, color: AppColors.warning),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  'Offline Mode: Request sent to backend. You will receive SMS with nearby mechanics list.',
                  style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : AppColors.textPrimary,
                    fontSize: AppText.body,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Container(
            decoration: BoxDecoration(
              gradient: AppGradients.warmSunset,
              borderRadius: BorderRadius.circular(AppRadius.md),
              boxShadow: AppShadows.md,
            ),
            child: ElevatedButton.icon(
              onPressed: _emergency,
              icon: const Icon(Icons.sms_rounded),
              label: const Text('Send Emergency SMS'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
              ),
            ),
          ),
        ),
        // const SizedBox(height: AppSpacing.md),
        // ... (inside _buildOfflineSms)

        // The final section
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                children: [
                  const Spacer(), 
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.sms_outlined,
                      size: 64,
                      color: AppColors.warning,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Backend will send SMS to your registered phone number with the list of nearby mechanics.',
                    style: TextStyle(
                      fontSize: AppText.body,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(), 
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfile() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              size: 64,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Profile',
            style: TextStyle(
              fontSize: AppText.h3,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Coming soon',
            style: TextStyle(
              fontSize: AppText.body,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
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
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppGradients.warmSunset,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: const Icon(
                Icons.emergency_share_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            const Text('RoadResQ'),
          ],
        ),
        elevation: 0,
      ),
      body: AnimatedSwitcher(
        duration: AppAnimations.normal,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.1, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: AppAnimations.defaultCurve,
              )),
              child: child,
            ),
          );
        },
        child: pages[_tabIndex],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (i) => setState(() => _tabIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map_rounded),
            label: 'Map',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _fabController,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 + (_fabController.value * 0.05),
            child: Container(
              decoration: BoxDecoration(
                gradient: AppGradients.emergency,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                boxShadow: [
                  ...AppShadows.xl,
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: FloatingActionButton.extended(
                onPressed: _emergency,
                icon: const Icon(Icons.emergency_rounded),
                label: const Text(
                  'Help',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}


