import '../repositories/auth_repository.dart';

class UpdateEmail {
  UpdateEmail(this._repo);
  final AuthRepository _repo;

  Future<void> call(String newEmail, {String? currentPassword}) {
    return _repo.updateEmail(newEmail: newEmail, currentPassword: currentPassword);
  }
}
