import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage();
  static const _authTokenKey = 'auth_token';

  // Save token
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _authTokenKey, value: token);
  }
  // static Future<void> saveToken(String? token) async {
  //   if (token != null) {
  //     // Save the token to secure storage
  //     await _storage.write(key: 'auth_token', value: token);
  //   } else {
  //     print('Token is null, skipping save'); // Debug statement
  //   }
  // }

  // Retrieve token
  static Future<String?> getToken() async {
    return await _storage.read(key: _authTokenKey);
  }

  // Delete token
  static Future<void> deleteToken() async {
    await _storage.delete(key: _authTokenKey);
  }

   // Add these general methods for storing credentials
  static Future<void> saveValue(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  static Future<String?> getValue(String key) async {
    return await _storage.read(key: key);
  }

  static Future<void> deleteValue(String key) async {
    await _storage.delete(key: key);
  }

  // Update logout to clear all stored data
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}

