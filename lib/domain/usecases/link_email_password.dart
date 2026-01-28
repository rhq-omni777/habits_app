import '../repositories/auth_repository.dart';

class LinkEmailPassword {
  LinkEmailPassword(this._repo);
  final AuthRepository _repo;

  Future<void> call(String email, String password) {
    return _repo.linkEmailPassword(email: email, password: password);
  }
}
