class DriverUser {
  final String name;
  final String phone;
  final String vehicleType;
  final String email;
  final String plateNumber;

  const DriverUser({
    required this.name,
    required this.phone,
    required this.vehicleType,
    this.email = '',
    this.plateNumber = '',
  });

  DriverUser copyWith({
    String? name,
    String? phone,
    String? vehicleType,
    String? email,
    String? plateNumber,
  }) {
    return DriverUser(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      vehicleType: vehicleType ?? this.vehicleType,
      email: email ?? this.email,
      plateNumber: plateNumber ?? this.plateNumber,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
        'vehicleType': vehicleType,
        'email': email,
        'plateNumber': plateNumber,
      };

  factory DriverUser.fromJson(Map<String, dynamic> json) => DriverUser(
        name: json['name'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        vehicleType: json['vehicleType'] as String? ?? '',
        email: json['email'] as String? ?? '',
        plateNumber: json['plateNumber'] as String? ?? '',
      );
}

enum UserRole { driver, mechanic }


