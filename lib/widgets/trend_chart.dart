import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/openalex_group.dart';
import '../utils/formatters.dart';

class TrendChart extends StatelessWidget {
  const TrendChart({super.key, required this.points});

  final List<OpenAlexGroup> points;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return const SizedBox(
        height: 220,
        child: Center(child: Text('No trend data available.')),
      );
    }

    final colorScheme = Theme.of(context).colorScheme;
    final maxCount = points
        .map((point) => point.count)
        .fold<int>(0, (best, current) => current > best ? current : best);
    final interval = points.length <= 8 ? 1 : (points.length / 5).ceil();

    return SizedBox(
      height: 260,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceBetween,
          maxY: maxCount == 0 ? 1 : maxCount * 1.15,
          gridData: FlGridData(
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) =>
                FlLine(color: colorScheme.outlineVariant, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => colorScheme.inverseSurface,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final point = points[group.x.toInt()];
                return BarTooltipItem(
                  '${point.name}\n${formatCount(point.count)} publications',
                  TextStyle(
                    color: colorScheme.onInverseSurface,
                    fontWeight: FontWeight.w700,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 44,
                getTitlesWidget: (value, meta) {
                  if (value == 0) {
                    return const SizedBox.shrink();
                  }
                  return Text(
                    formatCompactCount(value),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 34,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= points.length) {
                    return const SizedBox.shrink();
                  }
                  if (index % interval != 0 && index != points.length - 1) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      points[index].name,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < points.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: points[i].count.toDouble(),
                    width: 10,
                    color: colorScheme.primary,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
