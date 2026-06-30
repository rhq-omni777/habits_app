// Caso de uso para eliminar la cuenta del usuario.

import '../repositories/auth_repository.dart';

class DeleteAccount {
  DeleteAccount(this.repo);
  final AuthRepository repo;

  Future<void> call({String? currentPassword}) => repo.deleteAccount(currentPassword: currentPassword);
}
