// class Mechanic {
//   final String id;
//   final String name;
//   final String phone;
//   final double latitude;
//   final double longitude;
//   final String area;
//   final bool available;
//   final double rating;

//   const Mechanic({
//     required this.id,
//     required this.name,
//     required this.phone,
//     required this.latitude,
//     required this.longitude,
//     required this.area,
//     required this.available,
//     required this.rating,
//   });

//   factory Mechanic.fromJson(Map<String, dynamic> json) => Mechanic(
//         id: json['id'] as String,
//         name: json['name'] as String,
//         phone: json['phone'] as String,
//         latitude: (json['latitude'] as num).toDouble(),
//         longitude: (json['longitude'] as num).toDouble(),
//         area: json['area'] as String,
//         available: json['available'] as bool,
//         rating: (json['rating'] as num).toDouble(),
//       );

//   Map<String, dynamic> toJson() => {
//         'id': id,
//         'name': name,
//         'phone': phone,
//         'latitude': latitude,
//         'longitude': longitude,
//         'area': area,
//         'available': available,
//         'rating': rating,
//       };
// }


class Mechanic {
  final int id;
  final String name;
  final String phone;
  final double latitude;
  final double longitude;
  final String area;
  final String district;
  final String shopName;
  final String address;
  final bool available;
  final double rating;
  final String email;
  final String services;
  final bool contactVerified;

  Mechanic({
    required this.id,
    required this.name,
    required this.phone,
    required this.latitude,
    required this.longitude,
    required this.area,
    required this.district,
    required this.shopName,
    required this.address,
    required this.available,
    required this.rating,
    required this.email,
    required this.services,
    required this.contactVerified,
  });

  factory Mechanic.fromJson(Map<String, dynamic> json) {
    return Mechanic(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      area: json['area'] ?? '',
      district: json['district'] ?? '',
      shopName: json['shop_name'] ?? '',
      address: json['address'] ?? '',
      available: json['available'] == 1 || json['available'] == true,
      rating: (json['rating'] ?? 0).toDouble(),
      email: json['email'] ?? '',
      services: json['services'] ?? '',
      contactVerified:
          json['contact_verified'] == 1 || json['contact_verified'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'latitude': latitude,
      'longitude': longitude,
      'area': area,
      'district': district,
      'shop_name': shopName,
      'address': address,
      'available': available ? 1 : 0,
      'rating': rating,
      'email': email,
      'services': services,
      'contact_verified': contactVerified ? 1 : 0,
    };
  }
}
