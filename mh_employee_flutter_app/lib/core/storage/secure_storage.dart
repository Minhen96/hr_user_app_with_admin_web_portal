import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/storage_keys.dart';

class SecureStorage {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  // Auth Token
  static Future<void> saveToken(String token) async {
    await _storage.write(key: StorageKeys.authToken, value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: StorageKeys.authToken);
  }

  static Future<void> deleteToken() async {
    await _storage.delete(key: StorageKeys.authToken);
  }

  // Refresh Token
  static Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: StorageKeys.refreshToken, value: token);
  }

  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: StorageKeys.refreshToken);
  }

  static Future<void> deleteRefreshToken() async {
    await _storage.delete(key: StorageKeys.refreshToken);
  }

  // FCM Token
  static Future<void> saveFcmToken(String token) async {
    await _storage.write(key: StorageKeys.fcmToken, value: token);
  }

  static Future<String?> getFcmToken() async {
    return await _storage.read(key: StorageKeys.fcmToken);
  }

  static Future<void> deleteFcmToken() async {
    await _storage.delete(key: StorageKeys.fcmToken);
  }

  // Generic save/get/delete methods
  static Future<void> saveValue(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  static Future<String?> getValue(String key) async {
    return await _storage.read(key: key);
  }

  static Future<void> deleteValue(String key) async {
    await _storage.delete(key: key);
  }

  // Clear all stored data
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  // Check if has token
  static Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}

