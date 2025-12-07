import 'package:flutter/material.dart';

class RecommendationsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> recommendations;

  const RecommendationsWidget({super.key, required this.recommendations});

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
              'Recommendations',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...recommendations.map((rec) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getRecommendationColor(rec['severity'])[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _getRecommendationColor(rec['severity'])[200]!,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      _getIcon(rec['icon']),
                      color: _getRecommendationColor(rec['severity'])[700],
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            rec['title'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _getRecommendationColor(
                                rec['severity'],
                              )[900],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            rec['description'],
                            style: TextStyle(
                              fontSize: 12,
                              color: _getRecommendationColor(
                                rec['severity'],
                              )[700],
                            ),
                          ),
                        ],
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

  MaterialColor _getRecommendationColor(String severity) {
    switch (severity) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'success':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'security':
        return Icons.security;
      case 'person_off':
        return Icons.person_off;
      case 'verified':
        return Icons.verified;
      case 'info':
        return Icons.info;
      default:
        return Icons.info_outline;
    }
  }
}
