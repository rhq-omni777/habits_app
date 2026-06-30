// Caso de uso para enviar un enlace para recuperar la contraseña.

import '../repositories/auth_repository.dart';

class SendPasswordReset {
  SendPasswordReset(this.repo);
  final AuthRepository repo;

  // Ejecuta la lógica relacionada con call.
  Future<void> call(String email) => repo.sendPasswordReset(email);
}
