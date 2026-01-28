import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/habit_progress_entity.dart';
import '../providers/habit_providers.dart';
import '../providers/progress_providers.dart';

class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = (ref.watch(progressProvider).value ?? []).map(_normalize).toList();
    final habits = ref.watch(habitsProvider).value ?? [];
    final counts = _lastSevenDaysCounts(progress);
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
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
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
                    return BarChartGroupData(x: i, barRods: [BarChartRodData(toY: counts[i].toDouble(), width: 14)]);
                  }),
                ),
              ),
            ),
            const SizedBox(height: 24),
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

  List<int> _lastSevenDaysCounts(List<HabitProgressEntity> progress) {
    final now = DateTime.now().toUtc();
    final counts = List<int>.filled(7, 0);
    for (int i = 0; i < 7; i++) {
      final day = DateTime.utc(now.year, now.month, now.day).subtract(Duration(days: 6 - i));
      counts[i] = progress.where((p) => p.date == day && p.completed).length;
    }
    return counts;
  }

  HabitProgressEntity _normalize(HabitProgressEntity p) => HabitProgressEntity(
        habitId: p.habitId,
        date: DateTime.utc(p.date.year, p.date.month, p.date.day),
        completed: p.completed,
      );
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
