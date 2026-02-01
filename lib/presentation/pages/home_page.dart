import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/habit_entity.dart';
import '../../domain/entities/habit_progress_entity.dart';
import '../providers/habit_providers.dart';
import '../providers/progress_providers.dart';

final expandedHabitsProvider = StateProvider<Set<String>>((_) => <String>{});

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsState = ref.watch(habitsProvider);
    final progressState = ref.watch(progressProvider);
    final expandedHabits = ref.watch(expandedHabitsProvider);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hábitos'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.menu_book_rounded),
            onPressed: () => context.push('/library'),
            tooltip: 'Biblioteca de hábitos',
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart_rounded),
            onPressed: () => context.push('/stats'),
            tooltip: 'Estadísticas',
          ),
          IconButton(
            icon: const Icon(Icons.person_rounded),
            onPressed: () => context.push('/profile'),
            tooltip: 'Perfil',
          ),
        ],
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [scheme.primary.withValues(alpha: 0.06), scheme.surface, scheme.secondary.withValues(alpha: 0.04)],
            begin: Alignment.topCenter,
            end: Alignment.bottomRight,
          ),
        ),
        child: habitsState.when(
          data: (habits) {
            final progress = progressState.value ?? [];
            final todayTotal = habits.length;
            final todayDone = habits.where((h) => _completedToday(h.id, progress)).length;

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
              children: [
                Text('Tu progreso de hoy', style: textTheme.headlineSmall),
                const SizedBox(height: 6),
                Text(
                  'Marca tus hábitos diarios y mantén la racha activa.',
                  style: textTheme.bodyMedium?.copyWith(color: scheme.onSurface.withValues(alpha: 0.7)),
                ),
                const SizedBox(height: 12),
                _GuidanceBanner(),
                const SizedBox(height: 18),
                Row(
                  children: [
                    _StatChip(
                      icon: Icons.check_circle_rounded,
                      label: 'Completados',
                      value: '$todayDone',
                      color: scheme.primary,
                    ),
                    const SizedBox(width: 12),
                    _StatChip(
                      icon: Icons.schedule_rounded,
                      label: 'Pendientes',
                      value: '${(todayTotal - todayDone).clamp(0, 999)}',
                      color: scheme.secondary,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (habits.isEmpty)
                  _EmptyState(onCreate: () => context.push('/habit/new'))
                else
                  ...List.generate(habits.length, (index) {
                    final habit = habits[index];
                    final streak = ref.read(progressProvider.notifier).streakForHabit(habit.id);
                    final completedToday = _completedToday(habit.id, progress);
                    final reminderLabel = _formatTime(habit.reminderMinutes);
                    final habitIcon = _iconForHabit(habit);
                    final expanded = expandedHabits.contains(habit.id);
                    return Padding(
                      padding: EdgeInsets.only(bottom: index == habits.length - 1 ? 0 : 12),
                      child: _HabitCard(
                        habit: habit,
                        streak: streak,
                        completedToday: completedToday,
                        reminderLabel: reminderLabel,
                        habitIcon: habitIcon,
                        expanded: expanded,
                        onToggle: () => ref.read(progressProvider.notifier).toggleToday(habit.id),
                        onEdit: () => _openEdit(context, habit),
                        onEditTime: () => _editReminderTime(context, ref, habit),
                        onToggleExpand: () => _toggleExpand(ref, habit.id),
                        onDelete: () => _confirmDelete(context, ref, habit),
                      ),
                    );
                  }),
              ],
            );
          },
          error: (err, _) => Center(child: Text('Error: $err')),
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/habit/new'),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo hábito'),
      ),
    );
  }

  bool _completedToday(String habitId, List<HabitProgressEntity> progress) {
    final today = DateTime.now().toUtc();
    final normalized = DateTime.utc(today.year, today.month, today.day);
    return progress.any((p) => p.habitId == habitId && p.date == normalized && p.completed);
  }

  String _formatTime(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}' ;
  }

  IconData _iconForHabit(HabitEntity habit) => IconData(
        habit.iconCodePoint,
        fontFamily: habit.iconFontFamily,
        fontPackage: habit.iconFontPackage,
      );

  void _toggleExpand(WidgetRef ref, String habitId) {
    ref.read(expandedHabitsProvider.notifier).update((state) {
      final next = {...state};
      if (next.contains(habitId)) {
        next.remove(habitId);
      } else {
        next.add(habitId);
      }
      return next;
    });
  }

  Future<void> _openEdit(BuildContext context, HabitEntity habit) async {
    final result = await context.push('/habit/edit', extra: habit);
    if (context.mounted && result == true) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hábito actualizado: ${habit.title}')));
    }
  }

  Future<void> _editReminderTime(BuildContext context, WidgetRef ref, HabitEntity habit) async {
    final initial = TimeOfDay(hour: habit.reminderMinutes ~/ 60, minute: habit.reminderMinutes % 60);
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null) return;
    final updated = HabitEntity(
      id: habit.id,
      title: habit.title,
      description: habit.description,
      frequency: habit.frequency,
      weekDays: habit.weekDays,
      reminderMinutes: picked.hour * 60 + picked.minute,
      notificationsEnabled: habit.notificationsEnabled,
      createdAt: habit.createdAt,
      iconCodePoint: habit.iconCodePoint,
      iconFontFamily: habit.iconFontFamily,
      iconFontPackage: habit.iconFontPackage,
    );
    await ref.read(habitsProvider.notifier).editHabit(updated);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hora actualizada a ${_formatTime(updated.reminderMinutes)}')));
    }
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, HabitEntity habit) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar hábito'),
        content: Text('¿Seguro que deseas eliminar "${habit.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Eliminar')),
        ],
      ),
    );
    if (result == true) {
      await ref.read(habitsProvider.notifier).removeHabit(habit.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hábito eliminado: ${habit.title}')));
      }
    }
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.icon, required this.label, required this.value, required this.color});

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: scheme.outline.withValues(alpha: 0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: scheme.onSurfaceVariant)),
                const SizedBox(height: 4),
                Text(value, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HabitCard extends StatelessWidget {
  const _HabitCard({
    required this.habit,
    required this.streak,
    required this.completedToday,
    required this.reminderLabel,
    required this.habitIcon,
    required this.expanded,
    required this.onToggle,
    required this.onEdit,
    required this.onEditTime,
    required this.onToggleExpand,
    required this.onDelete,
  });

  final HabitEntity habit;
  final int streak;
  final bool completedToday;
  final String reminderLabel;
  final IconData habitIcon;
  final bool expanded;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onEditTime;
  final VoidCallback onToggleExpand;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: onToggleExpand,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: scheme.outline.withValues(alpha: 0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [scheme.primary.withValues(alpha: 0.18), scheme.secondary.withValues(alpha: 0.12)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    habitIcon,
                    color: completedToday ? scheme.primary : scheme.onSurfaceVariant,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(habit.title, style: textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(
                        habit.description,
                        style: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                        maxLines: expanded ? null : 2,
                        overflow: expanded ? TextOverflow.visible : TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 160),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: onEditTime,
                        child: _Pill(label: 'Hora $reminderLabel', icon: Icons.schedule_rounded),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: onEdit,
                            tooltip: 'Editar',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded),
                            onPressed: onDelete,
                            tooltip: 'Eliminar',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _Pill(label: 'Racha $streak', icon: Icons.local_fire_department_rounded),
                _Pill(label: completedToday ? 'Completado' : 'Pendiente', icon: Icons.today_rounded),
                TextButton.icon(
                  onPressed: onToggle,
                  icon: Icon(completedToday ? Icons.undo_rounded : Icons.check_rounded),
                  label: Text(completedToday ? 'Desmarcar' : 'Marcar hoy'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: scheme.primary),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.auto_awesome_rounded, color: scheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Crea tu primer hábito',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Elige una meta simple, define la frecuencia y empieza hoy mismo.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: onCreate,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Crear hábito'),
          ),
        ],
      ),
    );
  }
}

class _GuidanceBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: scheme.primary.withValues(alpha: 0.18), shape: BoxShape.circle),
            child: Icon(Icons.rocket_launch_rounded, color: scheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Micro-acciones', style: textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  'Usa recordatorios suaves, mantén tareas simples y marca al terminar. Las rachas y logros refuerzan tu motivación.',
                  style: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => GoRouter.of(context).push('/stats'),
            child: const Text('Ver avance'),
          ),
        ],
      ),
    );
  }
}
