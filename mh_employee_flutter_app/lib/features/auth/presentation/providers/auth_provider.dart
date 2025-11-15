import 'package:flutter/foundation.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/login.dart';
import '../../domain/usecases/logout.dart';

class AuthProvider extends ChangeNotifier {
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;

  User? _user;
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _error;

  AuthProvider({
    required this.loginUseCase,
    required this.logoutUseCase,
  });

  // Getters
  User? get user => _user;
  User? get currentUser => _user; // Alias for compatibility
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get error => _error;

  // Check authentication status on init
  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Check if user has valid token
      final isAuth = await loginUseCase.repository.isAuthenticated();
      _isAuthenticated = isAuth;

      if (isAuth) {
        // Get user profile
        final result = await loginUseCase.repository.getUserProfile();
        result.fold(
          (failure) {
            _isAuthenticated = false;
            _error = failure.message;
          },
          (user) {
            _user = user;
            _isAuthenticated = true;
          },
        );
      }
    } catch (e) {
      _isAuthenticated = false;
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Login
  Future<void> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await loginUseCase(LoginParams(
      email: email,
      password: password,
    ));

    result.fold(
      (failure) {
        _error = failure.message;
        _isLoading = false;
        _isAuthenticated = false;
        notifyListeners();
      },
      (user) {
        _user = user;
        _isLoading = false;
        _isAuthenticated = true;
        _error = null;
        notifyListeners();
      },
    );
  }

  // Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await logoutUseCase();

    _user = null;
    _isAuthenticated = false;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  // Refresh user data
  Future<void> refreshUserData() async {
    if (!_isAuthenticated) return;

    try {
      final result = await loginUseCase.repository.getUserProfile();
      result.fold(
        (failure) {
          _error = failure.message;
          // If unauthorized, logout
          if (failure.message.toLowerCase().contains('unauthorized') ||
              failure.message.toLowerCase().contains('token')) {
            logout();
          }
        },
        (user) {
          _user = user;
          _error = null;
          notifyListeners();
        },
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}


