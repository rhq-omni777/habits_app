import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/achievement_providers.dart';
import '../providers/auth_providers.dart';
import '../providers/habit_providers.dart';
import '../providers/progress_providers.dart';
import '../../domain/entities/habit_progress_entity.dart';
import '../../domain/entities/achievement_entity.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  Future<void> _changeEmail(BuildContext context, WidgetRef ref) async {
    final emailCtrl = TextEditingController(text: ref.read(authStateProvider).valueOrNull?.email ?? '');
    final passCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cambiar correo'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: emailCtrl,
                decoration: const InputDecoration(labelText: 'Nuevo correo'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) => v != null && v.contains('@') ? null : 'Correo inválido',
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: passCtrl,
                decoration: const InputDecoration(labelText: 'Contraseña actual (si aplica)'),
                obscureText: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) Navigator.pop(ctx, true);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    if (!context.mounted) return;
    if (result != true) return;
    await _runAuthAction(context, ref, () => ref.read(authControllerProvider.notifier).doUpdateEmail(emailCtrl.text.trim(), currentPassword: passCtrl.text.isEmpty ? null : passCtrl.text));
  }

  Future<void> _changePassword(BuildContext context, WidgetRef ref) async {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cambiar contraseña'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: currentCtrl,
                decoration: const InputDecoration(labelText: 'Contraseña actual (si aplica)'),
                obscureText: true,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: newCtrl,
                decoration: const InputDecoration(labelText: 'Nueva contraseña'),
                obscureText: true,
                validator: (v) => v != null && v.length >= 6 ? null : 'Mínimo 6 caracteres',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) Navigator.pop(ctx, true);
            },
            child: const Text('Actualizar'),
          ),
        ],
      ),
    );
    if (!context.mounted) return;
    if (result != true) return;
    await _runAuthAction(context, ref, () => ref.read(authControllerProvider.notifier).doUpdatePassword(currentPassword: currentCtrl.text.isEmpty ? null : currentCtrl.text, newPassword: newCtrl.text));
  }

  Future<void> _linkEmailPassword(BuildContext context, WidgetRef ref) async {
    final emailCtrl = TextEditingController(text: ref.read(authStateProvider).valueOrNull?.email ?? '');
    final passCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Crear contraseña para Google'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: emailCtrl,
                decoration: const InputDecoration(labelText: 'Correo'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) => v != null && v.contains('@') ? null : 'Correo inválido',
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: passCtrl,
                decoration: const InputDecoration(labelText: 'Nueva contraseña'),
                obscureText: true,
                validator: (v) => v != null && v.length >= 6 ? null : 'Mínimo 6 caracteres',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) Navigator.pop(ctx, true);
            },
            child: const Text('Vincular'),
          ),
        ],
      ),
    );
    if (!context.mounted) return;
    if (result != true) return;
    await _runAuthAction(context, ref, () => ref.read(authControllerProvider.notifier).doLinkEmailPassword(email: emailCtrl.text.trim(), password: passCtrl.text));
  }

  Future<void> _deleteAccount(BuildContext context, WidgetRef ref, {required bool requiresPassword}) async {
    final passCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar cuenta'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Se borrarán tus datos asociados a esta cuenta. Esta acción no se puede deshacer.'),
              if (requiresPassword) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: passCtrl,
                  decoration: const InputDecoration(labelText: 'Contraseña actual'),
                  obscureText: true,
                  validator: (v) => v != null && v.length >= 6 ? null : 'Ingresa la contraseña',
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () {
              if (!requiresPassword || (formKey.currentState?.validate() ?? false)) {
                Navigator.pop(ctx, true);
              }
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (!context.mounted || result != true) return;
    await _runAuthAction(context, ref, () => ref.read(authControllerProvider.notifier).doDeleteAccount(currentPassword: passCtrl.text.isEmpty ? null : passCtrl.text));
    if (context.mounted) {
      context.go('/login');
    }
  }

  Future<void> _runAuthAction(BuildContext context, WidgetRef ref, Future<void> Function() action) async {
    try {
      await action();
      ref.invalidate(needsPasswordLinkProvider);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cambios guardados')));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).valueOrNull;
    final achievements = ref.watch(achievementsProvider);
    final progress = ref.watch(progressProvider).value ?? [];
    final habits = ref.watch(habitsProvider).value ?? [];
    final needsLink = ref.watch(needsPasswordLinkProvider).maybeWhen(data: (v) => v, orElse: () => false);
    final isGuest = (user?.email.isEmpty ?? true);
    final showChangePassword = !isGuest && !needsLink;
    final requiresPasswordForDelete = showChangePassword;

    final maxStreak = _maxStreak(progress);
    final totalCompletions = progress.length;
    final activeHabits = habits.length;
    final level = _levelFromStreak(maxStreak);
    final frame = _frameFromStreak(maxStreak);

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeaderCard(
                name: user?.displayName ?? 'Invitado',
                email: user?.email ?? 'Sin correo',
                level: level,
                frame: frame,
              ),
              const SizedBox(height: 16),
              _StatsWrap(
                maxStreak: maxStreak,
                totalCompletions: totalCompletions,
                activeHabits: activeHabits,
              ),
              const SizedBox(height: 14),
              _SecurityActions(
                onChangeEmail: () => _changeEmail(context, ref),
                onChangePassword: showChangePassword ? () => _changePassword(context, ref) : null,
                onLinkPassword: needsLink && !isGuest ? () => _linkEmailPassword(context, ref) : null,
                showLinkPassword: needsLink && !isGuest,
                isGuest: isGuest,
                onCreateAccount: () => context.go('/register'),
                onDeleteAccount: () => _deleteAccount(context, ref, requiresPassword: requiresPasswordForDelete),
              ),
              const SizedBox(height: 20),
              Text('Logros', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              achievements.when(
                data: (items) => _AchievementsGrid(items: items, progressCount: progress.length),
                error: (e, _) => Text('Error: $e'),
                loading: () => const Center(child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: CircularProgressIndicator(),
                )),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await ref.read(authControllerProvider.notifier).doSignOut();
                        if (!context.mounted) return;
                        context.go('/login');
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text('Cerrar sesión'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => context.push('/legal'),
                      icon: const Icon(Icons.privacy_tip_outlined),
                      label: const Text('Privacidad y términos'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.name, required this.email, required this.level, required this.frame});

  final String name;
  final String email;
  final String level;
  final _FrameStyle frame;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final initial = name.isNotEmpty ? name.characters.first.toUpperCase() : 'U';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 18, offset: const Offset(0, 10)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: frame.colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 34,
              backgroundColor: scheme.surface,
              child: Text(initial, style: textTheme.headlineSmall?.copyWith(color: scheme.onSurface)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(email, style: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(frame.icon, size: 16, color: scheme.primary),
                      const SizedBox(width: 6),
                      Text(level, style: textTheme.labelMedium?.copyWith(color: scheme.primary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsWrap extends StatelessWidget {
  const _StatsWrap({required this.maxStreak, required this.totalCompletions, required this.activeHabits});

  final int maxStreak;
  final int totalCompletions;
  final int activeHabits;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return LayoutBuilder(builder: (context, constraints) {
      final isWide = constraints.maxWidth > 640;
      final itemWidth = isWide ? (constraints.maxWidth - 10) / 2 : constraints.maxWidth;
      return Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          _StatCard(width: itemWidth, label: 'Racha máxima', value: '$maxStreak días', icon: Icons.local_fire_department, color: scheme.primary),
          _StatCard(width: itemWidth, label: 'Completados', value: '$totalCompletions', icon: Icons.check_circle, color: scheme.secondary),
          _StatCard(width: itemWidth, label: 'Hábitos activos', value: '$activeHabits', icon: Icons.list_alt, color: scheme.tertiary),
        ],
      );
    });
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.icon, required this.color, required this.width});

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final double width;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: scheme.outline.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: textTheme.labelMedium?.copyWith(color: scheme.onSurfaceVariant)),
                  const SizedBox(height: 4),
                  Text(value, style: textTheme.titleMedium, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SecurityActions extends StatelessWidget {
  const _SecurityActions({required this.onChangeEmail, this.onChangePassword, this.onLinkPassword, required this.showLinkPassword, required this.isGuest, required this.onCreateAccount, required this.onDeleteAccount});

  final VoidCallback onChangeEmail;
  final VoidCallback? onChangePassword;
  final VoidCallback? onLinkPassword;
  final bool showLinkPassword;
  final bool isGuest;
  final VoidCallback onCreateAccount;
  final VoidCallback onDeleteAccount;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: scheme.outline.withValues(alpha: 0.1))),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lock_reset, color: scheme.primary),
                const SizedBox(width: 8),
                Text('Seguridad de la cuenta', style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: isGuest ? null : onChangeEmail,
                  icon: const Icon(Icons.alternate_email),
                  label: const Text('Cambiar correo'),
                ),
                if (onChangePassword != null)
                  OutlinedButton.icon(
                    onPressed: isGuest ? null : onChangePassword,
                    icon: const Icon(Icons.password),
                    label: const Text('Cambiar contraseña'),
                  ),
                if (showLinkPassword && onLinkPassword != null)
                  OutlinedButton.icon(
                    onPressed: onLinkPassword,
                    icon: const Icon(Icons.link),
                    label: const Text('Crear contraseña (Google)'),
                  ),
                if (isGuest)
                  FilledButton.icon(
                    onPressed: onCreateAccount,
                    icon: const Icon(Icons.person_add_alt),
                    label: const Text('Crear mi cuenta'),
                  ),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
                  onPressed: onDeleteAccount,
                  icon: const Icon(Icons.delete_forever),
                  label: const Text('Eliminar cuenta'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AchievementsGrid extends StatelessWidget {
  const _AchievementsGrid({required this.items, required this.progressCount});

  final List<AchievementEntity> items;
  final int progressCount;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isWide = constraints.maxWidth > 640;
      final itemWidth = isWide ? (constraints.maxWidth - 10) / 2 : constraints.maxWidth;
      return Wrap(
        spacing: 10,
        runSpacing: 10,
        children: items
            .map((a) => _AchievementCard(
                  width: itemWidth,
                  title: a.title,
                  description: a.description,
                  unlocked: a.unlocked,
                  progress: progressCount,
                  threshold: a.threshold,
                ))
            .toList(),
      );
    });
  }
}

