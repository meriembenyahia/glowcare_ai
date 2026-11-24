import 'package:flutter/material.dart';

/// Supported payment options at checkout.
/// Card / Baridimob payments are captured as a confirmation request and
/// remain "pending" until the merchant verifies them.
enum PaymentMethod { cod, cib, edahabia, baridimob }

extension PaymentMethodX on PaymentMethod {
  String get labelKey {
    switch (this) {
      case PaymentMethod.cod:
        return 'Cash on Delivery';
      case PaymentMethod.cib:
        return 'CIB Card';
      case PaymentMethod.edahabia:
        return 'EDAHABIA Card';
      case PaymentMethod.baridimob:
        return 'Baridimob';
    }
  }

  String get descriptionKey {
    switch (this) {
      case PaymentMethod.cod:
        return 'Pay in cash when your order is delivered';
      case PaymentMethod.cib:
        return 'Pay securely with your CIB card';
      case PaymentMethod.edahabia:
        return 'Pay with your EDAHABIA card';
      case PaymentMethod.baridimob:
        return 'Bank transfer via the Baridimob app';
    }
  }

  IconData get icon {
    switch (this) {
      case PaymentMethod.cod:
        return Icons.payments_outlined;
      case PaymentMethod.cib:
        return Icons.credit_card;
      case PaymentMethod.edahabia:
        return Icons.credit_card_outlined;
      case PaymentMethod.baridimob:
        return Icons.phone_android;
    }
  }

  bool get isCard => this == PaymentMethod.cib || this == PaymentMethod.edahabia;

  bool get needsVerification => this != PaymentMethod.cod;
}

PaymentMethod paymentMethodFromName(String? name) {
  for (final method in PaymentMethod.values) {
    if (method.name == name) return method;
  }
  return PaymentMethod.cod;
}
