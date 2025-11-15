import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/constants/storage_keys.dart';
import '../../../../core/errors/exceptions.dart';
import 'dart:convert';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> deleteToken();
  Future<void> saveUser(UserModel user);
  Future<UserModel?> getCachedUser();
  Future<void> clearUserData();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SecureStorage secureStorage;
  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImpl({
    required this.secureStorage,
    required this.sharedPreferences,
  });

  @override
  Future<void> saveToken(String token) async {
    await SecureStorage.saveToken(token);
  }

  @override
  Future<String?> getToken() async {
    return await SecureStorage.getToken();
  }

  @override
  Future<void> deleteToken() async {
    await SecureStorage.deleteToken();
  }

  @override
  Future<void> saveUser(UserModel user) async {
    try {
      // Save user data to shared preferences
      final userId = int.tryParse(user.id) ?? 0;
      await sharedPreferences.setInt(StorageKeys.userId, userId);
      await sharedPreferences.setString(StorageKeys.userName, user.fullName);
      await sharedPreferences.setString(StorageKeys.userEmail, user.email);
      await sharedPreferences.setString(StorageKeys.userRole, user.role);
      await sharedPreferences.setString(
          StorageKeys.userDepartment, user.department.name);
      final departmentId = int.tryParse(user.department.id) ?? 0;
      await sharedPreferences.setInt(
          StorageKeys.userDepartmentId, departmentId);
      await sharedPreferences.setBool(StorageKeys.isLoggedIn, true);

      // Cache full user object
      await sharedPreferences.setString(
        StorageKeys.cachedUserData,
        jsonEncode(user.toJson()),
      );
    } catch (e) {
      throw CacheException(message: 'Failed to save user data');
    }
  }

  @override
  Future<UserModel?> getCachedUser() async {
    try {
      final userJson = sharedPreferences.getString(StorageKeys.cachedUserData);
      if (userJson != null) {
        return UserModel.fromJson(jsonDecode(userJson));
      }
      return null;
    } catch (e) {
      throw CacheException(message: 'Failed to get cached user');
    }
  }

  @override
  Future<void> clearUserData() async {
    try {
      await deleteToken();
      await sharedPreferences.remove(StorageKeys.userId);
      await sharedPreferences.remove(StorageKeys.userName);
      await sharedPreferences.remove(StorageKeys.userEmail);
      await sharedPreferences.remove(StorageKeys.userRole);
      await sharedPreferences.remove(StorageKeys.userDepartment);
      await sharedPreferences.remove(StorageKeys.userDepartmentId);
      await sharedPreferences.remove(StorageKeys.isLoggedIn);
      await sharedPreferences.remove(StorageKeys.cachedUserData);
    } catch (e) {
      throw CacheException(message: 'Failed to clear user data');
    }
  }
}

