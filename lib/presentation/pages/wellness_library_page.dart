import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/habit_entity.dart';
import '../providers/habit_providers.dart';

class WellnessLibraryPage extends ConsumerWidget {
  const WellnessLibraryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templates = _templates;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Biblioteca de hábitos saludables')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          Text(
            'Inspírate con micro-acciones basadas en hidratación, movimiento y descanso. Usa los atajos para crear hábitos rápidos y reforzar tus rutinas.',
            style: textTheme.bodyMedium?.copyWith(color: scheme.onSurface.withValues(alpha: 0.75)),
          ),
          const SizedBox(height: 16),
          ...templates.map((t) => _TemplateCard(template: t, onAdd: () => _createFromTemplate(context, ref, t))),
          const SizedBox(height: 12),
          _TipBanner(
            title: 'Recuerda el modelo B=MAP',
            body: 'Baja la fricción: mantén hábitos simples, con horarios claros y recordatorios suaves. Celebra pequeñas victorias para sostener la motivación.',
          ),
        ],
      ),
    );
  }

  void _createFromTemplate(BuildContext context, WidgetRef ref, _HabitTemplate t) {
    final habit = HabitEntity(
      id: const Uuid().v4(),
      title: t.title,
      description: t.description,
      frequency: t.frequency,
      weekDays: t.frequency == HabitFrequency.weekly ? t.weekDays : const [],
      reminderMinutes: t.reminderMinutes,
      notificationsEnabled: true,
      createdAt: DateTime.now(),
      iconCodePoint: t.icon.codePoint,
      iconFontFamily: t.icon.fontFamily ?? 'MaterialIcons',
      iconFontPackage: t.icon.fontPackage,
    );
    ref.read(habitsProvider.notifier).createHabit(habit);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hábito agregado: ${t.title}')));
  }
}

class _TemplateCard extends StatelessWidget {
  const _TemplateCard({required this.template, required this.onAdd});

  final _HabitTemplate template;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(template.icon, color: scheme.primary),
                const SizedBox(width: 10),
                Expanded(child: Text(template.title, style: textTheme.titleMedium)),
                FilledButton.icon(onPressed: onAdd, icon: const Icon(Icons.add_rounded), label: const Text('Agregar')),
              ],
            ),
            const SizedBox(height: 8),
            Text(template.description, style: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _Pill(label: template.frequency == HabitFrequency.daily ? 'Diario' : 'Semanal'),
                _Pill(label: template.timeLabel),
                if (template.frequency == HabitFrequency.weekly && template.weekDays.isNotEmpty)
                  _Pill(label: 'Días: ${template.weekDays.map((d) => _dayShort(d)).join(', ')}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _dayShort(int day) {
    const labels = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
    return labels[(day - 1).clamp(0, 6)];
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: scheme.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
      child: Text(label, style: Theme.of(context).textTheme.labelMedium),
    );
  }
}

