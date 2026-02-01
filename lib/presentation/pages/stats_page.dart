import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/habit_progress_entity.dart';
import '../../domain/entities/habit_entity.dart';
import '../providers/habit_providers.dart';
import '../providers/progress_providers.dart';

final selectedDayIndexProvider = StateProvider<int?>((_) => null);

class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = (ref.watch(progressProvider).value ?? []).map(_normalize).toList();
    final habits = ref.watch(habitsProvider).value ?? [];
    final habitMap = {for (final h in habits) h.id: h};
    final selectedDayIndex = ref.watch(selectedDayIndexProvider);
    final now = DateTime.now().toUtc();
    final days = List.generate(7, (i) => DateTime.utc(now.year, now.month, now.day).subtract(Duration(days: 6 - i)));
    final counts = _lastSevenDaysCounts(progress, days);
    final todayCompleted = counts.last;
    final weeklyCompleted = counts.reduce((a, b) => a + b);
    final completionToday = habits.isEmpty ? 0.0 : todayCompleted / habits.length;
    final completionWeek = habits.isEmpty ? 0.0 : weeklyCompleted / (habits.length * 7);

    return Scaffold(
      appBar: AppBar(title: const Text('Estadísticas')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Cumplimiento semanal', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Row(
              children: [
                _SummaryChip(label: 'Completados (7d)', value: '$weeklyCompleted'),
                const SizedBox(width: 8),
                _SummaryChip(label: 'Hábitos activos', value: '${habits.length}'),
                const Spacer(),
                _SummaryChip(label: 'Hoy', value: '$todayCompleted'),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchCallback: (event, response) {
                      if (!event.isInterestedForInteractions || response?.spot == null) return;
                      final index = response!.spot!.touchedBarGroupIndex;
                      ref.read(selectedDayIndexProvider.notifier).state = index;
                    },
                  ),
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const labels = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
                          final index = value.toInt();
                          return Text(labels[index % 7]);
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(7, (i) {
                    return BarChartGroupData(
                      x: i,
                      barRods: [BarChartRodData(toY: counts[i].toDouble(), width: 14)],
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _DayDetails(
              days: days,
              selectedIndex: selectedDayIndex,
              progress: progress,
              habitMap: habitMap,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatTile(
                    title: 'Hoy',
                    value: '${(completionToday * 100).clamp(0, 100).toStringAsFixed(0)}%',
                    subtitle: '$todayCompleted/${habits.length} completados',
                    progress: completionToday,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatTile(
                    title: 'Últimos 7 días',
                    value: '${(completionWeek * 100).clamp(0, 100).toStringAsFixed(0)}%',
                    subtitle: '$weeklyCompleted/${habits.length * 7} posibles',
                    progress: completionWeek,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<int> _lastSevenDaysCounts(List<HabitProgressEntity> progress, List<DateTime> days) {
    final counts = List<int>.filled(days.length, 0);
    for (int i = 0; i < days.length; i++) {
      counts[i] = progress.where((p) => p.date == days[i] && p.completed).length;
    }
    return counts;
  }

  HabitProgressEntity _normalize(HabitProgressEntity p) => HabitProgressEntity(
        habitId: p.habitId,
        date: DateTime.utc(p.date.year, p.date.month, p.date.day),
        completed: p.completed,
      );

}

class _DayDetails extends StatelessWidget {
  const _DayDetails({
    required this.days,
    required this.selectedIndex,
    required this.progress,
    required this.habitMap,
  });

  final List<DateTime> days;
  final int? selectedIndex;
  final List<HabitProgressEntity> progress;
  final Map<String, HabitEntity> habitMap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final day = selectedIndex != null && selectedIndex! < days.length ? days[selectedIndex!] : null;
    final completed = day == null
        ? const <HabitEntity>[]
        : progress
            .where((p) => p.date == day && p.completed)
            .map((p) => habitMap[p.habitId])
            .whereType<HabitEntity>()
            .toList();

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      child: Container(
        key: ValueKey(day ?? 'none'),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: scheme.outline.withValues(alpha: 0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              day == null
                  ? 'Toca una barra para ver detalles'
                  : 'Completados el ${day.day.toString().padLeft(2, '0')}/${day.month.toString().padLeft(2, '0')}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (day == null)
              Text('Toca cualquier barra para ver qué hábitos completaste ese día.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant))
            else if (completed.isEmpty)
              Text('No marcaste hábitos ese día.', style: Theme.of(context).textTheme.bodyMedium)
            else
              ...completed.map(
                (habit) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    IconData(habit.iconCodePoint, fontFamily: habit.iconFontFamily, fontPackage: habit.iconFontPackage),
                    color: scheme.primary,
                  ),
                  title: Text(habit.title),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant)),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.title, required this.value, required this.subtitle, required this.progress});

  final String title;
  final String value;
  final String subtitle;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: scheme.primary)),
          const SizedBox(height: 6),
          LinearProgressIndicator(value: progress.clamp(0, 1)),
          const SizedBox(height: 6),
          Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}
