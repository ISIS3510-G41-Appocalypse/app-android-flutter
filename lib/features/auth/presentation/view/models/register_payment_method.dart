enum RegisterPaymentMethod {
  nequi,
  daviplata,
  llave,
  efectivo,
}

extension RegisterPaymentMethodX on RegisterPaymentMethod {
  String get label {
    switch (this) {
      case RegisterPaymentMethod.nequi:
        return 'Nequi';
      case RegisterPaymentMethod.daviplata:
        return 'Daviplata';
      case RegisterPaymentMethod.llave:
        return 'Llave';
      case RegisterPaymentMethod.efectivo:
        return 'Efectivo';
    }
  }

  bool get requiresValue => this != RegisterPaymentMethod.efectivo;

  String get hintText {
    switch (this) {
      case RegisterPaymentMethod.nequi:
      case RegisterPaymentMethod.daviplata:
        return 'Numero';
      case RegisterPaymentMethod.llave:
        return 'Llave';
      case RegisterPaymentMethod.efectivo:
        return '';
    }
  }
}
