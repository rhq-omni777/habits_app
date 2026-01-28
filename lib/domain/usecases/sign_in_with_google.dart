import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SignInWithGoogle {
  final AuthRepository repo;
  SignInWithGoogle(this.repo);

  Future<UserEntity> call() => repo.signInWithGoogle();
}
