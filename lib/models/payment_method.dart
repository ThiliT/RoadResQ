class PaymentMethod {
  final String id;
  final String cardNumber;
  final String cardholderName;
  final String expiryMonth;
  final String expiryYear;
  final String cvv;
  final bool isDefault;

  const PaymentMethod({
    required this.id,
    required this.cardNumber,
    required this.cardholderName,
    required this.expiryMonth,
    required this.expiryYear,
    required this.cvv,
    this.isDefault = false,
  });

  PaymentMethod copyWith({
    String? id,
    String? cardNumber,
    String? cardholderName,
    String? expiryMonth,
    String? expiryYear,
    String? cvv,
    bool? isDefault,
  }) {
    return PaymentMethod(
      id: id ?? this.id,
      cardNumber: cardNumber ?? this.cardNumber,
      cardholderName: cardholderName ?? this.cardholderName,
      expiryMonth: expiryMonth ?? this.expiryMonth,
      expiryYear: expiryYear ?? this.expiryYear,
      cvv: cvv ?? this.cvv,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  String get maskedCardNumber {
    if (cardNumber.length < 4) return cardNumber;
    final last4 = cardNumber.substring(cardNumber.length - 4);
    return '**** **** **** $last4';
  }

  String get expiryDate => '$expiryMonth/$expiryYear';

  Map<String, dynamic> toJson() => {
        'id': id,
        'cardNumber': cardNumber,
        'cardholderName': cardholderName,
        'expiryMonth': expiryMonth,
        'expiryYear': expiryYear,
        'cvv': cvv,
        'isDefault': isDefault,
      };

  factory PaymentMethod.fromJson(Map<String, dynamic> json) => PaymentMethod(
        id: json['id'] as String,
        cardNumber: json['cardNumber'] as String,
        cardholderName: json['cardholderName'] as String,
        expiryMonth: json['expiryMonth'] as String,
        expiryYear: json['expiryYear'] as String,
        cvv: json['cvv'] as String,
        isDefault: json['isDefault'] as bool? ?? false,
      );
}


