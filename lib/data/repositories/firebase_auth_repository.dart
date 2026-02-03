import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/errors/auth_failure.dart';
import '../../domain/repositories/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<T> _runAuth<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on AuthFailure catch (e) {
      throw e;
    } on fb.FirebaseAuthException catch (e) {
      throw _mapAuthError(e);
    } on Exception catch (e) {
      throw AuthFailure(code: 'unknown', message: e.toString());
    }
  }

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
    return _runAuth(() async {
      final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return _mapUser(cred.user)!;
    });
  }

  @override
  Future<UserEntity> signInWithGoogle() async {
    return _runAuth(() async {
      final googleUser = await _googleSignIn.signInSilently() ?? await _googleSignIn.signIn();
      if (googleUser == null) {
        throw const AuthFailure(code: 'cancelled', message: 'Inicio con Google cancelado');
      }
      final googleAuth = await googleUser.authentication;
      final credential = fb.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final cred = await _auth.signInWithCredential(credential);
      return _mapUser(cred.user)!;
    });
  }

  @override
  Future<UserEntity> signInAnonymously() async {
    return _runAuth(() async {
      final cred = await _auth.signInAnonymously();
      final user = cred.user;
      if (user != null && (user.displayName == null || user.displayName!.isEmpty)) {
        await user.updateDisplayName('Invitado');
      }
      return _mapUser(cred.user)!;
    });
  }

  @override
  Future<UserEntity> signUp(String email, String password, String name) async {
    return _runAuth(() async {
      final current = _auth.currentUser;
      if (current != null && current.isAnonymous) {
        final cred = fb.EmailAuthProvider.credential(email: email, password: password);
        final linked = await current.linkWithCredential(cred);
        await linked.user?.updateDisplayName(name);
        await linked.user?.reload();
        return _mapUser(linked.user ?? _auth.currentUser)!;
      }

      final created = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      await created.user?.updateDisplayName(name);
      return _mapUser(created.user)!;
    });
  }

  @override
  Future<void> signOut() async {
    await _runAuth(() async {
      await _auth.signOut();
      await _googleSignIn.signOut();
      try {
        await _googleSignIn.disconnect();
      } catch (_) {
        // Best-effort; algunos proveedores no permiten disconnect en todas las plataformas.
      }
    });
  }

  @override
  Future<void> updateEmail({required String newEmail, String? currentPassword}) async {
    await _runAuth(() async {
      final user = _auth.currentUser;
      if (user == null) {
        throw const AuthFailure(code: 'no-user', message: 'No hay usuario autenticado');
      }
      if (currentPassword != null && user.email != null) {
        final cred = fb.EmailAuthProvider.credential(email: user.email!, password: currentPassword);
        await user.reauthenticateWithCredential(cred);
      }
      await user.verifyBeforeUpdateEmail(newEmail);
      await user.reload();
    });
  }

  @override
  Future<void> updatePassword({String? currentPassword, required String newPassword}) async {
    await _runAuth(() async {
      final user = _auth.currentUser;
      if (user == null) {
        throw const AuthFailure(code: 'no-user', message: 'No hay usuario autenticado');
      }

      final providers = user.providerData.map((p) => p.providerId).toSet();
      final hasPasswordProvider = providers.contains('password');
      if (!hasPasswordProvider) {
        throw const AuthFailure(code: 'password-not-linked', message: 'Agrega una contraseña primero');
      }
      if (currentPassword == null || currentPassword.isEmpty || user.email == null) {
        throw const AuthFailure(code: 'missing-current-password', message: 'Ingresa tu contraseña actual');
      }

      final cred = fb.EmailAuthProvider.credential(email: user.email!, password: currentPassword);
      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(newPassword);
      await user.reload();
    });
  }

  @override
  Future<void> linkEmailPassword({required String email, required String password}) async {
    await _runAuth(() async {
      final user = _auth.currentUser;
      if (user == null) {
        throw const AuthFailure(code: 'no-user', message: 'No hay usuario autenticado');
      }
      final cred = fb.EmailAuthProvider.credential(email: email, password: password);
      try {
        await user.linkWithCredential(cred);
        await user.reload();
      } on fb.FirebaseAuthException catch (e) {
        if (e.code == 'provider-already-linked') {
          return;
        }
        throw _mapAuthError(e);
      }
    });
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    await _runAuth(() async {
      await _auth.sendPasswordResetEmail(email: email);
    });
  }

  @override
  Future<bool> needsPasswordLink() async {
    return _runAuth(() async {
      final user = _auth.currentUser;
      if (user == null) return false;
      await user.reload();
      final refreshed = _auth.currentUser ?? user;
      final providers = refreshed.providerData.map((p) => p.providerId).toSet();
      final hasPassword = providers.contains('password');
      final hasGoogle = providers.contains('google.com');
      return hasGoogle && !hasPassword;
    });
  }

  @override
  Future<void> deleteAccount({String? currentPassword}) async {
    await _runAuth(() async {
      final user = _auth.currentUser;
      if (user == null) {
        throw const AuthFailure(code: 'no-user', message: 'No hay usuario autenticado');
      }
      if (currentPassword != null && user.email != null) {
        final cred = fb.EmailAuthProvider.credential(email: user.email!, password: currentPassword);
        await user.reauthenticateWithCredential(cred);
      }
      await user.delete();
      await _googleSignIn.signOut();
      try {
        await _googleSignIn.disconnect();
      } catch (_) {
        // Best-effort; algunos proveedores no permiten disconnect en todas las plataformas.
      }
    });
  }

  AuthFailure _mapAuthError(fb.FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return const AuthFailure(code: 'invalid-email', message: 'Correo inválido');
      case 'user-disabled':
        return const AuthFailure(code: 'user-disabled', message: 'La cuenta está deshabilitada');
      case 'user-not-found':
        return const AuthFailure(code: 'user-not-found', message: 'Usuario no encontrado');
      case 'wrong-password':
        return const AuthFailure(code: 'wrong-password', message: 'Contraseña incorrecta');
      case 'too-many-requests':
        return const AuthFailure(code: 'too-many-requests', message: 'Demasiados intentos, inténtalo más tarde');
      case 'network-request-failed':
        return const AuthFailure(code: 'network', message: 'Sin conexión. Verifica tu red');
      case 'requires-recent-login':
        return const AuthFailure(code: 'requires-recent-login', message: 'Vuelve a iniciar sesión para continuar');
      case 'account-exists-with-different-credential':
        return const AuthFailure(code: 'account-exists-with-different-credential', message: 'La cuenta ya existe con otro proveedor');
      case 'credential-already-in-use':
        return const AuthFailure(code: 'credential-already-in-use', message: 'El correo ya está en uso');
      default:
        return AuthFailure(code: e.code, message: e.message ?? 'Error de autenticación');
    }
  }
}
