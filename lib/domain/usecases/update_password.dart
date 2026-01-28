import '../repositories/auth_repository.dart';

class UpdatePassword {
  UpdatePassword(this._repo);
  final AuthRepository _repo;

  Future<void> call(String newPassword, {String? currentPassword}) {
    return _repo.updatePassword(newPassword: newPassword, currentPassword: currentPassword);
  }
}
