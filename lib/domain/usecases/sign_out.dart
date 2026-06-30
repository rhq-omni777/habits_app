// Caso de uso para cerrar la sesión del usuario.

import '../repositories/auth_repository.dart';

class SignOut {
  final AuthRepository repo;
  SignOut(this.repo);

  // Ejecuta la lógica relacionada con call.
  Future<void> call() => repo.signOut();
}