class _AchievementCard extends StatelessWidget {
  const _AchievementCard({required this.title, required this.description, required this.unlocked, required this.progress, required this.threshold, required this.width});

  final String title;
  final String description;
  final bool unlocked;
  final int progress;
  final int threshold;
  final double width;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final clampedProgress = progress.clamp(0, threshold);
    final ratio = (clampedProgress / threshold).clamp(0, 1).toDouble();
    final color = unlocked ? scheme.primary : scheme.onSurfaceVariant.withValues(alpha: 0.5);
    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: unlocked ? scheme.primary.withValues(alpha: 0.08) : scheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: scheme.outline.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(unlocked ? Icons.emoji_events : Icons.lock_outline, color: color),
                const SizedBox(width: 8),
                Expanded(child: Text(title, style: textTheme.titleMedium?.copyWith(color: color), overflow: TextOverflow.ellipsis)),
              ],
            ),
            const SizedBox(height: 6),
            Text(description, style: textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(value: ratio, minHeight: 6, backgroundColor: scheme.outline.withValues(alpha: 0.2), valueColor: AlwaysStoppedAnimation(color)),
            ),
            const SizedBox(height: 6),
            Text('$clampedProgress / $threshold', style: textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

class _FrameStyle {
  const _FrameStyle({required this.colors, required this.icon, required this.label});
  final List<Color> colors;
  final IconData icon;
  final String label;
}

_FrameStyle _frameFromStreak(int streak) {
  if (streak >= 30) return const _FrameStyle(colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)], icon: Icons.bolt, label: 'Épico');
  if (streak >= 14) return const _FrameStyle(colors: [Color(0xFFd4af37), Color(0xFFf3e5ab)], icon: Icons.star, label: 'Oro');
  if (streak >= 7) return const _FrameStyle(colors: [Color(0xFFC0C0C0), Color(0xFFE0E0E0)], icon: Icons.star_half, label: 'Plata');
  if (streak >= 3) return const _FrameStyle(colors: [Color(0xFFcd7f32), Color(0xFFdca574)], icon: Icons.emoji_events, label: 'Bronce');
  return const _FrameStyle(colors: [Color(0xFF607D8B), Color(0xFF90A4AE)], icon: Icons.hourglass_bottom, label: 'Novato');
}

String _levelFromStreak(int streak) {
  if (streak >= 30) return 'Nivel Épico';
  if (streak >= 14) return 'Nivel Oro';
  if (streak >= 7) return 'Nivel Plata';
  if (streak >= 3) return 'Nivel Bronce';
  return 'Nivel Novato';
}

int _maxStreak(List<HabitProgressEntity> progress) {
  final byHabit = <String, Set<DateTime>>{};
  for (final p in progress) {
    if (p.completed) {
      byHabit.putIfAbsent(p.habitId, () => <DateTime>{}).add(_normalize(p.date));
    }
  }

  int max = 0;
  for (final dates in byHabit.values) {
    final sorted = dates.toList()..sort();
    int current = 0;
    DateTime? prev;
    for (final d in sorted) {
      if (prev != null && d.difference(prev).inDays == 1) {
        current += 1;
      } else {
        current = 1;
      }
      if (current > max) max = current;
      prev = d;
    }
  }
  return max;
}

DateTime _normalize(DateTime d) => DateTime.utc(d.year, d.month, d.day);
