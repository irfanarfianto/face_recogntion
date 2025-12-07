import 'package:flutter/material.dart';

class ScoreDistributionWidget extends StatelessWidget {
  final Map<String, dynamic> metrics;

  const ScoreDistributionWidget({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    final distribution = metrics['distribution'] as Map<String, int>;
    final maxCount = distribution.values.isEmpty
        ? 1
        : distribution.values.reduce((a, b) => a > b ? a : b);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Score Distribution',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Avg: ${metrics['avgScore'].toStringAsFixed(3)} | Min: ${metrics['minScore'].toStringAsFixed(3)} | Max: ${metrics['maxScore'].toStringAsFixed(3)}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ...distribution.entries.map((entry) {
              final percentage = maxCount > 0 ? (entry.value / maxCount) : 0.0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entry.key, style: const TextStyle(fontSize: 12)),
                        Text(
                          '${entry.value} scans',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percentage,
                        minHeight: 8,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getScoreColor(entry.key),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Color _getScoreColor(String range) {
    final start = double.tryParse(range.split('-')[0]) ?? 0.0;
    if (start < 0.7) return Colors.green;
    if (start < 1.0) return Colors.lightGreen;
    if (start < 1.2) return Colors.orange;
    return Colors.red;
  }
}
