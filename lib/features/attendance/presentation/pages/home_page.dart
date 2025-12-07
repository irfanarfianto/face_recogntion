import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_face_recognition/features/attendance/presentation/bloc/attendance_bloc.dart';
import 'package:test_face_recognition/features/attendance/presentation/pages/analytics_dashboard_page.dart';
import 'package:test_face_recognition/features/attendance/presentation/pages/attendance_page.dart';
import 'package:test_face_recognition/features/attendance/presentation/pages/logs_page.dart';
import 'package:test_face_recognition/features/attendance/presentation/pages/manage_users_page.dart';
import 'package:test_face_recognition/features/attendance/presentation/pages/register_page.dart';
import 'package:test_face_recognition/features/attendance/presentation/pages/settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Load users to check if any exist
    context.read<AttendanceBloc>().add(LoadUsersEvent());
  }

  Future<void> _handleAttendance(BuildContext context) async {
    // Load users first
    context.read<AttendanceBloc>().add(LoadUsersEvent());

    // Wait a bit for state to update
    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;

    final state = context.read<AttendanceBloc>().state;

    // Check if there are any registered users
    if (state.allUsers.isEmpty) {
      _showNoUsersDialog(context);
    } else {
      // Navigate to attendance page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AttendancePage()),
      );
    }
  }

  void _showNoUsersDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.person_off, size: 48, color: Colors.orange),
        title: const Text('Belum Ada User Terdaftar'),
        content: const Text(
          'Silakan daftarkan wajah terlebih dahulu sebelum melakukan absensi.',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RegisterPage()),
              );
            },
            icon: const Icon(Icons.person_add),
            label: const Text('Daftar Sekarang'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selamat Datang',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Admin Panel',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SettingsPage(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.settings),
                        tooltip: "Pengaturan",
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Main Actions Grid
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildActionCard(
                      context,
                      title: 'Absen',
                      icon: Icons.face_retouching_natural,
                      color: Theme.of(context).colorScheme.primary,
                      onTap: () => _handleAttendance(context),
                      isPrimary: true,
                    ),
                    _buildActionCard(
                      context,
                      title: 'Daftar Wajah',
                      icon: Icons.person_add_alt_1,
                      color: Colors.orange,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterPage(),
                        ),
                      ),
                    ),
                    _buildActionCard(
                      context,
                      title: 'Manajemen User',
                      icon: Icons.people_alt,
                      color: Colors.purple,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ManageUsersPage(),
                        ),
                      ),
                    ),
                    _buildActionCard(
                      context,
                      title: 'Log Absensi',
                      icon: Icons.history,
                      color: Colors.teal,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LogsPage(),
                        ),
                      ),
                    ),
                    _buildActionCard(
                      context,
                      title: 'Analytics',
                      icon: Icons.analytics,
                      color: Colors.indigo,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AnalyticsDashboardPage(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Footer info
              Center(
                child: Text(
                  'v1.0.0 • Powered by MobileFaceNet',
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return Card(
      elevation: isPrimary ? 4 : 0,
      shadowColor: isPrimary ? color.withOpacity(0.4) : null,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: isPrimary
            ? BorderSide.none
            : BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
