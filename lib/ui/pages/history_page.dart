import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/attendance_history.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../atoms/app_loader.dart';
import '../atoms/app_text.dart';
import '../molecules/attendance_history_tile.dart';
import '../molecules/status_message.dart';

/// History: every event I attended, newest first, with the org name.
class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  // Kept so rebuilds don't restart the Firestore listener.
  Stream<List<AttendanceHistory>>? _history;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    if (user != null) {
      _history ??= context.read<AttendanceProvider>().watchHistory(user.uid);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.green,
        title: const AppText(
          text: 'History',
          variant: AppTextVariant.title,
          color: AppColors.white,
        ),
      ),
      body: StreamBuilder<List<AttendanceHistory>>(
        stream: _history,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            debugPrint('History error: ${snapshot.error}');
            return const StatusMessage(
              icon: Icons.error_outline,
              message: 'Something went wrong',
            );
          }
          if (!snapshot.hasData) {
            return const AppLoader();
          }

          final history = snapshot.data!;
          if (history.isEmpty) {
            return const StatusMessage(
              icon: Icons.history,
              message: 'No attended events yet',
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (final item in history)
                Card(
                  color: AppColors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: AppColors.border),
                  ),
                  child: AttendanceHistoryTile(
                    eventTitle: item.eventTitle,
                    orgName: item.orgName,
                    scannedAt: item.scannedAt,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
