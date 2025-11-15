import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import 'package:mh_employee_app/features/auth/data/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _error;
  User? _currentUser;


  AuthProvider() {
    // Initialize auth state
    _init();
  }

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  User? get currentUser => _currentUser;
  String? get error => _error;

  Future<void> _init() async {
    try {
      await _authService.init();
      _currentUser = _authService.currentUser;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await _authService.login(email, password);
      _error = null; // Explicitly clear error
      notifyListeners();
    } catch (e) {
      // Ensure _error is always a string
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.logout();
      _currentUser = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshUserData() async {
    try {
      // Set loading state
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Attempt to refresh user data
      _currentUser = await _authService.refreshUserData();

      // Clear any previous errors
      _error = null;
    } catch (e) {
      // Handle specific error scenarios
      _error = e.toString();

      // Optional: Logout user if token is invalid
      if (e.toString().contains('Unauthorized') ||
          e.toString().contains('token')) {
        await logout();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> initializeFromService(AuthService authService) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _authService.init();
      _currentUser = _authService.currentUser;

      // Load remember me state
      final prefs = await SharedPreferences.getInstance();
      final rememberMe = prefs.getBool('remember_me') ?? false;

      if (!rememberMe) {
        // Clear saved credentials if remember me is disabled
        await prefs.remove('email');
        await prefs.remove('password');
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

