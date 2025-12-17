class PaymentMethod {
  final String type;
  final String last4;

  const PaymentMethod({required this.type, required this.last4});

  Map<String, dynamic> toJson() => {
        'type': type,
        'last4': last4,
      };

  factory PaymentMethod.fromJson(Map<String, dynamic> json) => PaymentMethod(
        type: json['type'] as String? ?? '',
        last4: json['last4'] as String? ?? '',
      );
}


