import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:test_face_recognition/features/attendance/presentation/bloc/attendance_bloc.dart';

class LogsPage extends StatefulWidget {
  const LogsPage({super.key});

  @override
  State<LogsPage> createState() => _LogsPageState();
}

class _LogsPageState extends State<LogsPage> {
  @override
  void initState() {
    super.initState();
    // Load logs and threshold when the page opens
    context.read<AttendanceBloc>().add(LoadLogsEvent());
    context.read<AttendanceBloc>().add(LoadThresholdEvent());
  }

  // Convert to West Indonesia Time (WIB) - UTC+7
  String _formatToWIB(DateTime dateTime) {
    // If the datetime is local and local is not WIB, we might need manual shift
    // But typically we should just trust standard timezones.
    // If we want to FORCE +7 display:

    // 1. Ensure we have it reliably (fromUTC if possible, or assume it's UTC if stored as such)
    // The Model converts toLocal(), so it depends on device.

    // To properly show WIB regardless of device setting:
    // Convert to UTC first (if it was converted to local), then add 7 hours.

    // However, clean way:
    // If db returns UTC, and we want WIB (UTC+7):

    // Note: log.scanTime from Model is already .toLocal().
    // If device is in WIB, it's fine.
    // If device is NOT in WIB, user wants WIB.

    final utc = dateTime.toUtc();
    final wib = utc.add(const Duration(hours: 7));
    return '${DateFormat('dd MMM yyyy, HH:mm:ss').format(wib)} WIB';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Consistent background
      appBar: AppBar(
        title: const Text('Riwayat Absensi'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: BlocBuilder<AttendanceBloc, AttendanceState>(
        builder: (context, state) {
          if (state.status == AttendanceStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == AttendanceStatus.failure && state.logs.isEmpty) {
            return Center(child: Text('Error: ${state.errorMessage}'));
          }
          if (state.logs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada log absensi.',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<AttendanceBloc>().add(LoadLogsEvent());
            },
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: state.logs.length,
              separatorBuilder: (_, _) => const SizedBox(height: 2),
              itemBuilder: (context, index) {
                final log = state.logs[index];
                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  color: Colors.white,
                  child: ExpansionTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    collapsedShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    backgroundColor: Colors.transparent,
                    collapsedBackgroundColor: Colors.transparent,
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue[50],
                      backgroundImage: log.imageUrl != null
                          ? NetworkImage(log.imageUrl!)
                          : null,
                      child: log.imageUrl == null
                          ? Text(
                              log.userName.isNotEmpty
                                  ? log.userName[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(color: Colors.blue),
                            )
                          : null,
                    ),
                    title: Text(
                      log.userName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      _formatToWIB(log.scanTime),
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color:
                            (log.matchScore ?? 1.0) <
                                (log.threshold ?? state.threshold)
                            ? Colors.green[50]
                            : Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        (log.matchScore ?? 1.0) <
                                (log.threshold ?? state.threshold)
                            ? "MATCH"
                            : "FAIL",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color:
                              (log.matchScore ?? 1.0) <
                                  (log.threshold ?? state.threshold)
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Divider(),
                            const SizedBox(height: 8),
                            _buildDetailRow(
                              'Distance Score (Lower is better)',
                              log.matchScore?.toStringAsFixed(6) ?? '-',
                            ),
                            if (log.threshold != null) ...[
                              const SizedBox(height: 4),
                              _buildDetailRow(
                                'Threshold Used',
                                log.threshold!.toStringAsFixed(6),
                              ),
                            ],
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildImageColumn(
                                  'Registered',
                                  log.enrolledImageUrl,
                                ),
                                const Icon(
                                  Icons.compare_arrows,
                                  size: 20,
                                  color: Colors.grey,
                                ),
                                _buildImageColumn('Captured', log.imageUrl),
                              ],
                            ),
                            const SizedBox(height: 16),

                            if (log.faceAttributes != null) ...[
                              const SizedBox(height: 8),
                              const Text(
                                "Atribut Wajah:",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  _buildAttrChip(
                                    'Yaw',
                                    log.faceAttributes!.yaw,
                                  ),
                                  const SizedBox(width: 8),
                                  _buildAttrChip(
                                    'Roll',
                                    log.faceAttributes!.roll,
                                  ),
                                  const SizedBox(width: 8),
                                  _buildAttrChip(
                                    'Pitch',
                                    log.faceAttributes!.pitch,
                                  ),
                                  const SizedBox(width: 8),
                                  if (log.faceAttributes!.smilingProbability !=
                                      null)
                                    _buildAttrChip(
                                      'Smile',
                                      log.faceAttributes!.smilingProbability! *
                                          100,
                                      suffix: '%',
                                    ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildAttrChip(String label, double? value, {String suffix = ''}) {
    if (value == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        '$label: ${value.toStringAsFixed(1)}$suffix',
        style: const TextStyle(fontSize: 10, color: Colors.black87),
      ),
    );
  }

  Widget _buildImageColumn(String label, String? url) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
            image: url != null
                ? DecorationImage(image: NetworkImage(url), fit: BoxFit.cover)
                : null,
          ),
          child: url == null
              ? const Icon(Icons.broken_image, size: 20, color: Colors.grey)
              : null,
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}
