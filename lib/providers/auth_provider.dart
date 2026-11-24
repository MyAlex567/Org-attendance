import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import '../models/app_user.dart';
import '../services/user_service.dart';

class AuthProvider extends ChangeNotifier{
  final _authService = AuthService();
  final _userService = UserService();

  /// Live uid from Firebase Auth: a value when logged in, null when logged out.
  /// Used in: AuthGate (shows Login or MainPage)
  late final Stream<String?> uidChanges = _authService.uidChanges;

  bool _isLoading = false;
  AppUser? _user;
  /// The logged-in user's profile; null until loadUser finishes.
  /// Used in: HomePage, MyQrPage, HistoryPage, OrgPage, MembersPage, InvitationsPage, TakeAttendancePage, ScanPage
  AppUser? get user => _user;
  /// True while login, register or a reset email is in progress (button spinners).
  /// Used in: LoginPage (and its Forgot password dialog), RegisterPage
  bool get isLoading => _isLoading;

  /// Reads the logged-in user's profile from Firestore into [user].
  /// Used in: HomePage when it opens, and login() below
  Future<void> loadUser() async{
    final uid = _authService.currentUid;
    if(uid == null) return;

    _user = await _userService.getUser(uid);
    notifyListeners();
  }

  /// Logs in. Returns null on success, or a friendly error message.
  /// Used in: LoginPage
  Future<String?> login(String email, String password) async{
    _isLoading = true;
    notifyListeners();

    try{
      await _authService.login(email, password);
      await loadUser();
      return null;
    }on AuthFailure catch(e){
      return e.message;
    }finally{
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Logs out and clears the profile.
  /// Used in: ProfilePage, Log out button
  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }

  /// Sends a password reset email.
  /// Returns null on success, or a friendly error message.
  /// Used in: LoginPage, Forgot password dialog
  Future<String?> sendPasswordReset(String email) async {
    // Show the spinner on the dialog's button.
    _isLoading = true;
    notifyListeners();

    // Ask the service to send the email. null means it worked.
    try {
      await _authService.sendPasswordReset(email);
      return null;
    }
    // A known Firebase problem (bad email, offline, too many tries).
    on AuthFailure catch (e) {
      return e.message;
    }
    // Anything unexpected: log it for us, show a safe message to the user.
    catch (e) {
      debugPrint('Password reset error: $e');
      return 'Could not send the reset email. Please try again.';
    }
    // Always hide the spinner, whether it worked or failed.
    finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  /// Creates the account and saves the profile. Returns null on success, or a friendly error message.
  /// Used in: RegisterPage
  Future<String?> register(
    String fullname,
    String studentId,
    String email,
    String password,
  ) async{
    _isLoading = true;
    notifyListeners();

    try{
      final uid = await _authService.register(email, password);

      final user = AppUser(
        uid: uid,
        fullName: fullname,
        studentId: studentId,
        email: email,
      );
      
      await _userService.createUser(user);
      _user = user;

      return null;
    } on AuthFailure catch (e){
      return e.message;
    } catch (e){
      debugPrint('Register error: $e');
      return 'Could not save your profile. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

}