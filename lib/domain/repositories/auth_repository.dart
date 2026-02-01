import '../entities/user_entity.dart';

abstract class AuthRepository {
  Stream<UserEntity?> authStateChanges();
  Future<UserEntity?> currentUser();
  Future<UserEntity> signIn(String email, String password);
  Future<UserEntity> signInWithGoogle();
  Future<UserEntity> signInAnonymously();
  Future<UserEntity> signUp(String email, String password, String name);
  Future<void> signOut();
  Future<void> updateEmail({required String newEmail, String? currentPassword});
  Future<void> updatePassword({String? currentPassword, required String newPassword});
  Future<void> linkEmailPassword({required String email, required String password});
  Future<bool> needsPasswordLink();
}
