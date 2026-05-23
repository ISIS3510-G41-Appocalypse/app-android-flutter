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
  int maxLength = 32,
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
    return 'La contrasena debe tener al menos 8 caracteres';
  }

  if (password.length > 32) {
    return 'La contrasena no puede superar 32 caracteres';
  }

  if (!RegExp(r'[A-Z]').hasMatch(password)) {
    return 'La contrasena debe tener al menos una mayuscula';
  }

  if (!RegExp(r'[a-z]').hasMatch(password)) {
    return 'La contrasena debe tener al menos una minuscula';
  }

  if (!RegExp(r'[0-9]').hasMatch(password)) {
    return 'La contrasena debe tener al menos un numero';
  }

  if (!RegExp(r'[!@#$%^&*(),.?":{}|<>_\-\\/\[\];+=`~]').hasMatch(password)) {
    return 'La contrasena debe tener al menos un signo';
  }

  return null;
}

String? confirmPasswordValidator(
  String? value, {
  required String originalPassword,
}) {
  final empty = emptyFieldValidator(value, fieldName: 'Validar contrasena');
  if (empty != null) return empty;

  if ((value?.trim() ?? '') != originalPassword.trim()) {
    return 'Las contrasenas no coinciden';
  }

  return null;
}
