String? emptyFieldValidator(String? value, {String fieldName = 'Este campo'}) {
  if (value == null || value.trim().isEmpty) {
    return '$fieldName es obligatorio';
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