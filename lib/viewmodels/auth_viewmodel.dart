import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _currentUser;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  AuthViewModel() {
    _authService.user.listen((User? user) async {
      if (user != null) {
        _currentUser = await _authService.getUserData(user.uid);
      } else {
        _currentUser = null;
      }
      notifyListeners();
    });
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    
    final result = await _authService.login(email, password);
    
    _isLoading = false;
    notifyListeners();
    return result != null;
  }

  Future<bool> register(String email, String password, String name) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final result = await _authService.register(email, password, name);
      _isLoading = false;
      notifyListeners();
      return result != null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
  }
}
