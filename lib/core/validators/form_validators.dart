String? emptyFieldValidator(String? value, {String fieldName = 'Este campo'}) {
  if (value == null || value.trim().isEmpty) {
    return '$fieldName es obligatorio';
  }
  return null;
}

String? nameValidator(
  String? value, {
  required String fieldName,
  int minLength = 3,
  int maxLength = 20,
}) {
  final normalizedValue = value?.trim() ?? '';
  final empty = emptyFieldValidator(normalizedValue, fieldName: fieldName);
  if (empty != null) return empty;

  if (normalizedValue.length < minLength) {
    return '$fieldName debe tener al menos $minLength caracteres';
  }

  if (normalizedValue.length > maxLength) {
    return '$fieldName no puede superar $maxLength caracteres';
  }

  return null;
}

String? uniandesEmailValidator(String? value) {
  final email = value?.trim() ?? '';
  final emailRegex = RegExp(r'^[\w-\.]+@uniandes\.edu\.co$');
  if (!emailRegex.hasMatch(email)) {
    return 'Debes usar un correo @uniandes.edu.co';
  }
  return null;
}

String? passwordStrengthValidator(String? value) {
  final password = value?.trim() ?? '';

  if (password.length < 8) {
    return 'La contraseña debe tener al menos 8 caracteres';
  }

  if (password.length > 30) {
    return 'La contraseña no puede superar 30 caracteres';
  }

  if (!RegExp(r'[A-Z]').hasMatch(password)) {
    return 'La contraseña debe tener al menos una mayúscula';
  }

  if (!RegExp(r'[a-z]').hasMatch(password)) {
    return 'La contraseña debe tener al menos una minúscula';
  }

  if (!RegExp(r'[0-9]').hasMatch(password)) {
    return 'La contraseña debe tener al menos un número';
  }

  if (!RegExp(r'[!@#$%^&*(),.?":{}|<>_\-\\/\[\];+=`~]').hasMatch(password)) {
    return 'La contraseña debe tener al menos un signo';
  }

  return null;
}

String? confirmPasswordValidator(
  String? value, {
  required String originalPassword,
}) {
  final empty = emptyFieldValidator(value, fieldName: 'Validar contraseña');
  if (empty != null) return empty;

  if ((value?.trim() ?? '') != originalPassword.trim()) {
    return 'Las contraseñas no coinciden';
  }

  return null;
}
