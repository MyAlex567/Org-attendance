import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import '../models/app_user.dart';
import '../services/firestore_service.dart';

class AuthProvider extends ChangeNotifier{
  final _authService = AuthService();
  final _firestoreService = FirestoreService();

  late final Stream<String?> uidChanges = _authService.uidChanges;

  bool _isLoading = false;
  AppUser? _user;
  AppUser? get user => _user;
  bool get isLoading => _isLoading;

  Future<void> loadUser() async{
    final uid = _authService.currentUid;
    if(uid == null) return;

    _user = await _firestoreService.getUser(uid);
    notifyListeners();
  }

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

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }

  /// Sends a password reset email.
  /// Returns null on success, or a friendly error message.
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
      
      await _firestoreService.createUser(user);
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