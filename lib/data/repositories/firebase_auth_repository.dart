import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  UserEntity? _mapUser(fb.User? user) {
    if (user == null) return null;
    return UserEntity(id: user.uid, email: user.email ?? '', displayName: user.displayName ?? '');
  }

  @override
  Stream<UserEntity?> authStateChanges() => _auth.authStateChanges().map(_mapUser);

  @override
  Future<UserEntity?> currentUser() async => _mapUser(_auth.currentUser);

  @override
  Future<UserEntity> signIn(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
    return _mapUser(cred.user)!;
  }

  @override
  Future<UserEntity> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw Exception('Inicio cancelado');
    }
    final googleAuth = await googleUser.authentication;
    final credential = fb.GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final cred = await _auth.signInWithCredential(credential);
    return _mapUser(cred.user)!;
  }

  @override
  Future<UserEntity> signInAnonymously() async {
    final cred = await _auth.signInAnonymously();
    final user = cred.user;
    if (user != null && (user.displayName == null || user.displayName!.isEmpty)) {
      await user.updateDisplayName('Invitado');
    }
    return _mapUser(cred.user)!;
  }

  @override
  Future<UserEntity> signUp(String email, String password, String name) async {
    final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    await cred.user?.updateDisplayName(name);
    return _mapUser(cred.user)!;
  }

  @override
  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  @override
  Future<void> updateEmail({required String newEmail, String? currentPassword}) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No hay usuario autenticado');
    if (currentPassword != null && user.email != null) {
      final cred = fb.EmailAuthProvider.credential(email: user.email!, password: currentPassword);
      await user.reauthenticateWithCredential(cred);
    }
    await user.verifyBeforeUpdateEmail(newEmail);
    await user.reload();
  }

  @override
  Future<void> updatePassword({String? currentPassword, required String newPassword}) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No hay usuario autenticado');
    if (currentPassword != null && user.email != null) {
      final cred = fb.EmailAuthProvider.credential(email: user.email!, password: currentPassword);
      await user.reauthenticateWithCredential(cred);
    }
    await user.updatePassword(newPassword);
  }

  @override
  Future<void> linkEmailPassword({required String email, required String password}) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No hay usuario autenticado');
    final cred = fb.EmailAuthProvider.credential(email: email, password: password);
    try {
      await user.linkWithCredential(cred);
    } on fb.FirebaseAuthException catch (e) {
      if (e.code == 'provider-already-linked') {
        return; // already has email/password
      }
      rethrow;
    }
  }

  @override
  Future<bool> needsPasswordLink() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    final providers = user.providerData.map((p) => p.providerId).toSet();
    final hasPassword = providers.contains('password');
    final hasGoogle = providers.contains('google.com');
    return hasGoogle && !hasPassword;
  }
}
