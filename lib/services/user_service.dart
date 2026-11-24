import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';

/// Firestore reads and writes for user profiles (users/{uid}).
class UserService {
  final _db = FirebaseFirestore.instance;

  /// Saves a new user's profile at users/{uid}.
  /// Used in: RegisterPage (via AuthProvider.register)
  Future<void> createUser(AppUser user){
    final data = user.toMap();

    data['createdAt'] = FieldValue.serverTimestamp();
    return _db.collection('users').doc(user.uid).set(data);
  }

  /// Reads one user's profile from users/{uid}.
  /// Used in: HomePage when it opens, and LoginPage after login (via AuthProvider.loadUser)
  Future<AppUser> getUser(String uid) async{
    final doc = await _db.collection('users').doc(uid).get();

    return AppUser.fromMap(doc.id, doc.data() ?? {});
  }
}