class _TipBanner extends StatelessWidget {
  const _TipBanner({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: scheme.tertiary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: scheme.outline.withValues(alpha: 0.2)),
            ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: scheme.tertiary.withValues(alpha: 0.18), shape: BoxShape.circle),
            child: Icon(Icons.lightbulb, color: scheme.tertiary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(body, style: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HabitTemplate {
  const _HabitTemplate({
    required this.title,
    required this.description,
    required this.icon,
    required this.frequency,
    required this.reminderMinutes,
    this.weekDays = const [],
  });

  final String title;
  final String description;
  final IconData icon;
  final HabitFrequency frequency;
  final int reminderMinutes;
  final List<int> weekDays;

  String get timeLabel {
    final hours = reminderMinutes ~/ 60;
    final minutes = reminderMinutes % 60;
    return 'Hora: ${_two(hours)}:${_two(minutes)}';
  }
}

String _two(int value) => value.toString().padLeft(2, '0');

const List<_HabitTemplate> _templates = [
  _HabitTemplate(
    title: 'Hidratación 8 vasos',
    description: 'Beber un vaso de agua cada hora activa durante la jornada. Refuerza energía y enfoque.',
    icon: Icons.water_drop,
    frequency: HabitFrequency.daily,
    reminderMinutes: 9 * 60,
  ),
  _HabitTemplate(
    title: 'Caminata 30 minutos',
    description: 'Actividad física moderada para reducir sedentarismo. Ideal después de clases o trabajo.',
    icon: Icons.directions_walk,
    frequency: HabitFrequency.daily,
    reminderMinutes: 18 * 60 + 30,
  ),
  _HabitTemplate(
    title: 'Higiene del sueño (8h)',
    description: 'Preparar rutina de descanso: sin pantallas 30 minutos antes y hora fija de dormir.',
    icon: Icons.bedtime,
    frequency: HabitFrequency.daily,
    reminderMinutes: 22 * 60,
  ),
  _HabitTemplate(
    title: 'Estiramientos semanales',
    description: 'Sesión corta de movilidad 3 veces por semana para reducir tensión muscular.',
    icon: Icons.self_improvement,
    frequency: HabitFrequency.weekly,
    weekDays: [1, 3, 5],
    reminderMinutes: 7 * 60 + 30,
  ),
  _HabitTemplate(
    title: 'Respiración 4-7-8',
    description: 'Ciclo breve para bajar estrés: 4s inhalar, 7s sostener, 8s exhalar. Repite 3 veces.',
    icon: Icons.self_improvement_rounded,
    frequency: HabitFrequency.daily,
    reminderMinutes: 12 * 60,
  ),
  _HabitTemplate(
    title: 'Fruta al día',
    description: 'Incluye una porción de fruta entera en la mañana para sumar fibra y micronutrientes.',
    icon: Icons.apple,
    frequency: HabitFrequency.daily,
    reminderMinutes: 8 * 60 + 30,
  ),
  _HabitTemplate(
    title: 'Bloque de enfoque 25m',
    description: 'Sesión de concentración tipo pomodoro. Sin notificaciones, con pausa breve al terminar.',
    icon: Icons.timelapse,
    frequency: HabitFrequency.daily,
    reminderMinutes: 10 * 60,
  ),
  _HabitTemplate(
    title: 'Diario de gratitud',
    description: 'Anota 3 cosas buenas del día para reforzar atención positiva y motivación.',
    icon: Icons.auto_awesome,
    frequency: HabitFrequency.daily,
    reminderMinutes: 21 * 60 + 30,
  ),
  _HabitTemplate(
    title: 'Pausa de movilidad',
    description: 'Cada tarde, 5-7 minutos de movilidad de cuello, hombros y cadera para romper sedentarismo.',
    icon: Icons.fitness_center,
    frequency: HabitFrequency.daily,
    reminderMinutes: 16 * 60,
  ),
  _HabitTemplate(
    title: 'Planificar mañana',
    description: 'Revisa calendario y define 3 prioridades para el día siguiente.',
    icon: Icons.event_note,
    frequency: HabitFrequency.daily,
    reminderMinutes: 20 * 60 + 30,
  ),
  _HabitTemplate(
    title: 'Sin azúcar añadida',
    description: 'Elige una comida del día sin bebidas azucaradas ni postres procesados.',
    icon: Icons.no_food,
    frequency: HabitFrequency.daily,
    reminderMinutes: 13 * 60,
  ),
  _HabitTemplate(
    title: 'Pasos 8k',
    description: 'Camina hasta 8,000 pasos. Divide en bloques (mañana y tarde) para hacerlo alcanzable.',
    icon: Icons.directions_run,
    frequency: HabitFrequency.daily,
    reminderMinutes: 17 * 60,
  ),
  _HabitTemplate(
    title: 'Lectura 10 minutos',
    description: 'Lee algo fuera de pantalla (o modo noche) para bajar el uso de redes antes de dormir.',
    icon: Icons.menu_book_rounded,
    frequency: HabitFrequency.daily,
    reminderMinutes: 21 * 60,
  ),
  _HabitTemplate(
    title: 'Contacto social',
    description: 'Envía un mensaje o llamada breve a alguien importante. Nutre tu red de apoyo.',
    icon: Icons.connect_without_contact,
    frequency: HabitFrequency.daily,
    reminderMinutes: 19 * 60,
  ),
  _HabitTemplate(
    title: 'Proteína en desayuno',
    description: 'Incluye una fuente de proteína (huevo, yogurt griego, legumbre) para mayor saciedad.',
    icon: Icons.egg_alt,
    frequency: HabitFrequency.daily,
    reminderMinutes: 7 * 60 + 30,
  ),
  _HabitTemplate(
    title: 'Revisión semanal',
    description: 'Domingo: revisar hábitos, logros y ajustar horarios para la siguiente semana.',
    icon: Icons.insights,
    frequency: HabitFrequency.weekly,
    weekDays: [7],
    reminderMinutes: 19 * 60,
  ),
];
