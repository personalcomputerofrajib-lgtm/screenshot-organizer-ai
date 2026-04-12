import 'package:flutter/material.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isSignedIn => _user != null;
  String? get error => _error;

  AuthProvider() {
    _initAuthState();
  }

  void _initAuthState() {
    // Create a mock local user instead of listening to Firebase
    _user = UserModel(
      uid: 'local_admin',
      displayName: 'Rajib',
      email: 'rajib19y1@gmail.com',
    );
    
    // Use Future.microtask to avoid calling notifyListeners during build
    Future.microtask(() => notifyListeners());
  }

  // Mock sign in method (bypasses Google and just logs in the local user)
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
    
    _user = UserModel(
      uid: 'local_admin',
      displayName: 'Rajib',
      email: 'rajib19y1@gmail.com',
    );
    
    _isLoading = false;
    notifyListeners();
    return true;
  }

  // Mock sign out method
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));
    _user = null;

    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}