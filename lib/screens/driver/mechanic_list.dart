import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../models/mechanic.dart';
import '../../services/location_service.dart';
import '../../services/communication_service.dart';
import '../../services/mechanics_service.dart';
import '../../utils/constants.dart';

class MechanicListView extends StatefulWidget {
  const MechanicListView({super.key});

  @override
  State<MechanicListView> createState() => _MechanicListViewState();
}

class _MechanicListViewState extends State<MechanicListView> {
  final LocationService _locationService = LocationService();
  final MechanicsService _mechanicsService = MechanicsService();
  final CommunicationService _comm = CommunicationService();

  Position? _position;
  List<Mechanic> _items = [];
  bool _loading = true;
  String _search = '';
  double _radiusKm = 20;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    setState(() => _loading = true);
    try {
      // Get user location
      final pos = await _locationService.getCurrentLocation();

      // Fetch mechanics from backend
      final mechanics = await _mechanicsService.fetchMechanics();

      if (!mounted) return;

      setState(() {
        _position = pos;
        _items = mechanics;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching data: $e")),
      );
    }
  }

  List<Mechanic> _filtered() {
    final query = _search.trim().toLowerCase();
    var list = _items.where((m) =>
        query.isEmpty ||
        m.area.toLowerCase().contains(query) ||
        m.name.toLowerCase().contains(query)).toList();

    if (_position != null) {
      list = list
          .where((m) =>
              _locationService.calculateDistance(
                  _position!.latitude, _position!.longitude, m.latitude, m.longitude) <=
              _radiusKm)
          .toList();

      list.sort((a, b) {
        final da = _locationService.calculateDistance(
            _position!.latitude, _position!.longitude, a.latitude, a.longitude);
        final db = _locationService.calculateDistance(
            _position!.latitude, _position!.longitude, b.latitude, b.longitude);
        return da.compareTo(db);
      });
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Loading mechanics...',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: AppText.body,
              ),
            ),
          ],
        ),
      );
    }

    final items = _filtered();

    return RefreshIndicator(
      onRefresh: () async => await _init(),
      color: AppColors.primary,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          // Search + radius filter
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              boxShadow: AppShadows.sm,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search_rounded),
                      hintText: 'Search by area or name',
                      filled: true,
                      fillColor: Theme.of(context).scaffoldBackgroundColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (v) => setState(() => _search = v),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: DropdownButton<double>(
                    value: _radiusKm,
                    underline: const SizedBox(),
                    icon: Icon(Icons.tune_rounded, color: AppColors.primary),
                    items: const [
                      DropdownMenuItem(value: 5, child: Text('5km')),
                      DropdownMenuItem(value: 10, child: Text('10km')),
                      DropdownMenuItem(value: 20, child: Text('20km')),
                    ],
                    onChanged: (v) => setState(() => _radiusKm = v ?? 20),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Results count
          if (items.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Text(
                '${items.length} mechanic${items.length == 1 ? '' : 's'} found',
                style: TextStyle(
                  fontSize: AppText.bodySmall,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.sm),

          if (items.isEmpty)
            Container(
              margin: const EdgeInsets.only(top: AppSpacing.xxl),
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    decoration: BoxDecoration(
                      color: AppColors.textTertiary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.search_off_rounded,
                      size: 48,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'No mechanics found nearby',
                    style: TextStyle(
                      fontSize: AppText.h5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Try adjusting your search or radius filter',
                    style: TextStyle(
                      fontSize: AppText.body,
                      color: AppColors.textTertiary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

          ...items.map((m) => _MechanicCard(
              mechanic: m,
              position: _position,
              onCall: _comm.makePhoneCall,
              onSms: (p, msg) => _comm.sendSMS(p, msg))),
        ],
      ),
    );
  }
}

class _MechanicCard extends StatefulWidget {
  final Mechanic mechanic;
  final Position? position;
  final Future<void> Function(String) onCall;
  final Future<void> Function(String, String) onSms;

  const _MechanicCard({
    required this.mechanic,
    required this.position,
    required this.onCall,
    required this.onSms,
  });

  @override
  State<_MechanicCard> createState() => _MechanicCardState();
}

class _MechanicCardState extends State<_MechanicCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.fast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: AppAnimations.defaultCurve),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final service = LocationService();
    final distance = widget.position == null
        ? null
        : service.calculateDistance(
            widget.position!.latitude,
            widget.position!.longitude,
            widget.mechanic.latitude,
            widget.mechanic.longitude,
          );
    final eta = distance == null ? null : service.calculateETA(distance);

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                border: Border.all(
                  color: widget.mechanic.available
                      ? AppColors.success.withOpacity(0.2)
                      : AppColors.border,
                  width: 1.5,
                ),
                boxShadow: AppShadows.md,
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row
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
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: const Icon(
                            Icons.handyman_rounded,
                            color: AppColors.accentOrange,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.mechanic.name,
                                style: const TextStyle(
                                  fontSize: AppText.h5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              if (widget.mechanic.shopName.isNotEmpty)
                                Text(
                                  widget.mechanic.shopName,
                                  style: TextStyle(
                                    fontSize: AppText.bodySmall,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: AppColors.accentOrange,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.mechanic.rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: AppText.label,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.accentOrange,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    // Location info
                    Row(
                      children: [
                        Icon(
                          Icons.place_outlined,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            distance == null
                                ? '${widget.mechanic.area}, ${widget.mechanic.district}'
                                : '${distance.toStringAsFixed(1)} km away${eta != null ? ' • $eta' : ''}',
                            style: TextStyle(
                              fontSize: AppText.body,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: widget.mechanic.available
                                ? AppColors.success.withOpacity(0.15)
                                : AppColors.error.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(AppRadius.round),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: widget.mechanic.available
                                      ? AppColors.success
                                      : AppColors.error,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                widget.mechanic.available ? 'Available' : 'Busy',
                                style: TextStyle(
                                  fontSize: AppText.labelSmall,
                                  fontWeight: FontWeight.w600,
                                  color: widget.mechanic.available
                                      ? AppColors.success
                                      : AppColors.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    // Phone info
                    Row(
                      children: [
                        Icon(
                          Icons.phone_outlined,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          widget.mechanic.phone,
                          style: TextStyle(
                            fontSize: AppText.body,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => widget.onCall(widget.mechanic.phone),
                            icon: const Icon(Icons.call_rounded, size: 18),
                            label: const Text('Call'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: AppGradients.warmSunset,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              boxShadow: AppShadows.sm,
                            ),
                            child: ElevatedButton.icon(
                              onPressed: () => widget.onSms(
                                widget.mechanic.phone,
                                'Hello, I need roadside assistance.',
                              ),
                              icon: const Icon(Icons.sms_rounded, size: 18),
                              label: const Text('Message'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
