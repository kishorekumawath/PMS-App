import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class OccupancyChart extends StatelessWidget {
  final int occupied;
  final int vacant;

  const OccupancyChart({
    super.key,
    required this.occupied,
    required this.vacant,
  });

  @override
  Widget build(BuildContext context) {
    final total = occupied + vacant;
    final colorScheme = Theme.of(context).colorScheme;

    if (total == 0) {
      return Center(
        child: Text(
          'No properties yet',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: colorScheme.outline),
        ),
      );
    }

    final occupiedPct =
        total > 0 ? (occupied / total * 100).toStringAsFixed(0) : '0';

    return Row(
      children: [
        Expanded(
          flex: 5,
          child: AspectRatio(
            aspectRatio: 1,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 36,
                sections: [
                  if (occupied > 0)
                    PieChartSectionData(
                      value: occupied.toDouble(),
                      color: Colors.green.shade500,
                      radius: 48,
                      showTitle: false,
                    ),
                  if (vacant > 0)
                    PieChartSectionData(
                      value: vacant.toDouble(),
                      color: Colors.orange.shade300,
                      radius: 48,
                      showTitle: false,
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 5,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$occupiedPct%',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade600,
                    ),
              ),
              Text(
                'Occupancy Rate',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.outline,
                    ),
              ),
              const SizedBox(height: 16),
              _Legend(color: Colors.green.shade500, label: 'Occupied ($occupied)'),
              const SizedBox(height: 6),
              _Legend(color: Colors.orange.shade300, label: 'Vacant ($vacant)'),
            ],
          ),
        ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;

  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
