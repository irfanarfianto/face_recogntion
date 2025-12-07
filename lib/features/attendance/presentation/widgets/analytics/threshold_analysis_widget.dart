import 'package:flutter/material.dart';

class ThresholdAnalysisWidget extends StatelessWidget {
  final Map<String, dynamic> metrics;
  final double currentThreshold;

  const ThresholdAnalysisWidget({
    super.key,
    required this.metrics,
    required this.currentThreshold,
  });

  @override
  Widget build(BuildContext context) {
    final rocData = metrics['rocData'] as List<Map<String, dynamic>>;

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
              'Threshold Analysis',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Current threshold: ${currentThreshold.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ...rocData.map((data) {
              final threshold = data['threshold'] as double;
              final acceptanceRate = data['acceptanceRate'] as double;
              final isCurrent = (threshold - currentThreshold).abs() < 0.01;

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isCurrent ? Colors.blue[50] : Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isCurrent ? Colors.blue : Colors.grey.shade200,
                    width: isCurrent ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 40,
                      child: Text(
                        threshold.toStringAsFixed(1),
                        style: TextStyle(
                          fontWeight: isCurrent
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isCurrent ? Colors.blue : Colors.black87,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: acceptanceRate / 100,
                          minHeight: 6,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getThresholdColor(acceptanceRate),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 50,
                      child: Text(
                        '${acceptanceRate.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isCurrent
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: Colors.grey[700],
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Color _getThresholdColor(double acceptanceRate) {
    if (acceptanceRate > 90) return Colors.green;
    if (acceptanceRate > 70) return Colors.lightGreen;
    if (acceptanceRate > 50) return Colors.orange;
    return Colors.red;
  }
}
