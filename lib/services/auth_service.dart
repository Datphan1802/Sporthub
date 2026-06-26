import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get user => _auth.authStateChanges();

  Future<UserCredential?> register(
      String email, String password, String name) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      User? user = result.user;
      if (user != null) {
        await _db.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': email,
          'name': name,
          'role': 'user',
          'ownedCourts': <String>[],
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return result;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserCredential?> login(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<UserModel?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
    } catch (_) {}
    return null;
  }

  Future<void> upgradeToOwner(String uid) async {
    await _db.collection('users').doc(uid).update({
      'role': 'owner',
    });
  }

  Future<void> updateUserName(String uid, String name) async {
    await _db.collection('users').doc(uid).update({
      'name': name,
    });
  }

  Future<void> addCourtToOwner(String uid, String courtId) async {
    await _db.collection('users').doc(uid).update({
      'ownedCourts': FieldValue.arrayUnion([courtId]),
    });
  }

  Future<void> removeCourtFromOwner(String uid, String courtId) async {
    await _db.collection('users').doc(uid).update({
      'ownedCourts': FieldValue.arrayRemove([courtId]),
    });
  }
}
