import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<void> logout();
  Future<UserModel> getUserProfile();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient client;

  AuthRemoteDataSourceImpl({required this.client});

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      final response = await client.post(
        ApiConstants.login,
        body: {
          'email': email,
          'password': password,
        },
        requiresAuth: false,
      );

      if (response == null) {
        throw ServerException(message: 'No response from server');
      }

      // Extract user data from response (backend returns {success, token, user})
      if (response['user'] == null) {
        throw ServerException(message: 'No user data in response');
      }

      // Create UserModel from user data and add the token from top-level response
      final userJson = Map<String, dynamic>.from(response['user']);
      userJson['token'] = response['token']; // Add token to user data

      return UserModel.fromJson(userJson);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> logout() async {
    try {
      await client.post(ApiConstants.logout);
    } catch (e) {
      // Logout should succeed even if API call fails
      return;
    }
  }

  @override
  Future<UserModel> getUserProfile() async {
    try {
      final response = await client.get(ApiConstants.profile);

      if (response == null) {
        throw ServerException(message: 'No response from server');
      }

      // Extract user data from response (backend returns {success, user})
      if (response['user'] == null) {
        throw ServerException(message: 'No user data in response');
      }

      return UserModel.fromJson(response['user']);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}

