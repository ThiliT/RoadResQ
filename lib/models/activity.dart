import 'package:flutter/material.dart';
import '../utils/constants.dart';

enum ActivityStatus {
  completed,
  cancelled,
  pending,
  inProgress,
}

enum ActivityType {
  fuelDelivery,
  towing,
  batteryJump,
  flatTire,
  other,
}

class Activity {
  final String id;
  final ActivityType type;
  final ActivityStatus status;
  final DateTime timestamp;
  final String? description;
  final String? mechanicName;

  const Activity({
    required this.id,
    required this.type,
    required this.status,
    required this.timestamp,
    this.description,
    this.mechanicName,
  });

  String get typeLabel {
    switch (type) {
      case ActivityType.fuelDelivery:
        return 'Fuel delivery';
      case ActivityType.towing:
        return 'Towing request';
      case ActivityType.batteryJump:
        return 'Battery jump';
      case ActivityType.flatTire:
        return 'Flat tire';
      case ActivityType.other:
        return description ?? 'Service request';
    }
  }

  String get statusLabel {
    switch (status) {
      case ActivityStatus.completed:
        return 'Completed';
      case ActivityStatus.cancelled:
        return 'Cancelled';
      case ActivityStatus.pending:
        return 'Pending';
      case ActivityStatus.inProgress:
        return 'In progress';
    }
  }

  Color get statusColor {
    switch (status) {
      case ActivityStatus.completed:
        return AppColors.success;
      case ActivityStatus.cancelled:
        return Colors.orangeAccent;
      case ActivityStatus.pending:
        return Colors.blueAccent;
      case ActivityStatus.inProgress:
        return Colors.purpleAccent;
    }
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 7) {
      return '${difference.inDays ~/ 7} weeks ago';
    } else if (difference.inDays > 0) {
      if (difference.inDays == 1) {
        return 'Yesterday';
      }
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      if (difference.inHours == 1) {
        return '1 hour ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      if (difference.inMinutes == 1) {
        return '1 minute ago';
      }
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  String get fullDescription {
    return '$statusLabel • $timeAgo';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'status': status.name,
        'timestamp': timestamp.toIso8601String(),
        'description': description,
        'mechanicName': mechanicName,
      };

  factory Activity.fromJson(Map<String, dynamic> json) => Activity(
        id: json['id'] as String,
        type: ActivityType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => ActivityType.other,
        ),
        status: ActivityStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => ActivityStatus.pending,
        ),
        timestamp: DateTime.parse(json['timestamp'] as String),
        description: json['description'] as String?,
        mechanicName: json['mechanicName'] as String?,
      );
}

