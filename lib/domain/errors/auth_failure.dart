// Error de dominio para normalizar los fallos de autenticación.

// Representa un error de autenticación del dominio.
class AuthFailure implements Exception {
  final String code;
  final String message;

  const AuthFailure({required this.code, required this.message});

  @override

  // Ejecuta la lógica relacionada con to string.
  String toString() => 'AuthFailure($code): $message';
}
