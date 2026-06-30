// Caso de uso para iniciar sesión con Google.

import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SignInWithGoogle {
  final AuthRepository repo;
  SignInWithGoogle(this.repo);

  // Ejecuta la lógica relacionada con call.
  Future<UserEntity> call() => repo.signInWithGoogle();
}
