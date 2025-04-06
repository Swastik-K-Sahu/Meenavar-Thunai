import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/local_storage_service.dart';

enum AuthStatus { initial, authenticated, unauthenticated, loading, error }

class AuthResult {
  final bool success;
  final String? message;

  AuthResult({required this.success, this.message});
}

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService;
  final LocalStorageService _storageService;

  AuthStatus _status = AuthStatus.initial;
  String? _errorMessage;
  User? _user;

  // Getters
  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  User? get user => _user;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;

  // Constructor
  AuthViewModel({
    required AuthService authService,
    required LocalStorageService storageService,
  }) : _authService = authService,
       _storageService = storageService {
    // Initialize by checking current user
    _initializeAuthState();
  }

  // Initialize auth state
  Future<void> _initializeAuthState() async {
    _status = AuthStatus.loading;
    notifyListeners();

    _user = _authService.currentUser;

    if (_user != null) {
      _status = AuthStatus.authenticated;
    } else {
      _status = AuthStatus.unauthenticated;
    }

    notifyListeners();

    // Listen for auth state changes
    _authService.authStateChanges.listen((User? user) {
      _user = user;
      if (user != null) {
        _status = AuthStatus.authenticated;
        _saveUserData(user);
      } else {
        _status = AuthStatus.unauthenticated;
      }
      notifyListeners();
    });
  }

  // Register with name, email and password
  Future<AuthResult> register(
    String name,
    String email,
    String password,
  ) async {
    try {
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();

      // Register the user with email and password
      final user = await _authService.registerWithEmailAndPassword(
        email,
        password,
      );

      if (user != null) {
        // Update the user's display name
        await user.updateDisplayName(name);

        // Refresh user to get updated data
        await user.reload();
        _user = _authService.currentUser;

        _status = AuthStatus.authenticated;
        await _saveUserData(_user!);
        notifyListeners();
        return AuthResult(success: true);
      } else {
        _status = AuthStatus.error;
        _errorMessage = "Registration failed";
        notifyListeners();
        return AuthResult(success: false, message: "Registration failed");
      }
    } on FirebaseAuthException catch (e) {
      _status = AuthStatus.error;
      _errorMessage = _getMessageFromErrorCode(e.code);
      notifyListeners();
      return AuthResult(success: false, message: _errorMessage);
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return AuthResult(success: false, message: _errorMessage);
    }
  }

  // Login with email and password - removed rememberMe parameter
  Future<AuthResult> login(String email, String password) async {
    try {
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();

      final user = await _authService.loginWithEmailAndPassword(
        email,
        password,
      );

      if (user != null) {
        _user = user;
        _status = AuthStatus.authenticated;
        await _saveUserData(user);
        notifyListeners();
        return AuthResult(success: true);
      } else {
        _status = AuthStatus.error;
        _errorMessage = "Login failed";
        notifyListeners();
        return AuthResult(success: false, message: "Login failed");
      }
    } on FirebaseAuthException catch (e) {
      _status = AuthStatus.error;
      _errorMessage = _getMessageFromErrorCode(e.code);
      notifyListeners();
      return AuthResult(success: false, message: _errorMessage);
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return AuthResult(success: false, message: _errorMessage);
    }
  }

  // Sign in with Google
  Future<AuthResult> signInWithGoogle() async {
    try {
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();

      final user = await _authService.signInWithGoogle();

      if (user != null) {
        _user = user;
        _status = AuthStatus.authenticated;
        await _saveUserData(user);
        notifyListeners();
        return AuthResult(success: true);
      } else {
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return AuthResult(success: false, message: "Google sign in failed");
      }
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return AuthResult(success: false, message: _errorMessage);
    }
  }

  Future<bool> isUserLoggedIn() async {
    return _status == AuthStatus.authenticated;
  }

  // Sign out
  Future<AuthResult> signOut() async {
    try {
      await _authService.signOut();
      _status = AuthStatus.unauthenticated;
      _user = null;
      notifyListeners();
      return AuthResult(success: true);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return AuthResult(success: false, message: _errorMessage);
    }
  }

  // Reset password
  Future<AuthResult> resetPassword(String email) async {
    try {
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();

      await _authService.resetPassword(email);

      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return AuthResult(success: true, message: "Password reset email sent");
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return AuthResult(success: false, message: _errorMessage);
    }
  }

  // Save user data to local storage
  Future<void> _saveUserData(User user) async {
    Map<String, dynamic> userData = {
      'uid': user.uid,
      'email': user.email,
      'displayName': user.displayName,
      'photoURL': user.photoURL,
    };

    await _storageService.setUserData(jsonEncode(userData));
  }

  // Get friendly error messages
  String _getMessageFromErrorCode(String errorCode) {
    switch (errorCode) {
      case "user-not-found":
        return "No user found with this email.";
      case "wrong-password":
        return "Incorrect password.";
      case "email-already-in-use":
        return "An account already exists for this email.";
      case "invalid-email":
        return "Please enter a valid email address.";
      case "weak-password":
        return "Password is too weak. Please use a stronger password.";
      case "operation-not-allowed":
        return "This operation is not allowed.";
      case "user-disabled":
        return "This account has been disabled.";
      case "too-many-requests":
        return "Too many attempts. Please try again later.";
      case "network-request-failed":
        return "Network error. Please check your connection.";
      default:
        return "An error occurred. Please try again.";
    }
  }
}
