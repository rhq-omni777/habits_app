// Caso de uso para vincular una contraseña a una cuenta de Google.

import '../repositories/auth_repository.dart';

class LinkEmailPassword {
  LinkEmailPassword(this._repo);
  final AuthRepository _repo;

  // Ejecuta la lógica relacionada con call.
  Future<void> call(String email, String password) {
    return _repo.linkEmailPassword(email: email, password: password);
  }
}
