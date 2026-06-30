// Caso de uso para entrar como usuario invitado.

import '../repositories/auth_repository.dart';
import '../entities/user_entity.dart';

class SignInAnonymously {
  SignInAnonymously(this._repo);
  final AuthRepository _repo;

  // Ejecuta la lógica relacionada con call.
  Future<UserEntity> call() => _repo.signInAnonymously();
}
