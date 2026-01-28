import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SignUp {
  final AuthRepository repo;
  SignUp(this.repo);
  Future<UserEntity> call(String email, String password, String name) => repo.signUp(email, password, name);
}
