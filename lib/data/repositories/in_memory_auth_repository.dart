import 'dart:async';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/in_memory_store.dart';
import '../models/user_model.dart';

class InMemoryAuthRepository implements AuthRepository {
  final InMemoryStore _store = InMemoryStore.instance;

  @override
  Stream<UserEntity?> authStateChanges() => _store.authChanges();

  @override
  Future<UserEntity?> currentUser() async => _store.currentUser;

  @override
  Future<UserEntity> signIn(String email, String password) async {
    final existing = _store.currentUser ?? UserModel(
      id: email.hashCode.toString(),
      email: email,
      displayName: email.split('@').first,
    );
    _store.currentUser = existing;
    _store.emitAuth(existing);
    return existing;
  }

  @override
  Future<UserEntity> signInWithGoogle() async {
    final user = UserModel(
      id: 'google-${DateTime.now().millisecondsSinceEpoch}',
      email: 'google_user@example.com',
      displayName: 'Google User',
    );
    _store.currentUser = user;
    _store.emitAuth(user);
    return user;
  }

  @override
  Future<UserEntity> signInAnonymously() async {
    final user = UserModel(
      id: 'guest-${DateTime.now().millisecondsSinceEpoch}',
      email: '',
      displayName: 'Invitado',
    );
    _store.currentUser = user;
    _store.emitAuth(user);
    return user;
  }

  @override
  Future<UserEntity> signUp(String email, String password, String name) async {
    final user = UserModel(id: DateTime.now().millisecondsSinceEpoch.toString(), email: email, displayName: name);
    _store.currentUser = user;
    _store.emitAuth(user);
    return user;
  }

  @override
  Future<void> signOut() async {
    _store.currentUser = null;
    _store.emitAuth(null);
  }

  @override
  Future<void> updateEmail({required String newEmail, String? currentPassword}) async {
    final user = _store.currentUser;
    if (user == null) throw Exception('No hay usuario autenticado');
    _store.currentUser = UserModel(id: user.id, email: newEmail, displayName: user.displayName);
    _store.emitAuth(_store.currentUser);
  }

  @override
  Future<void> updatePassword({String? currentPassword, required String newPassword}) async {
    // No password storage in-memory; nothing to persist.
    return;
  }

  @override
  Future<void> linkEmailPassword({required String email, required String password}) async {
    final user = _store.currentUser;
    if (user == null) throw Exception('No hay usuario autenticado');
    _store.currentUser = UserModel(id: user.id, email: email, displayName: user.displayName);
    _store.emitAuth(_store.currentUser);
  }

  @override
  Future<bool> needsPasswordLink() async {
    final user = _store.currentUser;
    if (user == null) return false;
    // En memoria: consideramos que usuarios con email vacío son invitados,
    // los de Google son los creados por signInWithGoogle (tienen correo simulado) sin password.
    final isGuest = user.email.isEmpty;
    final isGoogle = user.id.startsWith('google-');
    return isGoogle && !isGuest;
  }
}
