class DriverUser {
  final String name;
  final String phone;
  final String vehicleType;
  final String email;
  final String plateNumber;
  final String photoPath;

  const DriverUser({
    required this.name,
    required this.phone,
    required this.vehicleType,
    this.email = '',
    this.plateNumber = '',
    this.photoPath = '',
  });

  DriverUser copyWith({
    String? name,
    String? phone,
    String? vehicleType,
    String? email,
    String? plateNumber,
    String? photoPath,
  }) {
    return DriverUser(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      vehicleType: vehicleType ?? this.vehicleType,
      email: email ?? this.email,
      plateNumber: plateNumber ?? this.plateNumber,
      photoPath: photoPath ?? this.photoPath,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
        'vehicleType': vehicleType,
        'email': email,
        'plateNumber': plateNumber,
        'photoPath': photoPath,
      };

  factory DriverUser.fromJson(Map<String, dynamic> json) => DriverUser(
        name: json['name'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        vehicleType: json['vehicleType'] as String? ?? '',
        email: json['email'] as String? ?? '',
        plateNumber: json['plateNumber'] as String? ?? '',
        photoPath: json['photoPath'] as String? ?? '',
      );
}

enum UserRole { driver, mechanic }


