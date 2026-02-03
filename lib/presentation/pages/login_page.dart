import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/errors/auth_failure.dart';
import '../providers/auth_providers.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _sendingReset = false;

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      ref.read(authControllerProvider.notifier).doSignIn(_email.text.trim(), _password.text.trim());
    }
  }

  Future<void> _forgotPassword() async {
    final emailCtrl = TextEditingController(text: _email.text.trim());
    final formKey = GlobalKey<FormState>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restablecer contraseña'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: emailCtrl,
            decoration: const InputDecoration(labelText: 'Correo'),
            keyboardType: TextInputType.emailAddress,
            validator: (v) => v != null && v.contains('@') ? null : 'Correo inválido',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) Navigator.pop(ctx, true);
            },
            child: const Text('Enviar enlace'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _sendingReset = true);
    try {
      await ref.read(authControllerProvider.notifier).doSendPasswordReset(emailCtrl.text.trim());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Si el correo existe, enviamos un enlace para restablecer')));
    } catch (e) {
      if (!mounted) return;
      final msg = _friendlyAuthMessage(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } finally {
      if (mounted) setState(() => _sendingReset = false);
    }
  }

  String _friendlyAuthMessage(dynamic e) {
    if (e is AuthFailure) {
      switch (e.code) {
        case 'invalid-email':
          return 'Correo inválido';
        case 'user-not-found':
          return 'Si el correo existe, recibirás un enlace';
        case 'network':
          return 'Sin conexión. Intenta de nuevo';
        case 'wrong-password':
          return 'Contraseña incorrecta';
        default:
          return e.message;
      }
    }
    return 'Error: $e';
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    ref.listen(authControllerProvider, (_, next) {
      final user = next.valueOrNull;
      if (user != null) context.go('/home');
    });

    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [scheme.primary.withValues(alpha: 0.12), scheme.surface, scheme.secondary.withValues(alpha: 0.06)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),
                    Text('Bienvenido de vuelta', style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 8),
                    Text(
                      'Continúa tu progreso saludable con una experiencia más cuidada.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSurface.withValues(alpha: 0.7)),
                    ),
                    const SizedBox(height: 24),
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TextFormField(
                                controller: _email,
                                decoration: const InputDecoration(labelText: 'Correo'),
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [AutofillHints.username, AutofillHints.email],
                                validator: (v) => v != null && v.contains('@') ? null : 'Correo inválido',
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _password,
                                decoration: const InputDecoration(labelText: 'Contraseña'),
                                obscureText: true,
                                textInputAction: TextInputAction.done,
                                autofillHints: const [AutofillHints.password],
                                onFieldSubmitted: (_) => _submit(),
                                validator: (v) => v != null && v.length >= 6 ? null : 'Mínimo 6 caracteres',
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: authState.isLoading || _sendingReset ? null : _forgotPassword,
                                  child: const Text('Olvidé mi contraseña'),
                                ),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: authState.isLoading ? null : _submit,
                                child: authState.isLoading
                                    ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                                    : const Text('Entrar'),
                              ),
                              const SizedBox(height: 8),
                              OutlinedButton.icon(
                                onPressed: authState.isLoading ? null : () => ref.read(authControllerProvider.notifier).doGoogleSignIn(),
                                icon: const Icon(Icons.login),
                                label: const Text('Continuar con Google'),
                              ),
                              const SizedBox(height: 8),
                              OutlinedButton.icon(
                                onPressed: authState.isLoading ? null : () => ref.read(authControllerProvider.notifier).doGuestSignIn(),
                                icon: const Icon(Icons.person_outline),
                                label: const Text('Entrar como invitado'),
                              ),
                              TextButton(
                                onPressed: () => context.go('/register'),
                                child: const Text('Crear cuenta'),
                              ),
                              if (authState.hasError)
                                Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: Text(
                                    _friendlyAuthMessage(authState.error),
                                    style: TextStyle(color: scheme.error),
                                  ),
                                ),
                              if (_sendingReset)
                                const Padding(
                                  padding: EdgeInsets.only(top: 8),
                                  child: LinearProgressIndicator(minHeight: 2),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
