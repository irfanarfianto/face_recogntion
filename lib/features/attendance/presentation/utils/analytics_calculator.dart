import 'package:test_face_recognition/features/attendance/presentation/bloc/attendance_bloc.dart';

class AnalyticsCalculator {
  static Map<String, dynamic> calculateMetrics(AttendanceState state) {
    final logs = state.logs;
    final threshold = state.threshold;

    // Basic counts
    final totalScans = logs.length;
    final matchCount = logs
        .where((log) => (log.matchScore ?? 1.0) < (log.threshold ?? threshold))
        .length;
    final failCount = totalScans - matchCount;

    // Score statistics
    final scores = logs
        .where((log) => log.matchScore != null)
        .map((log) => log.matchScore!)
        .toList();

    final avgScore = scores.isEmpty
        ? 0.0
        : scores.reduce((a, b) => a + b) / scores.length;

    final minScore = scores.isEmpty
        ? 0.0
        : scores.reduce((a, b) => a < b ? a : b);
    final maxScore = scores.isEmpty
        ? 0.0
        : scores.reduce((a, b) => a > b ? a : b);

    // Calculate metrics at different thresholds for ROC-like analysis
    final thresholdPoints = [
      0.5,
      0.6,
      0.7,
      0.8,
      0.9,
      1.0,
      1.1,
      1.2,
      1.3,
      1.4,
      1.5,
    ];
    final rocData = thresholdPoints.map((t) {
      final accepted = logs.where((log) => (log.matchScore ?? 1.0) < t).length;
      final rejected = totalScans - accepted;
      return {
        'threshold': t,
        'accepted': accepted,
        'rejected': rejected,
        'acceptanceRate': totalScans > 0 ? (accepted / totalScans * 100) : 0.0,
      };
    }).toList();

    // Score distribution (histogram)
    final bins = [0.0, 0.5, 0.7, 0.9, 1.0, 1.1, 1.3, 1.5, 2.0];
    final distribution = <String, int>{};
    for (int i = 0; i < bins.length - 1; i++) {
      final count = scores.where((s) => s >= bins[i] && s < bins[i + 1]).length;
      distribution['${bins[i].toStringAsFixed(1)}-${bins[i + 1].toStringAsFixed(1)}'] =
          count;
    }

    // Calculate FAR and FRR estimates
    final currentAccepted = logs
        .where((log) => (log.matchScore ?? 1.0) < threshold)
        .length;
    final currentRejected = totalScans - currentAccepted;

    // Estimated metrics (simplified)
    final accuracy = totalScans > 0 ? (matchCount / totalScans * 100) : 0.0;

    // For FAR/FRR estimation, we assume:
    // - Scores < 0.8 are likely genuine
    // - Scores > 1.2 are likely impostors
    final likelyGenuine = scores.where((s) => s < 0.8).length;
    final likelyImpostors = scores.where((s) => s > 1.2).length;

    final falseAccepts = logs.where((log) {
      final score = log.matchScore ?? 1.0;
      return score >= 1.2 && score < threshold; // Impostor accepted
    }).length;

    final falseRejects = logs.where((log) {
      final score = log.matchScore ?? 1.0;
      return score < 0.8 && score >= threshold; // Genuine rejected
    }).length;

    final far = likelyImpostors > 0
        ? (falseAccepts / likelyImpostors * 100)
        : 0.0;
    final frr = likelyGenuine > 0 ? (falseRejects / likelyGenuine * 100) : 0.0;

    return {
      'totalScans': totalScans,
      'matchCount': matchCount,
      'failCount': failCount,
      'successRate': totalScans > 0 ? (matchCount / totalScans * 100) : 0.0,
      'avgScore': avgScore,
      'minScore': minScore,
      'maxScore': maxScore,
      'distribution': distribution,
      'rocData': rocData,
      'accuracy': accuracy,
      'far': far,
      'frr': frr,
      'eer': (far + frr) / 2, // Simplified EER
      'likelyGenuine': likelyGenuine,
      'likelyImpostors': likelyImpostors,
      'falseAccepts': falseAccepts,
      'falseRejects': falseRejects,
    };
  }

  static List<Map<String, dynamic>> generateRecommendations(
    Map<String, dynamic> metrics,
    double currentThreshold,
  ) {
    final far = metrics['far'] as double;
    final frr = metrics['frr'] as double;
    final accuracy = metrics['accuracy'] as double;

    final recommendations = <Map<String, dynamic>>[];

    // Recommendation logic
    if (far > 10) {
      recommendations.add({
        'icon': 'security',
        'title': 'High False Acceptance Rate',
        'description':
            'Consider lowering threshold to 0.8-0.9 for better security',
        'severity': 'high',
      });
    }

    if (frr > 10) {
      recommendations.add({
        'icon': 'person_off',
        'title': 'High False Rejection Rate',
        'description':
            'Consider raising threshold to 1.1-1.2 for better user experience',
        'severity': 'medium',
      });
    }

    if (accuracy > 95) {
      recommendations.add({
        'icon': 'verified',
        'title': 'Excellent Performance',
        'description':
            'Current threshold (${currentThreshold.toStringAsFixed(2)}) is optimal',
        'severity': 'success',
      });
    }

    if (recommendations.isEmpty) {
      recommendations.add({
        'icon': 'info',
        'title': 'Good Performance',
        'description': 'System is performing well with current settings',
        'severity': 'info',
      });
    }

    return recommendations;
  }
}
