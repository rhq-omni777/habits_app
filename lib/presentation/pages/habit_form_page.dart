import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/habit_entity.dart';
import '../providers/habit_providers.dart';

class HabitFormPage extends ConsumerStatefulWidget {
  const HabitFormPage({super.key, this.habit});

  final HabitEntity? habit;

  @override
  ConsumerState<HabitFormPage> createState() => _HabitFormPageState();
}

class _HabitFormPageState extends ConsumerState<HabitFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  HabitFrequency _frequency = HabitFrequency.daily;
  final Set<int> _weekDays = {1, 2, 3, 4, 5};
  TimeOfDay _time = const TimeOfDay(hour: 8, minute: 0);
  bool _notifications = true;
  IconData _icon = Icons.flag_rounded;

  @override
  void initState() {
    super.initState();
    final existing = widget.habit;
    if (existing != null) {
      _title.text = existing.title;
      _description.text = existing.description;
      _frequency = existing.frequency;
      _weekDays
        ..clear()
        ..addAll(existing.weekDays);
      _time = TimeOfDay(hour: existing.reminderMinutes ~/ 60, minute: existing.reminderMinutes % 60);
      _notifications = existing.notificationsEnabled;
      _icon = IconData(existing.iconCodePoint, fontFamily: existing.iconFontFamily, fontPackage: existing.iconFontPackage);
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.habit == null ? 'Nuevo hábito' : 'Editar hábito')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _title,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (v) => v != null && v.isNotEmpty ? null : 'Requerido',
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _description,
                decoration: const InputDecoration(labelText: 'Descripción'),
                minLines: 1,
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              Text('Icono', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _iconOptions.map((option) {
                  final selected = option == _icon;
                  return ChoiceChip(
                    label: Icon(option),
                    selected: selected,
                    onSelected: (_) => setState(() => _icon = option),
                    selectedColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.16),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<HabitFrequency>(
                initialValue: _frequency,
                decoration: const InputDecoration(labelText: 'Frecuencia'),
                items: const [
                  DropdownMenuItem(value: HabitFrequency.daily, child: Text('Diaria')),
                  DropdownMenuItem(value: HabitFrequency.weekly, child: Text('Semanal')),
                ],
                onChanged: (value) {
                  setState(() => _frequency = value ?? HabitFrequency.daily);
                },
              ),
              if (_frequency == HabitFrequency.weekly) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: List.generate(7, (index) {
                    final day = index + 1;
                    final selected = _weekDays.contains(day);
                    return FilterChip(
                      label: Text(_dayLabel(day)),
                      selected: selected,
                      onSelected: (v) {
                        setState(() {
                          if (v) {
                            _weekDays.add(day);
                          } else {
                            _weekDays.remove(day);
                          }
                        });
                      },
                    );
                  }),
                ),
              ],
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Recordatorio'),
                subtitle: Text(_time.format(context)),
                trailing: IconButton(
                  icon: const Icon(Icons.schedule),
                  onPressed: () async {
                    final picked = await showTimePicker(context: context, initialTime: _time);
                    if (picked != null) setState(() => _time = picked);
                  },
                ),
              ),
              SwitchListTile(
                value: _notifications,
                title: const Text('Activar notificaciones'),
                onChanged: (v) => setState(() => _notifications = v),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    final now = DateTime.now();
                    final existing = widget.habit;
                    final habit = HabitEntity(
                      id: existing?.id ?? const Uuid().v4(),
                      title: _title.text.trim(),
                      description: _description.text.trim(),
                      frequency: _frequency,
                      weekDays: _frequency == HabitFrequency.weekly ? _weekDays.toList() : const [],
                      reminderMinutes: _time.hour * 60 + _time.minute,
                      notificationsEnabled: _notifications,
                      createdAt: existing?.createdAt ?? now,
                      iconCodePoint: _icon.codePoint,
                      iconFontFamily: _icon.fontFamily ?? 'MaterialIcons',
                      iconFontPackage: _icon.fontPackage,
                    );

                    final notifier = ref.read(habitsProvider.notifier);
                    final future = existing == null ? notifier.createHabit(habit) : notifier.editHabit(habit);
                    await future;
                    if (!context.mounted) return;
                    Navigator.of(context).pop(true);
                  }
                },
                child: Text(widget.habit == null ? 'Guardar' : 'Actualizar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _dayLabel(int day) {
    const labels = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
    return labels[day - 1];
  }
}

const List<IconData> _iconOptions = [
  Icons.flag_rounded,
  Icons.water_drop,
  Icons.directions_walk,
  Icons.bedtime,
  Icons.self_improvement,
  Icons.local_fire_department,
  Icons.favorite,
  Icons.fitness_center,
  Icons.emoji_nature,
  Icons.menu_book,
  Icons.accessibility_new,
  Icons.eco,
  Icons.stars,
  Icons.spa,
  Icons.rocket_launch,
];
