class Mechanic {
  final String id;
  final String name;
  final String phone;
  final double latitude;
  final double longitude;
  final String area;
  final bool available;
  final double rating;

  const Mechanic({
    required this.id,
    required this.name,
    required this.phone,
    required this.latitude,
    required this.longitude,
    required this.area,
    required this.available,
    required this.rating,
  });

  factory Mechanic.fromJson(Map<String, dynamic> json) => Mechanic(
        id: json['id'] as String,
        name: json['name'] as String,
        phone: json['phone'] as String,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        area: json['area'] as String,
        available: json['available'] as bool,
        rating: (json['rating'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'latitude': latitude,
        'longitude': longitude,
        'area': area,
        'available': available,
        'rating': rating,
      };
}


