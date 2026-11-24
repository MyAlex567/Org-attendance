import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthFailure implements Exception{
  final String message;
  const AuthFailure(this.message);
}

String _friendlyMessage(FirebaseAuthException e) {
  switch (e.code) {
    case 'invalid-credential':
      return 'Incorrect email or password.';
    case 'invalid-email':
      return 'Please enter a valid email.';
    case 'email-already-in-use':
      return 'That email is already registered.';
    case 'weak-password':
      return 'Password must be at least 6 characters.';
    default:
      debugPrint('Auth error: ${e.code}');
      return 'Something went wrong. Please try again.';
  }
}

class AuthService {
  final _auth = FirebaseAuth.instance;
  String? get currentUid => _auth.currentUser?.uid;

  Stream<String?> get uidChanges => _auth.authStateChanges().map((user) => user?.uid);

  Future<void> logout() => _auth.signOut();

  Future<String> login(String email, String password) async{
    try{
      final credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return credential.user!.uid;
    }on FirebaseAuthException catch(e){
      throw AuthFailure(_friendlyMessage(e));
    }
  }

  Future<String> register(String email, String password) async{
    try{
      final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return credential.user!.uid;
    } on FirebaseAuthException catch (e){
      throw AuthFailure(_friendlyMessage(e));
    }
  }
}
