import 'dart:convert';

import 'package:mh_employee_app/core/storage/secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mh_employee_app/features/auth/data/models/user_model.dart';
import 'api_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  User? _currentUser;
  User? get currentUser => _currentUser;

  Future init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = await SecureStorage.getToken();
      final rememberMe = prefs.getBool('remember_me') ?? false;
      final isLoggedIn = prefs.getBool('is_logged_in') ?? false;

      if (token != null && isLoggedIn) {
        final userStr = prefs.getString('user_data');
        if (userStr != null) {
          _currentUser = User.fromJson(json.decode(userStr));
          try {
            await refreshUserData();
          } catch (e) {
            print('Token validation failed: $e');
            await logout();
          }
        }
      } else if (rememberMe) {
        // Preserve remember me state even when logged out
        final email = prefs.getString('email');
        final password = prefs.getString('password');
        if (email != null && password != null) {
          // Don't automatically log in, just keep the credentials
          await prefs.setBool('remember_me', true);
        }
      }
    } catch (e) {
      print('Error in AuthService init: $e');
      await logout();
    }
  }

  Future<User> login(String email, String password) async {
    try {
      // TODO: Migrate to ApiClient
      final response = await ApiService.login(email, password);

      if (!response['success']) {
        throw Exception(response['message'] ?? 'Login failed');
      }

      final user = User.fromJson(response['user']);
      await _saveAuthData(response['token'], user);
      _currentUser = user;
      return user;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> _saveAuthData(String token, User user) async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      SecureStorage.saveToken(token),
      prefs.setString('user_data', json.encode(user.toJson())),
      prefs.setBool('is_logged_in', true),
      prefs.setInt('login_timestamp', DateTime.now().millisecondsSinceEpoch)
    ]);
  }

  Future logout() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool('remember_me') ?? false;
    
    // Store credentials temporarily if remember me is enabled
    String? savedEmail;
    String? savedPassword;
    if (rememberMe) {
      savedEmail = prefs.getString('email');
      savedPassword = prefs.getString('password');
    }

    // Clear auth-related data
    await SecureStorage.deleteToken();
    await prefs.remove('is_logged_in');
    await prefs.remove('user_data');

    // Restore credentials if remember me was enabled
    if (rememberMe) {
      await prefs.setBool('remember_me', true);
      if (savedEmail != null) await prefs.setString('email', savedEmail);
      if (savedPassword != null) await prefs.setString('password', savedPassword);
    }

    _currentUser = null;
  } catch (e) {
    print('Error during logout: $e');
    rethrow;
  }
}

  Future<User> refreshUserData() async {
    try {
      // TODO: Migrate to ApiClient
      final response = await ApiService.getUserProfile();
      final user = User.fromJson(response['user']);
      await _saveUserData(user);
      _currentUser = user;
      return user;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> _saveUserData(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', json.encode(user.toJson()));
  }

  Exception _handleError(dynamic error) {
    if (error is Exception) {
      return error;
    }
    // Ensure we always return a string message
    return Exception(error?.toString() ?? 'An unknown error occurred');
  }
}


