import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Get current user
  Stream<User?> get user => _auth.authStateChanges();

  // Register with email and password
  Future<UserCredential?> register(String email, String password, String name) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      
      User? user = result.user;
      if (user != null) {
        // LƯU VÀO FIRESTORE
        await _db.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': email,
          'name': name,
          'role': 'user', // Mặc định là user
          'createdAt': FieldValue.serverTimestamp(),
        });
        print("ĐÃ LƯU USER VÀO FIRESTORE THÀNH CÔNG");
      }
      return result;
    } catch (e) {
      print("LỖI ĐĂNG KÝ: $e");
      rethrow; // Đẩy lỗi ra ngoài để UI xử lý
    }
  }

  // Sign in with email and password
  Future<UserCredential?> login(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get user data from Firestore
  Future<UserModel?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print(e.toString());
    }
    return null;
  }
}
