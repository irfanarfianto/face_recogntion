import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_face_recognition/features/attendance/presentation/bloc/attendance_bloc.dart';
import 'package:test_face_recognition/features/attendance/presentation/utils/analytics_calculator.dart';
import 'package:test_face_recognition/features/attendance/presentation/widgets/analytics/summary_section_widget.dart';
import 'package:test_face_recognition/features/attendance/presentation/widgets/analytics/performance_metrics_widget.dart';
import 'package:test_face_recognition/features/attendance/presentation/widgets/analytics/score_distribution_widget.dart';
import 'package:test_face_recognition/features/attendance/presentation/widgets/analytics/threshold_analysis_widget.dart';
import 'package:test_face_recognition/features/attendance/presentation/widgets/analytics/recommendations_widget.dart';

class AnalyticsDashboardPage extends StatefulWidget {
  const AnalyticsDashboardPage({super.key});

  @override
  State<AnalyticsDashboardPage> createState() => _AnalyticsDashboardPageState();
}

class _AnalyticsDashboardPageState extends State<AnalyticsDashboardPage> {
  @override
  void initState() {
    super.initState();
    context.read<AttendanceBloc>().add(LoadLogsEvent());
    context.read<AttendanceBloc>().add(LoadThresholdEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Analytics Dashboard'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: BlocBuilder<AttendanceBloc, AttendanceState>(
        builder: (context, state) {
          if (state.status == AttendanceStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.logs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.analytics_outlined,
                    size: 64,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada data untuk dianalisis',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          // Calculate metrics using utility class
          final metrics = AnalyticsCalculator.calculateMetrics(state);
          final recommendations = AnalyticsCalculator.generateRecommendations(
            metrics,
            state.threshold,
          );

          return RefreshIndicator(
            onRefresh: () async {
              context.read<AttendanceBloc>().add(LoadLogsEvent());
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary Cards
                  SummarySectionWidget(metrics: metrics),
                  const SizedBox(height: 24),

                  // Performance Metrics
                  PerformanceMetricsWidget(metrics: metrics),
                  const SizedBox(height: 24),

                  // Score Distribution
                  ScoreDistributionWidget(metrics: metrics),
                  const SizedBox(height: 24),

                  // Threshold Analysis
                  ThresholdAnalysisWidget(
                    metrics: metrics,
                    currentThreshold: state.threshold,
                  ),
                  const SizedBox(height: 24),

                  // Recommendations
                  RecommendationsWidget(recommendations: recommendations),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
