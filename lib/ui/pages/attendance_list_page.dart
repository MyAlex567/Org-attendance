import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/attendance.dart';
import '../../models/event.dart';
import '../../providers/attendance_provider.dart';
import '../../theme/app_theme.dart';
import '../atoms/app_button.dart';
import '../atoms/app_loader.dart';
import '../atoms/app_text.dart';
import '../molecules/attendee_tile.dart';
import '../molecules/event_card.dart';
import '../molecules/status_message.dart';
import 'scan_page.dart';

/// Attendance List (officers and admin): who attended one session.
/// While the session is open there is also a button to go back to scanning.
class AttendanceListPage extends StatefulWidget {
  final Event event;
  final String orgName;

  const AttendanceListPage({
    super.key,
    required this.event,
    required this.orgName,
  });

  @override
  State<AttendanceListPage> createState() => _AttendanceListPageState();
}

class _AttendanceListPageState extends State<AttendanceListPage> {
  late final Stream<Event> _event;
  late final Stream<List<Attendance>> _attendance;

  @override
  void initState() {
    super.initState();
    final provider = context.read<AttendanceProvider>();
    _event = provider.watchEvent(widget.event.orgId, widget.event.id);
    _attendance = provider.watchAttendance(widget.event.orgId, widget.event.id);
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
            const AppText(
              text: 'Attendance',
              variant: AppTextVariant.title,
              color: AppColors.white,
            ),
            AppText(
              text: widget.orgName,
              variant: AppTextVariant.caption,
              color: AppColors.white,
            ),
          ],
        ),
      ),
      // Outer stream: the session (to see Open/Closed live).
      // Inner stream: the attendees.
      body: StreamBuilder<Event>(
        stream: _event,
        initialData: widget.event,
        builder: (context, eventSnapshot) {
          final event = eventSnapshot.data!;

          return StreamBuilder<List<Attendance>>(
            stream: _attendance,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                debugPrint('Attendance error: ${snapshot.error}');
                return const StatusMessage(
                  icon: Icons.error_outline,
                  message: 'Something went wrong',
                );
              }
              if (!snapshot.hasData) {
                return const AppLoader();
              }

              final attendees = snapshot.data!;

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  EventCard(
                    title: event.title,
                    venue: event.venue,
                    startsAt: event.startsAt,
                    isOpen: event.isOpen,
                    attendeeCount: attendees.length,
                  ),
                  if (event.isOpen) ...[
                    const SizedBox(height: 12),
                    AppButton(
                      label: 'Scan QR',
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ScanPage(
                            event: event,
                            orgName: widget.orgName,
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  const AppText(text: 'Attendees', variant: AppTextVariant.section),
                  const SizedBox(height: 8),
                  if (attendees.isEmpty)
                    const StatusMessage(
                      icon: Icons.people_outline,
                      message: 'No one has been scanned yet',
                    ),
                  for (final person in attendees)
                    Card(
                      color: AppColors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: AppColors.border),
                      ),
                      child: AttendeeTile(
                        studentName: person.name,
                        studentId: person.studentId,
                        scannedAt: person.scannedAt,
                        isSelfCheckIn: person.isSelfCheckIn,
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
