import '../repositories/auth_repository.dart';

class SendPasswordReset {
  SendPasswordReset(this.repo);
  final AuthRepository repo;

  Future<void> call(String email) => repo.sendPasswordReset(email);
}
