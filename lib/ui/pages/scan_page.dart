import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/event.dart';
import '../../models/scan_result.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../atoms/app_text.dart';
import '../molecules/attendance_count_card.dart';
import '../molecules/scan_result_card.dart';
import '../molecules/self_check_in_button.dart';
import '../organisms/confirm_dialog.dart';
import '../organisms/qr_scanner.dart';

/// Scan QR (officers and admin): scan members' codes, see the live count,
/// mark yourself present, and close the session when the event is over.
class ScanPage extends StatefulWidget {
  final Event event;
  final String orgName;

  const ScanPage({
    super.key,
    required this.event,
    required this.orgName,
  });

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  // True while one scan is being saved: the camera keeps seeing the same code
  // many times per second, so new detections are ignored until we're done.
  bool _busy = false;
  bool _markingMe = false;
  ScanResult? _lastResult;

  late final Stream<int> _count;
  late final Stream<bool> _iAmPresent;

  @override
  void initState() {
    super.initState();
    final attendance = context.read<AttendanceProvider>();
    final uid = context.read<AuthProvider>().user?.uid;

    _count = attendance.watchAttendanceCount(widget.event.orgId, widget.event.id);
    _iAmPresent = uid == null
        ? Stream.value(false)
        : attendance.watchHasAttended(widget.event.orgId, widget.event.id, uid);
  }

  Future<void> _onScan(String code) async {
    if (_busy) return;
    setState(() => _busy = true);

    final result = await context.read<AttendanceProvider>().scan(
          event: widget.event,
          orgName: widget.orgName,
          code: code,
          officer: context.read<AuthProvider>().user,
        );

    if (!mounted) return;
    setState(() => _lastResult = result);

    // A short pause so the same code isn't read again right away while the
    // officer moves to the next person.
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _markMePresent() async {
    setState(() => _markingMe = true);

    final result = await context.read<AttendanceProvider>().markMePresent(
          event: widget.event,
          orgName: widget.orgName,
          user: context.read<AuthProvider>().user,
        );

    if (!mounted) return;
    setState(() {
      _markingMe = false;
      _lastResult = result;
    });
  }

  Future<void> _closeSession() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const ConfirmDialog(
        title: 'Close session',
        message: 'No one can be scanned after the session is closed. Continue?',
        confirmLabel: 'Close session',
      ),
    );
    if (confirmed != true || !mounted) return;

    final error = await context
        .read<AttendanceProvider>()
        .closeEvent(widget.event.orgId, widget.event.id);

    if (!mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.green,
        foregroundColor: AppColors.white,
        toolbarHeight: 72,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              text: widget.event.title,
              variant: AppTextVariant.title,
              color: AppColors.white,
            ),
            AppText(
              text: '${widget.orgName} · Scanning',
              variant: AppTextVariant.caption,
              color: AppColors.white,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _closeSession,
            style: TextButton.styleFrom(foregroundColor: AppColors.white),
            child: const Text('Close'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          QrScanner(onScan: _onScan),
          const SizedBox(height: 8),
          const AppText(
            text: "Point the camera at a member's QR code",
            variant: AppTextVariant.caption,
          ),
          const SizedBox(height: 16),
          StreamBuilder<bool>(
            stream: _iAmPresent,
            builder: (context, snapshot) {
              return SelfCheckInButton(
                isPresent: snapshot.data ?? false,
                isLoading: _markingMe,
                onPressed: _markMePresent,
              );
            },
          ),
          const SizedBox(height: 16),
          if (_lastResult != null) ...[
            ScanResultCard(
              message: _lastResult!.message,
              isSuccess: _lastResult!.isSuccess,
            ),
            const SizedBox(height: 16),
          ],
          StreamBuilder<int>(
            stream: _count,
            builder: (context, snapshot) {
              return AttendanceCountCard(count: snapshot.data ?? 0);
            },
          ),
        ],
      ),
    );
  }
}
