import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_providers.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
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
            colors: [scheme.primary.withValues(alpha: 0.12), scheme.surface, scheme.secondary.withValues(alpha: 0.08)],
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
                    Text('Crear cuenta', style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 8),
                    Text(
                      'Únete y consolida tus hábitos saludables con una experiencia más cuidada.',
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
                                controller: _name,
                                decoration: const InputDecoration(labelText: 'Nombre'),
                                textInputAction: TextInputAction.next,
                                validator: (v) => v != null && v.isNotEmpty ? null : 'Requerido',
                              ),
                              const SizedBox(height: 14),
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
                                autofillHints: const [AutofillHints.newPassword],
                                validator: (v) => v != null && v.length >= 6 ? null : 'Mínimo 6 caracteres',
                                onFieldSubmitted: (_) => _submit(authState),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: authState.isLoading ? null : () => _submit(authState),
                                child: authState.isLoading
                                    ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                                    : const Text('Crear cuenta'),
                              ),
                              const SizedBox(height: 8),
                              OutlinedButton.icon(
                                onPressed:
                                    authState.isLoading ? null : () => ref.read(authControllerProvider.notifier).doGoogleSignIn(),
                                icon: const Icon(Icons.login),
                                label: const Text('Continuar con Google'),
                              ),
                              TextButton(
                                onPressed: () => context.go('/login'),
                                child: const Text('Ya tengo cuenta'),
                              ),
                              if (authState.hasError)
                                Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: Text(
                                    'Error: ${authState.error}',
                                    style: TextStyle(color: scheme.error),
                                  ),
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

  void _submit(AsyncValue authState) {
    if (_formKey.currentState?.validate() ?? false) {
      ref.read(authControllerProvider.notifier).doSignUp(
            _email.text.trim(),
            _password.text.trim(),
            _name.text.trim(),
          );
    }
  }
}
