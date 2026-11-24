import 'package:flutter/foundation.dart';
import '../models/app_user.dart';
import '../models/attendance.dart';
import '../models/attendance_history.dart';
import '../models/event.dart';
import '../models/scan_result.dart';
import '../services/firestore_service.dart';

/// Sessions, scanning, attendance lists and my history.
class AttendanceProvider extends ChangeNotifier {
  final _firestoreService = FirestoreService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // The session created last, so Take Attendance can open its Scan screen.
  Event? _createdEvent;
  Event? get createdEvent => _createdEvent;

  /// Live list of an org's sessions.
  Stream<List<Event>> watchEvents(String orgId) {
    return _firestoreService.watchEvents(orgId);
  }

  /// Live data of one session (to see it close).
  Stream<Event> watchEvent(String orgId, String eventId) {
    return _firestoreService.watchEvent(orgId, eventId);
  }

  /// Live list of who attended a session.
  Stream<List<Attendance>> watchAttendance(String orgId, String eventId) {
    return _firestoreService.watchAttendance(orgId, eventId);
  }

  /// Live number of attendees in a session.
  Stream<int> watchAttendanceCount(String orgId, String eventId) {
    return _firestoreService.watchAttendanceCount(orgId, eventId);
  }

  /// Live true/false: am I already marked present in this session?
  Stream<bool> watchHasAttended(String orgId, String eventId, String uid) {
    return _firestoreService.watchHasAttended(orgId, eventId, uid);
  }

  /// Live list of the events I attended.
  Stream<List<AttendanceHistory>> watchHistory(String uid) {
    return _firestoreService.watchHistory(uid);
  }

  /// Starts a session. Returns null on success (see [createdEvent]),
  /// or a friendly error message.
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
      _createdEvent = await _firestoreService.createEvent(
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
  Future<String?> closeEvent(String orgId, String eventId) async {
    try {
      await _firestoreService.closeEvent(orgId, eventId);
      return null;
    } catch (e) {
      debugPrint('Close event error: $e');
      return 'Could not close the session. Please try again';
    }
  }

  /// Records the member whose QR code was scanned. [code] is the QR text,
  /// which is the member's uid.
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
      return await _firestoreService.recordAttendance(
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
