class DriverUser {
  final String name;
  final String phone;
  final String vehicleType;

  const DriverUser({required this.name, required this.phone, required this.vehicleType});

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
        'vehicleType': vehicleType,
      };

  factory DriverUser.fromJson(Map<String, dynamic> json) => DriverUser(
        name: json['name'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        vehicleType: json['vehicleType'] as String? ?? '',
      );
}

enum UserRole { driver, mechanic }


