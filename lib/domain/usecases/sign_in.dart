// Caso de uso para iniciar sesión con correo y contraseña.

import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SignIn {
  final AuthRepository repo;
  SignIn(this.repo);

  // Ejecuta la lógica relacionada con call.
  Future<UserEntity> call(String email, String password) => repo.signIn(email, password);
}
