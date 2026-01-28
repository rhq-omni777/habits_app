import '../repositories/auth_repository.dart';
import '../entities/user_entity.dart';

class SignInAnonymously {
  SignInAnonymously(this._repo);
  final AuthRepository _repo;

  Future<UserEntity> call() => _repo.signInAnonymously();
}
