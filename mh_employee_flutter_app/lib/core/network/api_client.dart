import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../constants/api_constants.dart';
import '../errors/exceptions.dart';
import '../storage/secure_storage.dart';

class ApiClient {
  final http.Client _client;
  final SecureStorage _secureStorage;

  ApiClient({
    http.Client? client,
    SecureStorage? secureStorage,
  })  : _client = client ?? http.Client(),
        _secureStorage = secureStorage ?? SecureStorage();

  // GET request
  Future<dynamic> get(
    String endpoint, {
    Map<String, String>? queryParameters,
    bool requiresAuth = true,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParameters);
      final headers = await _getHeaders(requiresAuth);

      final response = await _client
          .get(uri, headers: headers)
          .timeout(ApiConstants.timeout);

      return _handleResponse(response);
    } on SocketException {
      throw NetworkException();
    } on TimeoutException {
      throw TimeoutException();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  // POST request
  Future<dynamic> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      final headers = await _getHeaders(requiresAuth);

      final response = await _client
          .post(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConstants.timeout);

      return _handleResponse(response);
    } on SocketException {
      throw NetworkException();
    } on TimeoutException {
      throw TimeoutException();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  // PUT request
  Future<dynamic> put(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      final headers = await _getHeaders(requiresAuth);

      final response = await _client
          .put(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConstants.timeout);

      return _handleResponse(response);
    } on SocketException {
      throw NetworkException();
    } on TimeoutException {
      throw TimeoutException();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  // DELETE request
  Future<dynamic> delete(
    String endpoint, {
    bool requiresAuth = true,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      final headers = await _getHeaders(requiresAuth);

      final response = await _client
          .delete(uri, headers: headers)
          .timeout(ApiConstants.timeout);

      return _handleResponse(response);
    } on SocketException {
      throw NetworkException();
    } on TimeoutException {
      throw TimeoutException();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  // Multipart request (for file uploads)
  Future<dynamic> multipartRequest(
    String endpoint, {
    required String method,
    Map<String, String>? fields,
    Map<String, File>? files,
    bool requiresAuth = true,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      final request = http.MultipartRequest(method, uri);

      // Add headers
      final headers = await _getHeaders(requiresAuth, isMultipart: true);
      request.headers.addAll(headers);

      // Add fields
      if (fields != null) {
        request.fields.addAll(fields);
      }

      // Add files
      if (files != null) {
        for (final entry in files.entries) {
          final file = entry.value;
          final stream = http.ByteStream(file.openRead());
          final length = await file.length();
          final multipartFile = http.MultipartFile(
            entry.key,
            stream,
            length,
            filename: file.path.split('/').last,
            contentType: MediaType('application', 'octet-stream'),
          );
          request.files.add(multipartFile);
        }
      }

      final streamedResponse =
          await request.send().timeout(ApiConstants.timeout);
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } on SocketException {
      throw NetworkException();
    } on TimeoutException {
      throw TimeoutException();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  // Download file
  Future<List<int>> downloadFile(String endpoint) async {
    try {
      final uri = _buildUri(endpoint);
      final headers = await _getHeaders(true);

      final response = await _client
          .get(uri, headers: headers)
          .timeout(ApiConstants.timeout);

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw ServerException(message: 'Failed to download file');
      }
    } on SocketException {
      throw NetworkException();
    } on TimeoutException {
      throw TimeoutException();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  // Build URI
  Uri _buildUri(String endpoint, [Map<String, String>? queryParameters]) {
    final path = '${ApiConstants.baseUrl}$endpoint';
    if (queryParameters != null && queryParameters.isNotEmpty) {
      return Uri.parse(path).replace(queryParameters: queryParameters);
    }
    return Uri.parse(path);
  }

  // Get headers
  Future<Map<String, String>> _getHeaders(
    bool requiresAuth, {
    bool isMultipart = false,
  }) async {
    final headers = <String, String>{};

    if (!isMultipart) {
      headers['Content-Type'] = 'application/json';
    }

    if (requiresAuth) {
      final token = await SecureStorage.getToken();
      if (token == null) {
        throw AuthenticationException(message: 'No authentication token found');
      }
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // Handle response
  dynamic _handleResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        if (response.body.isEmpty) {
          return null;
        }
        try {
          return jsonDecode(response.body);
        } catch (e) {
          return response.body;
        }
      case 400:
        throw ValidationException(
          message: _parseErrorMessage(response) ?? 'Invalid request',
        );
      case 401:
        throw UnauthorizedException(
          message: _parseErrorMessage(response) ?? 'Unauthorized access',
        );
      case 404:
        throw NotFoundException(
          message: _parseErrorMessage(response) ?? 'Resource not found',
        );
      case 500:
      case 502:
      case 503:
        throw ServerException(
          message: _parseErrorMessage(response) ?? 'Server error',
        );
      default:
        throw ServerException(
          message: _parseErrorMessage(response) ??
              'Unexpected error: ${response.statusCode}',
        );
    }
  }

  // Parse error message from response
  String? _parseErrorMessage(http.Response response) {
    try {
      final body = jsonDecode(response.body);
      return body['message'] ?? body['error'] ?? body['detail'];
    } catch (e) {
      return null;
    }
  }

  // Dispose
  void dispose() {
    _client.close();
  }
}

