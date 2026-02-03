import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/firebase_auth_repository.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/sign_in.dart';
import '../../domain/usecases/sign_in_anonymously.dart';
import '../../domain/usecases/sign_in_with_google.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/sign_up.dart';
import '../../domain/usecases/update_email.dart';
import '../../domain/usecases/update_password.dart';
import '../../domain/usecases/link_email_password.dart';
import '../../domain/usecases/delete_account.dart';
import '../../domain/usecases/send_password_reset.dart';
import '../../domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository();
});

final needsPasswordLinkProvider = FutureProvider<bool>((ref) async {
  final repo = ref.watch(authRepositoryProvider);
  return repo.needsPasswordLink();
});

final authChangesProvider = Provider<Stream<UserEntity?>>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return repo.authStateChanges();
});

final authStateProvider = StreamProvider<UserEntity?>((ref) {
  final stream = ref.watch(authChangesProvider);
  return stream;
});

final authControllerProvider = StateNotifierProvider<AuthController, AsyncValue<UserEntity?>>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthController(
    signIn: SignIn(repo),
    signInAnonymously: SignInAnonymously(repo),
    signInWithGoogle: SignInWithGoogle(repo),
    signUp: SignUp(repo),
    signOut: SignOut(repo),
    updateEmail: UpdateEmail(repo),
    updatePassword: UpdatePassword(repo),
    linkEmailPassword: LinkEmailPassword(repo),
    deleteAccount: DeleteAccount(repo),
    sendPasswordReset: SendPasswordReset(repo),
    repo: repo,
  );
});

class AuthController extends StateNotifier<AsyncValue<UserEntity?>> {
  AuthController({required this.signIn, required this.signInWithGoogle, required this.signInAnonymously, required this.signUp, required this.signOut, required this.updateEmail, required this.updatePassword, required this.linkEmailPassword, required this.deleteAccount, required this.sendPasswordReset, required this.repo})
      : super(const AsyncLoading()) {
    _init();
  }

  final SignIn signIn;
  final SignInAnonymously signInAnonymously;
  final SignInWithGoogle signInWithGoogle;
  final SignUp signUp;
  final SignOut signOut;
  final UpdateEmail updateEmail;
  final UpdatePassword updatePassword;
  final LinkEmailPassword linkEmailPassword;
  final DeleteAccount deleteAccount;
  final SendPasswordReset sendPasswordReset;
  final AuthRepository repo;

  Future<void> _init() async {
    final user = await repo.currentUser();
    state = AsyncData(user);
  }

  Future<void> doSignIn(String email, String password) async {
    state = const AsyncLoading();
    try {
      final user = await signIn(email, password);
      state = AsyncData(user);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> doGoogleSignIn() async {
    state = const AsyncLoading();
    try {
      final user = await signInWithGoogle();
      state = AsyncData(user);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> doGuestSignIn() async {
    state = const AsyncLoading();
    try {
      final user = await signInAnonymously();
      state = AsyncData(user);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> doSignUp(String email, String password, String name) async {
    state = const AsyncLoading();
    try {
      final user = await signUp(email, password, name);
      state = AsyncData(user);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> doSignOut() async {
    state = const AsyncLoading();
    try {
      await signOut();
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> doUpdateEmail(String newEmail, {String? currentPassword}) async {
    state = const AsyncLoading();
    try {
      await updateEmail(newEmail, currentPassword: currentPassword);
      final user = await repo.currentUser();
      state = AsyncData(user);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> doUpdatePassword({String? currentPassword, required String newPassword}) async {
    state = const AsyncLoading();
    try {
      await updatePassword(newPassword, currentPassword: currentPassword);
      final user = await repo.currentUser();
      state = AsyncData(user);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> doLinkEmailPassword({required String email, required String password}) async {
    state = const AsyncLoading();
    try {
      await linkEmailPassword(email, password);
      final user = await repo.currentUser();
      state = AsyncData(user);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> doDeleteAccount({String? currentPassword}) async {
    state = const AsyncLoading();
    try {
      await deleteAccount(currentPassword: currentPassword);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> doSendPasswordReset(String email) async {
    await sendPasswordReset(email);
  }
}
