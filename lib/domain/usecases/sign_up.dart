// Caso de uso para crear una cuenta nueva.

import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SignUp {
  final AuthRepository repo;
  SignUp(this.repo);

  // Ejecuta la lógica relacionada con call.
  Future<UserEntity> call(String email, String password, String name) => repo.signUp(email, password, name);
}
