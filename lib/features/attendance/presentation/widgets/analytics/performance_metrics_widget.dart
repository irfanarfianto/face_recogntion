import 'package:flutter/material.dart';

class PerformanceMetricsWidget extends StatelessWidget {
  final Map<String, dynamic> metrics;

  const PerformanceMetricsWidget({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
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
              'Performance Metrics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _MetricRow(
              label: 'Accuracy',
              value: '${metrics['accuracy'].toStringAsFixed(2)}%',
              color: Colors.blue,
            ),
            const Divider(height: 24),
            _MetricRow(
              label: 'FAR (False Acceptance Rate)',
              value: '${metrics['far'].toStringAsFixed(2)}%',
              color: Colors.red,
              subtitle: '${metrics['falseAccepts']} false accepts',
            ),
            const Divider(height: 24),
            _MetricRow(
              label: 'FRR (False Rejection Rate)',
              value: '${metrics['frr'].toStringAsFixed(2)}%',
              color: Colors.orange,
              subtitle: '${metrics['falseRejects']} false rejects',
            ),
            const Divider(height: 24),
            _MetricRow(
              label: 'EER (Equal Error Rate)',
              value: '${metrics['eer'].toStringAsFixed(2)}%',
              color: Colors.purple,
              subtitle: 'Lower is better',
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.blue[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Estimates based on score distribution. For accurate FAR/FRR, controlled testing needed.',
                      style: TextStyle(fontSize: 11, color: Colors.blue[700]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final String? subtitle;

  const _MetricRow({
    required this.label,
    required this.value,
    required this.color,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
