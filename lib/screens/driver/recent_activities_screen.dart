import 'package:flutter/material.dart';
import '../../models/activity.dart';
import '../../models/rating.dart';
import '../../models/user.dart';
import '../../services/rating_service.dart';
import '../../services/storage_service.dart';
import '../../utils/constants.dart';
import '../../widgets/rating_widget.dart';

class RecentActivitiesScreen extends StatefulWidget {
  const RecentActivitiesScreen({super.key});

  @override
  State<RecentActivitiesScreen> createState() => _RecentActivitiesScreenState();
}

class _RecentActivitiesScreenState extends State<RecentActivitiesScreen> {
  late Future<List<Activity>> _activitiesFuture;
  bool _isLoading = false;
  final RatingService _ratingService = RatingService();

  @override
  void initState() {
    super.initState();
    _activitiesFuture = _fetchActivities();
  }

  // API-ready method - replace with actual API call later
  Future<List<Activity>> _fetchActivities() async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // TODO: Replace with actual API call
    // Example: return await ActivityService().getRecentActivities();
    
    // Mock data for now
    final now = DateTime.now();
    return [
      Activity(
        id: '1',
        type: ActivityType.fuelDelivery,
        status: ActivityStatus.completed,
        timestamp: now.subtract(const Duration(hours: 2)),
      ),
      Activity(
        id: '2',
        type: ActivityType.towing,
        status: ActivityStatus.cancelled,
        timestamp: now.subtract(const Duration(days: 1)),
      ),
      Activity(
        id: '3',
        type: ActivityType.batteryJump,
        status: ActivityStatus.completed,
        timestamp: now.subtract(const Duration(days: 3)),
      ),
    ];
  }

  Future<void> _refreshActivities() async {
    setState(() {
      _isLoading = true;
      _activitiesFuture = _fetchActivities();
    });
    await _activitiesFuture;
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Recent Activities', style: TextStyle(fontWeight: FontWeight.w700)),
        elevation: 0,
      ),
      body: FutureBuilder<List<Activity>>(
        future: _activitiesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded, size: 64, color: Colors.redAccent),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load activities',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _refreshActivities,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final activities = snapshot.data ?? [];

          if (activities.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: _refreshActivities,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: activities.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final activity = activities[index];
                return _ActivityCard(
                  activity: activity,
                  ratingService: _ratingService,
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history_rounded,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 24),
            Text(
              'No recent activities',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your service requests and activities will appear here',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityCard extends StatefulWidget {
  final Activity activity;
  final RatingService ratingService;

  const _ActivityCard({required this.activity, required this.ratingService});

  @override
  State<_ActivityCard> createState() => _ActivityCardState();
}

class _ActivityCardState extends State<_ActivityCard> {
  bool _hasRated = false;
  Rating? _existingRating;

  @override
  void initState() {
    super.initState();
    _loadRatingState();
  }

  Future<void> _loadRatingState() async {
    final hasRated = await widget.ratingService.hasRated(widget.activity.id);
    Rating? rating;
    if (hasRated) {
      rating = await widget.ratingService.getRatingForService(widget.activity.id);
    }
    if (!mounted) return;
    setState(() {
      _hasRated = hasRated;
      _existingRating = rating;
    });
  }

  Future<void> _showRateDialog(BuildContext context) async {
    if (widget.activity.status != ActivityStatus.completed) return;

    int selectedRating = _existingRating?.rating ?? 0;
    final commentController = TextEditingController(text: _existingRating?.comment ?? '');

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
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Rate Mechanic',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        icon: const Icon(Icons.close_rounded),
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 24,
                        child: Icon(Icons.handyman_rounded),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.activity.mechanicName ?? 'Mechanic',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${widget.activity.typeLabel} • ${_formatTimestamp(widget.activity.timestamp)}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'How was the service?',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: RatingWidget(
                      rating: selectedRating,
                      onChanged: (value) {
                        setSheetState(() {
                          selectedRating = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: commentController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Add feedback (optional)',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text('Skip'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: selectedRating == 0
                              ? null
                              : () async {
                                  // Build rating payload
                                  final storage = StorageService();
                                  final driver = await storage.getDriver();
                                  final driverId = driver?.phone ?? 'unknown_driver';
                                  final mechanicId = widget.activity.mechanicName ?? 'unknown_mechanic';

                                  final rating = Rating(
                                    serviceId: widget.activity.id,
                                    mechanicId: mechanicId,
                                    driverId: driverId,
                                    rating: selectedRating,
                                    comment: commentController.text.trim().isEmpty
                                        ? null
                                        : commentController.text.trim(),
                                    timestamp: DateTime.now(),
                                  );

                                  try {
                                    await widget.ratingService.addRating(rating);
                                    if (!mounted) return;
                                    setState(() {
                                      _hasRated = true;
                                      _existingRating = rating;
                                    });
                                    Navigator.of(ctx).pop();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Thank you for rating!'),
                                        backgroundColor: AppColors.success,
                                      ),
                                    );
                                  } catch (e) {
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Failed to submit rating: $e'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                          child: const Text('Submit Rating'),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final activity = widget.activity;
    return Card(
      child: InkWell(
        onTap: () {
          // For completed services, tap opens the rating dialog.
          if (activity.status == ActivityStatus.completed && !_hasRated) {
            _showRateDialog(context);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${activity.typeLabel} - ${activity.statusLabel}'),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: activity.statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.local_activity_rounded,
                  color: activity.statusColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.typeLabel,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          activity.statusLabel,
                          style: TextStyle(
                            color: activity.statusColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '•',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          activity.timeAgo,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatTimestamp(activity.timestamp),
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                    if (activity.status == ActivityStatus.completed)
                      Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: _hasRated
                              ? Row(
                                  children: [
                                    const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${_existingRating?.rating ?? '-'} / 5',
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                )
                              : TextButton.icon(
                                  onPressed: () => _showRateDialog(context),
                                  icon: const Icon(Icons.star_border_rounded, size: 18),
                                  label: const Text('Rate mechanic'),
                                ),
                        ),
                      ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final activityDate = DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (activityDate == today) {
      // Show time for today
      final hour = timestamp.hour;
      final minute = timestamp.minute.toString().padLeft(2, '0');
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$displayHour:$minute $period';
    } else {
      // Show date for older activities
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      return '${months[timestamp.month - 1]} ${timestamp.day}, ${timestamp.year}';
    }
  }
}

