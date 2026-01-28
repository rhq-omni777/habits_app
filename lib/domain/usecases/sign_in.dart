import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SignIn {
  final AuthRepository repo;
  SignIn(this.repo);
  Future<UserEntity> call(String email, String password) => repo.signIn(email, password);
}
