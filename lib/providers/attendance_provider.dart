import 'package:flutter/foundation.dart';
import '../models/app_user.dart';
import '../models/attendance.dart';
import '../models/attendance_history.dart';
import '../models/event.dart';
import '../models/scan_result.dart';
import '../services/attendance_service.dart';
import '../services/service_failure.dart';

/// Sessions, scanning, attendance lists and my history.
class AttendanceProvider extends ChangeNotifier {
  final _attendanceService = AttendanceService();

  bool _isLoading = false;
  /// True while a session is being created (button spinner).
  /// Used in: TakeAttendancePage
  bool get isLoading => _isLoading;

  // The session created last, so Take Attendance can open its Scan screen.
  Event? _createdEvent;
  /// The session created last.
  /// Used in: TakeAttendancePage, to open ScanPage for the new session
  Event? get createdEvent => _createdEvent;

  /// Live list of an org's sessions.
  /// Used in: OrgPage, the sessions list
  Stream<List<Event>> watchEvents(String orgId) {
    return _attendanceService.watchEvents(orgId);
  }

  /// Live data of one session (to see it close).
  /// Used in: AttendanceListPage, Open / Closed and the Scan QR button
  Stream<Event> watchEvent(String orgId, String eventId) {
    return _attendanceService.watchEvent(orgId, eventId);
  }

  /// Live list of who attended a session.
  /// Used in: AttendanceListPage, the attendee list
  Stream<List<Attendance>> watchAttendance(String orgId, String eventId) {
    return _attendanceService.watchAttendance(orgId, eventId);
  }

  /// Live number of attendees in a session.
  /// Used in: OrgPage session cards (officers and admin) and ScanPage count card
  Stream<int> watchAttendanceCount(String orgId, String eventId) {
    return _attendanceService.watchAttendanceCount(orgId, eventId);
  }

  /// Live true/false: am I already marked present in this session?
  /// Used in: ScanPage, the Mark me present button
  Stream<bool> watchHasAttended(String orgId, String eventId, String uid) {
    return _attendanceService.watchHasAttended(orgId, eventId, uid);
  }

  /// Live list of the events I attended.
  /// Used in: HistoryPage
  Stream<List<AttendanceHistory>> watchHistory(String uid) {
    return _attendanceService.watchHistory(uid);
  }

  /// Starts a session. Returns null on success (see [createdEvent]),
  /// or a friendly error message.
  /// Used in: TakeAttendancePage, Create event button
  Future<String?> createEvent({
    required String orgId,
    required String title,
    required String venue,
    required DateTime startsAt,
    required AppUser? user,
  }) async {
    if (user == null) return 'Your profile is still loading. Please try again later';

    _isLoading = true;
    notifyListeners();

    try {
      _createdEvent = await _attendanceService.createEvent(
        orgId: orgId,
        title: title,
        venue: venue,
        startsAt: startsAt,
        createdBy: user.uid,
      );
      return null;
    } catch (e) {
      debugPrint('Create event error: $e');
      return 'Could not start the session. Please try again';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Closes a session. Returns null on success, or a friendly error message.
  /// Used in: ScanPage, Close button
  Future<String?> closeEvent(String orgId, String eventId) async {
    try {
      await _attendanceService.closeEvent(orgId, eventId);
      return null;
    } catch (e) {
      debugPrint('Close event error: $e');
      return 'Could not close the session. Please try again';
    }
  }

  /// Records the member whose QR code was scanned. [code] is the QR text,
  /// which is the member's uid.
  /// Used in: ScanPage, when the camera reads a QR code
  Future<ScanResult> scan({
    required Event event,
    required String orgName,
    required String code,
    required AppUser? officer,
  }) {
    return _record(
      event: event,
      orgName: orgName,
      memberUid: code.trim(),
      officer: officer,
      method: 'scan',
    );
  }

  /// Records my own attendance (officers and the admin).
  /// Used in: ScanPage, Mark me present button
  Future<ScanResult> markMePresent({
    required Event event,
    required String orgName,
    required AppUser? user,
  }) {
    return _record(
      event: event,
      orgName: orgName,
      memberUid: user?.uid ?? '',
      officer: user,
      method: 'self',
    );
  }

  /// Shared code for scan and markMePresent.
  /// Used in: scan and markMePresent (above)
  Future<ScanResult> _record({
    required Event event,
    required String orgName,
    required String memberUid,
    required AppUser? officer,
    required String method,
  }) async {
    if (officer == null) {
      return const ScanResult(
        ScanStatus.error,
        'Your profile is still loading. Please try again',
      );
    }

    try {
      return await _attendanceService.recordAttendance(
        event: event,
        orgName: orgName,
        memberUid: memberUid,
        scannedBy: officer.uid,
        method: method,
      );
    } on OrgFailure catch (e) {
      return ScanResult(ScanStatus.error, e.message);
    } catch (e) {
      debugPrint('Record attendance error: $e');
      return const ScanResult(
        ScanStatus.error,
        'Could not record attendance. Please try again',
      );
    }
  }
}
