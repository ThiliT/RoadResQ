class Rating {
  final String serviceId;
  final String mechanicId;
  final String driverId;
  final int rating; // 1-5
  final String? comment;
  final DateTime timestamp;

  const Rating({
    required this.serviceId,
    required this.mechanicId,
    required this.driverId,
    required this.rating,
    this.comment,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'serviceId': serviceId,
        'mechanicId': mechanicId,
        'driverId': driverId,
        'rating': rating,
        'comment': comment,
        'timestamp': timestamp.toIso8601String(),
      };

  factory Rating.fromJson(Map<String, dynamic> json) => Rating(
        serviceId: json['serviceId'] as String,
        mechanicId: json['mechanicId'] as String,
        driverId: json['driverId'] as String,
        rating: json['rating'] as int,
        comment: json['comment'] as String?,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );
}

