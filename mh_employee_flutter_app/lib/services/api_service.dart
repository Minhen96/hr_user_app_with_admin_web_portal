// lib/services/api_service.dart
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:mh_employee_app/core/storage/secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;
import 'dart:convert';

import 'package:mh_employee_app/shared/models/carousel_item.dart';
import 'package:mh_employee_app/features/change_request/data/models/change_request_model.dart';
import 'package:mh_employee_app/features/documents/data/models/document_model.dart';
import 'package:mh_employee_app/features/equipment/data/models/equipment_request_model.dart';
import 'package:mh_employee_app/features/calendar/data/models/event_model.dart';
import 'package:mh_employee_app/features/handbook/data/models/handbook_section.dart';
import 'package:mh_employee_app/features/calendar/data/models/holiday_model.dart';
import 'package:mh_employee_app/features/leave/data/models/leave_calendar_model.dart';
import 'package:mh_employee_app/features/moments/data/models/moment_model.dart';
import 'package:mh_employee_app/shared/models/news_item.dart';
import 'package:mh_employee_app/shared/models/quote_item.dart';
import 'package:mh_employee_app/shared/models/signature_data.dart';
import 'package:mh_employee_app/features/training/data/models/training_record_model.dart';
import 'package:mh_employee_app/features/auth/data/models/user_model.dart';
import 'package:mh_employee_app/shared/models/user_birthday.dart';
import 'package:mh_employee_app/features/moments/presentation/widgets/moment_creation_dialog.dart';
import 'package:mh_employee_app/core/constants/api_constants.dart';

class ApiService {
  // API base URLs
  static const String baseUrl = ApiConstants.baseUrl;
  static const String baseAdminUrl = ApiConstants.baseAdminUrl;

  // Timeout duration
  static const Duration timeoutDuration = ApiConstants.timeout;

  // Create http client with timeout (for all requests)
  static final http.Client _client = http.Client();

  // Headers with auth token
  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = await SecureStorage.getToken();
    if (token == null) {
      throw Exception('Authentication token not found');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Add a method to handle requests with improved error handling and timeout
  static Future<http.Response> sendRequestWithTimeout(
      Future<http.Response> Function() requestMethod) async {
    try {
      return await requestMethod().timeout(timeoutDuration,
          onTimeout: () => throw TimeoutException('Request timed out'));
    } on TimeoutException {
      print('Network request timed out');
      rethrow;
    } catch (e) {
      print('Network request error: $e');
      rethrow;
    }
  }

  static Exception _handleApiError(dynamic error, String operation) {
    if (error is SocketException) {
      return Exception('Network error: Unable to connect to server');
    } else if (error is TimeoutException) {
      return Exception('Request timeout: Please try again');
    } else if (error is FormatException) {
      return Exception('Invalid response format from server');
    } else if (error is http.ClientException) {
      return Exception('Network error: ${error.message}');
    } else {
      return Exception('$operation failed: ${error.toString()}');
    }
  }

  static Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final token = await SecureStorage.getToken();
      if (token == null) throw Exception('No token found');

      final response = await _client.get(
        Uri.parse('$baseUrl${ApiConstants.profile}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(timeoutDuration);

      print('Request URL: ${response.request?.url}'); // Debug log
      print('Response status: ${response.statusCode}');
      print('Response headers: ${response.headers}'); // Debug log
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          return responseData;
        } else {
          // Ensure a string error message
          throw Exception(
              responseData['message'] ?? 'Failed to get user profile');
        }
      } else {
        throw Exception('Failed to get user profile: ${response.statusCode}');
      }
    } catch (e) {
      // Ensure consistent error handling
      throw _handleApiError(e, 'Get User Profile');
    }
  }

  //20250122
  static Future<String> getUserNickname(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl${ApiConstants.nickname}/$userId'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['displayName'];
      } else {
        throw Exception('Failed to get nickname');
      }
    } catch (e) {
      throw Exception('Error getting nickname: $e');
    }
  }

  static Future<void> uploadProfilePicture(Uint8List profilePicture) async {
    try {
      final token = await SecureStorage.getToken();
      if (token == null) throw Exception('No token found');

      // Create a multipart request
      var request = http.MultipartRequest(
          'POST', Uri.parse('$baseUrl${ApiConstants.uploadProfilePicture}'));

      // Add authorization header
      request.headers['Authorization'] = 'Bearer $token';

      // Add the file to the request
      request.files.add(http.MultipartFile.fromBytes(
          'file', // This should match the parameter name in the backend
          profilePicture,
          filename: 'profile_picture.jpg'));

      // Send the request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      // Check the response
      if (response.statusCode == 200) {
        print('Profile picture uploaded successfully');
      } else {
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception(
            'Failed to upload profile picture: ${response.statusCode}');
      }
    } catch (e) {
      print('Error uploading profile picture: $e');
      rethrow;
    }
  }


  static Future<bool> updateNickname(String nickname) async {
    //20250117
    try {
      final response = await http.put(
        Uri.parse('$baseUrl${ApiConstants.updateNickname}'),
        headers: await _getHeaders(),
        body: json.encode({'nickname': nickname}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to update nickname: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error updating nickname: $e');
    }
  }

  // static Future<Map<String, dynamic>> validateToken(String token) async {
  //   try {
  //     final response = await _client.get(
  //       Uri.parse('$baseUrl/Auth/validate-token'),
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Authorization': 'Bearer $token'
  //       },
  //     ).timeout(timeoutDuration);
  //
  //     if (response.statusCode == 200) {
  //       final responseData = json.decode(response.body);
  //       return {
  //         'valid': responseData['valid'] ?? false,
  //         'user': responseData['user']
  //       };
  //     } else {
  //       throw Exception('Token validation failed');
  //     }
  //   } catch (e) {
  //     print("Token validation error: $e");
  //     throw Exception('Token validation failed');
  //   }
  // }

  static Future<Map<String, dynamic>> checkUserStatus(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl${ApiConstants.userStatus}/$userId'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        print(response.body);
        throw Exception('Unauthorized access');
      } else if (response.statusCode == 404) {
        print(response.body);
        throw Exception('User not found');
      } else {
        print(response.body);
        throw Exception(
            'Failed to check user status. Status code: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('Network error occurred');
    } catch (e) {
      throw Exception('Error checking user status: $e');
    }
  }

  static Future<Map<String, dynamic>> login(
      String email,
      String password) async {
    try {
      final response = await _client
          .post(
            Uri.parse('$baseUrl${ApiConstants.login}'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'email': email, 'password': password}),
          )
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success']) {
          // Save the auth token to secure storage
          final authToken = responseData['token'];

          await SecureStorage.saveToken(authToken);

          return responseData;
        } else {
          throw Exception(responseData['error'] ?? 'Login failed');
        }
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw _handleApiError(e, 'Login');
    }
  }

  // Register method
  static Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String password,
    required int departmentId,
    required String nric,
    required String birthday,
    String? tin,
    String? epfNo,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse('$baseUrl${ApiConstants.register}'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode({
              'fullName': fullName,
              'email': email,
              'password': password,
              'departmentId': departmentId,
              'nric': nric,
              'birthday': birthday,
              'tin': tin,
              'epfNo': epfNo,
            }),
          )
          .timeout(timeoutDuration);

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Registration failed');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> requestPasswordChange() async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('$baseUrl${ApiConstants.requestPasswordChange}');

      final response = await _client
          .post(
            uri,
            headers: headers,
          )
          .timeout(timeoutDuration);

      print('Request URL: ${response.request?.url}'); // Debug log
      print('Response status: ${response.statusCode}');
      print('Response headers: ${response.headers}'); // Debug log
      print('Response body: ${response.body}');

      if (response.statusCode != 200) {
        final error = json.decode(response.body);
        throw Exception(
            error['message'] ?? 'Failed to request password change');
      }
    } catch (e) {
      throw _handleApiError(e, 'Request password change');
    }
  }

  static Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('$baseUrl${ApiConstants.changePassword}');

      final response = await _client
          .post(
            uri,
            headers: headers,
            body: json.encode({
              'currentPassword': currentPassword,
              'newPassword': newPassword,
            }),
          )
          .timeout(timeoutDuration);

      print('Request URL: ${response.request?.url}'); // Debug log
      print('Response status: ${response.statusCode}');
      print('Response headers: ${response.headers}'); // Debug log
      print('Response body: ${response.body}');

      if (response.statusCode != 200) {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to change password');
      }
    } catch (e) {
      throw _handleApiError(e, 'Change password');
    }
  }



  // api_service.dart - Add these methods to your existing ApiService class
static Future<List<CarouselItem>> getCarouselContent() async {
  try {
    final response = await _client
        .get(
      Uri.parse('$baseUrl${ApiConstants.quoteCarousel}'),
      headers: await _getHeaders(),
    )
        .timeout(timeoutDuration);

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);

      // Handle both single object and list responses
      final List<dynamic> data =
          decoded is List ? decoded : [decoded];

      return data.map((item) {
        if (item['carouselType'] == 'Quote') {
          return QuoteItem.fromJson(item);
        } else {
          return CarouselItem.fromJson(item);
        }
      }).toList();

    } else if (response.statusCode == 404) {
      // Graceful handling for empty data
      return [];
    } else {
      throw Exception('Failed to load carousel content: ${response.statusCode}');
    }

  } catch (e) {
    throw _handleApiError(e, 'Get Carousel Content');
  }
}


  static String getCarouselTitle(String type) {
    switch (type) {
      case 'Vision':
        return 'Vision';
      case 'Mission':
        return 'Mission';
      case 'Values':
        return 'Values';
      case 'Target':
        return 'Target';
      default:
        return type;
    }
  }

  static String getCarouselTitleCn(String type) {
    switch (type) {
      case 'Vision':
        return '愿景';
      case 'Mission':
        return '使命';
      case 'Values':
        return '我们的价值观';
      case 'Target':
        return '目标';
      default:
        return type;
    }
  }

  static String getDefaultImageUrl(String type) {
    return 'assets/images/${type.toLowerCase()}.jpg';
  }

  static Future<CarouselItem> updateCarouselContent(
      String carouselType,
      String text,
      String textCn,
      Uint8List? imageBytes,
      String editorUsername,
      ) async {
    try {
      final headers = await _getHeaders();
      headers.remove('Content-Type');

      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('$baseUrl/Quote/carousel-content/$carouselType'),
      );

      request.fields.addAll({
        'text': text,
        'textCn': textCn,
        'editorUsername': editorUsername,
        'carouselType': carouselType,
      });

      if (imageBytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'image',
            imageBytes,
            filename: 'carousel_image.jpg',
          ),
        );
      }

      request.headers.addAll(headers);
      final streamedResponse = await request.send().timeout(timeoutDuration);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return CarouselItem.fromJson(data);
      } else {
        throw Exception('Failed to update carousel content: ${response.body}');
      }
    } catch (e) {
      throw _handleApiError(e, 'Update Carousel Content');
    }
  }

  static Future<Uint8List?> fetchUserGuidePDF() async {
    final uri = Uri.parse('$baseAdminUrl${ApiConstants.handbookUserGuide}');

    try {
      final response = await _client.get(uri);

      if (response.statusCode == 200) {
        // Check if response is empty or too small to be a valid PDF
        if (response.bodyBytes.isEmpty || response.bodyBytes.length < 100) {
          print('Received empty or invalid PDF response');
          return null;
        }
        return response.bodyBytes;
      } else {
        print(
            'Failed to fetch user guide PDF. Status code: ${response.statusCode}');
        return null; // Return null instead of throwing
      }
    } catch (e) {
      print('Error fetching user guide PDF: $e');
      return null; // Return null instead of rethrowing
    }
  }

  Future<List<HandbookSection>> getSections() async {
    try {
      print('Fetching sections from: http://localhost:5000/admin/api/Handbook'); // Debug log

      final response = await _client.get(
        Uri.parse('$baseAdminUrl${ApiConstants.handbookSections}'),
        headers: {'Accept': 'application/json'},
      ).timeout(timeoutDuration);

      print('Response status: ${response.statusCode}'); // Debug log
      print('Response body: ${response.body}'); // Debug log

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data
            .map((section) => HandbookSection.fromJson(section))
            .toList();
      } else {
        throw Exception(
            'Failed to load handbook sections: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching sections: $e'); // Debug log
      throw Exception('Failed to load handbook sections: ${e.toString()}');
    }
  }

  Future<HandbookSection> getSection(int id) async {
    try {
      print('Fetching section $id from: http://localhost:5000/admin/api/Handbook/$id'); // Debug log

      final response = await _client.get(
        Uri.parse('$baseAdminUrl${ApiConstants.handbookSection}/$id'),
        headers: {'Accept': 'application/json'},
      ).timeout(timeoutDuration);

      print('Response status: ${response.statusCode}'); // Debug log
      print('Response body: ${response.body}'); // Debug log

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return HandbookSection.fromJson(data);
      } else {
        throw Exception(
            'Failed to load section details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching section $id: $e'); // Debug log
      throw Exception('Failed to load section details: ${e.toString()}');
    }
  }

  static Future<List<UserBirthday>> getBirthdays(int month) async {
    final requestUrl = '$baseAdminUrl${ApiConstants.birthday}?month=$month';
    print('Requesting URL: $requestUrl'); // Debug log

    try {
      final response = await _client.get(
        Uri.parse(requestUrl),
        headers: {
          'Accept': 'application/json',
          // Add your authorization header if needed
          // 'Authorization': 'Bearer $token',
        },
      ).timeout(timeoutDuration);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        List<dynamic> birthdayJson = json.decode(response.body);
        return birthdayJson.map((json) => UserBirthday.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load birthdays: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching birthdays: $e');
      rethrow;
    }
  }

  static Future<List<Holiday>> getHolidays(int year, int month) async {
    final requestUrl = '$baseAdminUrl${ApiConstants.holiday}?year=$year&month=$month';
    print('Requesting URL: $requestUrl'); // Debug log

    try {
      final response = await _client.get(
        Uri.parse(requestUrl),
        headers: {
          'Accept': 'application/json',
          // Add your authorization header if needed
          // 'Authorization': 'Bearer $token',
        },
      ).timeout(timeoutDuration);

      print('Request URL: ${response.request?.url}'); // Debug log
      print('Response status: ${response.statusCode}');
      print('Response headers: ${response.headers}'); // Debug log
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        List<dynamic> holidayJson = json.decode(response.body);
        return holidayJson.map((json) => Holiday.fromJson(json)).toList();
      } else {
        throw Exception(
            'Failed to load holidays: ${response.statusCode}\nURL: $requestUrl');
      }
    } catch (e) {
      print(
          'Error fetching holidays: $e\nURL: $requestUrl'); // Enhanced error logging
      rethrow;
    }
  }

  static Future<List<Event>> getEvents(DateTime date) async {
    try {
      final uri = Uri.parse('$baseUrl/Events?date=${date.toIso8601String()}');

      final response = await _client.get(
        uri,
        headers: await _getHeaders(),
      ).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => Event.fromJson(e)).toList();
      } 
      else if (response.statusCode == 404) {
        // Graceful handling: no events found
        print('No events found for this date');
        return []; // return empty list
      } 
      else if (response.statusCode == 401) {
        // Token invalid or expired
        throw Exception('Unauthorized: Please login again');
      } 
      else {
        throw Exception('Unexpected error: ${response.statusCode}');
      }
    } 
    catch (e) {
      // Handle network or parsing errors gracefully
      print('Error fetching events: $e');
      return []; // fallback to empty list, so UI doesn’t break
    }
  }


  static Future<List<Event>> getMonthEvents(int year, int month) async {
    final response = await _client
        .get(Uri.parse('$baseUrl${ApiConstants.eventsMonth}?year=$year&month=$month'), headers: await _getHeaders());

    print('Request URL: ${response.request?.url}'); // Debug log
    print('Response status: ${response.statusCode}');
    print('Response headers: ${response.headers}'); // Debug log
    print('Response body: ${response.body}');
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((event) => Event.fromJson(event)).toList();
    } else {
      throw Exception('Failed to load month events');
    }
  }

  static Future<Event> createEvent(Event event) async {
    final headers = await _getHeaders();

    // Create a map that matches the server's expected structure
    // userId is extracted from JWT token on backend
    final eventData = {
      'title': event.title,
      'description': event.description ?? '',
      'date': event.date.toIso8601String(),
    };

    final response = await _client.post(
      Uri.parse('$baseUrl${ApiConstants.events}'),
      headers: await _getHeaders(),
      body: json.encode(eventData),
    );

    if (response.statusCode == 201) {
      return Event.fromJson(json.decode(response.body));
    } else {
      // Include the response body in the error for more context
      throw Exception('Failed to create event: ${response.body}');
    }
  }


  static Future<Event> updateEvent(Event event) async {
    final headers = await _getHeaders();

    final eventData = {
      'id': event.id,
      'title': event.title,
      'description': event.description ?? '',
      'date': event.date.toIso8601String(),
      'user_id': event.userId,
      'updated_at': DateTime.now().toIso8601String(),
    };

    final response = await _client.put(
      Uri.parse('$baseUrl/Events/${event.id}'),
      headers: {
        ...headers,
        'Content-Type': 'application/json; charset=utf-8',
      },
      body: json.encode(eventData),
    );

    if (response.statusCode == 200) {
      return Event.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update event: ${response.body}');
    }
  }

  static Future<void> deleteEvent(int eventId) async {
    final headers = await _getHeaders();

    final response = await _client.delete(
      Uri.parse('$baseUrl/Events/$eventId'),
      headers: headers,
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete event: ${response.body}');
    }
  }




static Future<EquipmentRequest> createEquipmentRequest({
  required List<EquipmentItem> items,
  required SignatureData signatureData,
}) async {
  try {
    final headers = await _getHeaders();

    final requestBody = {
      'items': items.map((item) => item.toJson()).toList(),
      'signature': {
        'points': signatureData.points
            .map((offset) => SignaturePoint(offset.dx, offset.dy).toJson())
            .toList(),
        'boundaryWidth': signatureData.boundarySize.width,
        'boundaryHeight': signatureData.boundarySize.height,
      },
    };

    final response = await _client
        .post(
          Uri.parse('$baseAdminUrl${ApiConstants.equipmentRequests}'),
          headers: headers,
          body: json.encode(requestBody),
        )
        .timeout(timeoutDuration);

    print('Request URL: ${response.request?.url}');
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return EquipmentRequest.fromJson(json.decode(response.body));
    } else {
      throw Exception(
        'Failed to create equipment request. Status: ${response.statusCode}',
      );
    }
  } catch (e) {
    throw _handleApiError(e, 'Create request');
  }
}



  static Future<List<EquipmentRequest>> getEquipmentRequests(
      {String? status}) async {
    try {
      final headers = await _getHeaders();
      final queryParams = status != null ? {'status': status} : null;

      final uri = Uri.parse('$baseAdminUrl${ApiConstants.equipmentRequests}')
          .replace(queryParameters: queryParams);

      final response =
          await _client.get(uri, headers: headers).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => EquipmentRequest.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch requests: ${response.statusCode}');
      }
    } catch (e) {
      throw _handleApiError(e, 'Fetch requests');
    }
  }

  static Future<void> updateReceivedDetails({
    required int requestId,
    required String receivedDetails,
  }) async {
    try {
      final headers = await _getHeaders();

      final response = await _client
          .put(
            Uri.parse('$baseAdminUrl${ApiConstants.equipmentReceived}/$requestId/received'),
            headers: headers,
            body: json.encode({
              'receivedDetails': receivedDetails,
            }),
          )
          .timeout(timeoutDuration);

      if (response.statusCode != 200) {
        final errorBody = json.decode(response.body);
        throw Exception(
            errorBody['message'] ?? 'Failed to update received details');
      }
    } catch (e) {
      throw _handleApiError(e, 'Update received details');
    }
  }

  static Future<int> createSignature(SignatureData signatureData) async {
    final url = Uri.parse('$baseUrl${ApiConstants.changeRequestSignature}');
    final headers = await _getHeaders();

    final body = {
      'points': signatureData.points
          .map((offset) => SignaturePoint(
                offset.dx,
                offset.dy,
              ).toJson())
          .toList(),
      'boundaryWidth': signatureData.boundarySize.width,
      'boundaryHeight': signatureData.boundarySize.height,
    };

    try {
      final response = await _client
          .post(
            url,
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(timeoutDuration);

      if (response.statusCode == 201) {
        // Parse response body to extract the signature ID
        final responseData = jsonDecode(response.body);
        return responseData['id'];
      } else {
        throw Exception(
          'Failed to create signature: ${response.statusCode} ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      throw Exception('Error creating signature: $e');
    }
  }

  static Future<Map<String, dynamic>> createChangeRequest({
    required int requesterId,
    required String reason,
    required String description,
    required String risk,
    required String instruction,
    required String postReview,
    required int signatureId,
    DateTime? completeDate,
  }) async {
    try {
      final headers = await _getHeaders();
      final body = jsonEncode({
        'requesterId': requesterId,
        'reason': reason,
        'description': description,
        'risk': risk,
        'instruction': instruction,
        'postReview': postReview,
        'signatureId': signatureId,
        'completeDate': completeDate?.toIso8601String(),
      });

      final response = await _client
          .post(
            Uri.parse('$baseUrl${ApiConstants.changeRequests}'),
            headers: headers,
            body: body,
          )
          .timeout(timeoutDuration);

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to create change request: ${response.body}');
      }
    } catch (e) {
      throw _handleApiError(e, 'Create change request');
    }
  }

  static Future<void> requestChangeRequestReturn(int changeRequestId) async {
    try {
      final headers = await _getHeaders();
      final response = await _client
          .put(
            Uri.parse('$baseUrl${ApiConstants.changeRequestReturn}/$changeRequestId'),
            headers: headers,
          )
          .timeout(timeoutDuration);

      if (response.statusCode != 200) {
        throw Exception('Failed to request return: ${response.body}');
      }
    } catch (e) {
      throw _handleApiError(e, 'Request change request return');
    }
  }

  static Future<List<dynamic>> getAllUserChangeRequests(int userId) async {
    try {
      final headers = await _getHeaders();
      final response = await _client
          .get(
            Uri.parse('$baseUrl${ApiConstants.changeRequestUser}/$userId/all'),
            headers: headers,
          )
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'Failed to fetch all change requests: ${response.body}');
      }
    } catch (e) {
      throw _handleApiError(e, 'Fetch all change requests');
    }
  }

  static Future<Map<String, dynamic>> getChangeRequestDetails(
      int changeRequestId) async {
    try {
      final headers = await _getHeaders();
      final response = await _client
          .get(
            Uri.parse('$baseUrl${ApiConstants.changeRequests}/$changeRequestId'),
            headers: headers,
          )
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'Failed to fetch change request details: ${response.body}');
      }
    } catch (e) {
      throw _handleApiError(e, 'Fetch change request details');
    }
  }

  static Future<List<TrainingCourse>> getTrainingCourses(
      {String? status}) async {
    try {
      final headers = await _getHeaders();
      final queryParams = status != null ? {'status': status} : null;

      final uri = Uri.parse('$baseAdminUrl${ApiConstants.trainings}')
          .replace(queryParameters: queryParams);

      final response =
          await _client.get(uri, headers: headers).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => TrainingCourse.fromJson(json)).toList();
      } else {
        throw Exception(
            'Failed to fetch training courses: ${response.statusCode}');
      }
    } catch (e) {
      throw _handleApiError(e, 'Fetch training courses');
    }
  }

  static Future<TrainingCourse> createTrainingCourse({
    required String title,
    required String description,
    required DateTime date,
    required List<Uint8List> certificates,
    required List<String> fileNames,
  }) async {
    try {
      final headers = await _getHeaders();
      headers.remove('Content-Type');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseAdminUrl${ApiConstants.trainings}'),
      );

      request.fields['title'] = title;
      request.fields['description'] = description;
      request.fields['courseDate'] = date.toIso8601String();

      // Add certificates
      for (var i = 0; i < certificates.length; i++) {
        final fileName = fileNames[i];
        // final extension = extension(fileName).toLowerCase();
        final extension = path.extension(fileName).toLowerCase();

        request.files.add(
          http.MultipartFile.fromBytes(
            'certificates',
            certificates[i],
            filename: fileName,
            contentType: MediaType(
              _getMediaType(extension),
              extension.replaceAll('.', ''),
            ),
          ),
        );
      }

      request.headers.addAll(headers);

      final streamedResponse = await request.send().timeout(timeoutDuration);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        return TrainingCourse.fromJson(json.decode(response.body));
      } else {
        throw Exception(
            'Failed to create training course: ${response.statusCode}');
      }
    } catch (e) {
      throw _handleApiError(e, 'Create training course');
    }
  }

  static Future<Uint8List> downloadCertificate(int certificateId) async {
    try {
      final headers = await _getHeaders();
      final response = await _client
          .get(
            Uri.parse('$baseAdminUrl${ApiConstants.trainingCertificate}/$certificateId'),
            headers: headers,
          )
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception(
            'Failed to download certificate: ${response.statusCode}');
      }
    } catch (e) {
      throw _handleApiError(e, 'Download certificate');
    }
  }

  static Future<TrainingCourse> updateTrainingCourse({
    required String id,
    required String title,
    required String description,
    required DateTime date,
    required List<File> newCertificates,
  }) async {
    try {
      final headers = await _getHeaders();
      headers.remove('Content-Type');

      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('$baseAdminUrl${ApiConstants.trainings}/$id'),
      );

      request.fields['title'] = title;
      request.fields['description'] = description;
      request.fields['courseDate'] = date.toIso8601String();

      // Add new certificates
      for (var certificate in newCertificates) {
        final fileName = certificate.path.split('/').last;
        final extension = fileName.split('.').last.toLowerCase();

        request.files.add(
          await http.MultipartFile.fromPath(
            'newCertificates',
            certificate.path,
            contentType: MediaType(
              _getMediaType(extension),
              extension,
            ),
          ),
        );
      }

      request.headers.addAll(headers);

      final streamedResponse = await request.send().timeout(timeoutDuration);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return TrainingCourse.fromJson(json.decode(response.body));
      } else {
        throw Exception(
            'Failed to update training course: ${response.statusCode}');
      }
    } catch (e) {
      throw _handleApiError(e, 'Update training course');
    }
  }

  static Future<void> deleteTrainingCourse(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await _client
          .delete(
            Uri.parse('$baseAdminUrl${ApiConstants.trainings}/$id'),
            headers: headers,
          )
          .timeout(timeoutDuration);

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to delete training course: ${response.statusCode}');
      }
    } catch (e) {
      throw _handleApiError(e, 'Delete training course');
    }
  }

  static String _getMediaType(String extension) {
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      default:
        return 'application/octet-stream';
    }
  }

  static Future<QuoteItem?> getQuote() async {
    try {
      final response = await _client
          .get(
            Uri.parse('$baseUrl${ApiConstants.quote}'),
            headers: await _getHeaders(),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Handle both single object and array responses
        if (data is List) {
          if (data.isEmpty) return null;
          return QuoteItem.fromJson(data[0]);
        } else if (data is Map<String, dynamic>) {
          return QuoteItem.fromJson(data);
        } else {
          print('Unexpected quote response format: ${data.runtimeType}');
          return null;
        }
      } else if (response.statusCode == 404) {
        // No quote available - not an error
        print('No quote available (404)');
        return null;
      } else if (response.statusCode == 401) {
        // Not authorized - not an error, just log
        print('Quote requires authentication (401)');
        return null;
      } else {
        throw Exception('Failed to fetch quote: ${response.statusCode}');
      }
    } catch (e) {
      print('Note: Could not fetch quote (this is normal if no data or auth required): $e');
      return null; // Return null instead of throwing
    }
  }

  static Future<List<QuoteView>> getQuoteViews(int quoteId) async {
    try {
      final response = await _client
          .get(
            Uri.parse('$baseUrl/Quote/$quoteId/views'),
            headers: await _getHeaders(),
          )
          .timeout(const Duration(seconds: 10));

      print('Request URL: ${response.request?.url}'); // Debug log
      print('Response status: ${response.statusCode}');
      print('Response headers: ${response.headers}'); // Debug log
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data.map((v) => QuoteView.fromJson(v)).toList();
      } else {
        throw Exception('Failed to fetch quote views: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching quote views: $e');
    }
  }

  static Future<List<QuoteReaction>> getQuoteReactions(int quoteId) async {
    try {
      final response = await _client
          .get(
            Uri.parse('$baseUrl/Quote/$quoteId/reactions'),
            headers: await _getHeaders(),
          )
          .timeout(const Duration(seconds: 10));

      print('Request URL: ${response.request?.url}'); // Debug log
      print('Response status: ${response.statusCode}');
      print('Response headers: ${response.headers}'); // Debug log
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data.map((r) => QuoteReaction.fromJson(r)).toList();
      } else {
        throw Exception(
            'Failed to fetch quote reactions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching quote reactions: $e');
    }
  }


  static Future<void> updateQuote(
      int id,
      String text,
      String textCn,
      String editorUsername,
      ) async {
    try {
      final response = await _client
          .post(
        Uri.parse('$baseUrl${ApiConstants.quote}'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'id': id,
          'text': text.trim(),
          'textCn': textCn.trim(),
          'editorUsername': editorUsername.trim(),
        }),
      )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception('Failed to update quote: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating quote: $e');
    }
  }

  static Future<QuoteItem> updateQuoteWithImage(
      int id,
      String text,
      String textCn,
      String editorUsername,
      Uint8List? imageBytes,
      ) async {
    try {
      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('$baseUrl/Quote/quote/$id'),
      );

      // Add fields with null checks
      request.fields.addAll({
        'text': text.trim(),
        'textCn': textCn.trim(),
        'editorUsername': editorUsername.trim(),
        'carouselType': 'Quotes',
      });

      if (imageBytes != null) {
        try {
          request.files.add(http.MultipartFile.fromBytes(
            'image',
            imageBytes,
            filename: 'quote_image_${DateTime.now().millisecondsSinceEpoch}.jpg', // Add filename
            contentType: MediaType('image', 'jpeg'), // Add content type
          ));
        } catch (e) {
          throw Exception('Error attaching image: $e');
        }
      }

      final headers = await _getHeaders();
      headers.remove('Content-Type'); // Remove Content-Type header for multipart request
      request.headers.addAll(headers);

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Request timed out');
        },
      );

      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        try {
          final decodedResponse = json.decode(response.body);
          return QuoteItem.fromJson(decodedResponse);
        } catch (e) {
          throw Exception('Error parsing response: $e\nResponse body: ${response.body}');
        }
      } else {
        throw Exception(
            'Server returned ${response.statusCode}: ${response.body}\n'
                'Request URL: ${request.url}\n'
                'Fields: ${request.fields}'
        );
      }
    } catch (e) {
      print('Error in updateQuoteWithImage: $e');
      rethrow;
    }
  }

  static Future<void> addView(
    int quoteId,
    String username,
  ) async {
    try {
      final response = await _client
          .post(
            Uri.parse('$baseUrl/Quote/$quoteId/view'),
            headers: await _getHeaders(),
            body: jsonEncode({
              'viewedBy': username,
            }),
          )
          .timeout(const Duration(seconds: 10));

      print('Request URL: ${response.request?.url}'); // Debug log
      print('Response status: ${response.statusCode}');
      print('Response headers: ${response.headers}'); // Debug log
      print('Response body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Failed to add view: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error adding view: $e');
    }
  }

  static Future<void> addAutoView(
    int quoteId,
    String username,
  ) async {
    try {
      final response = await _client
          .post(
            Uri.parse('$baseUrl/Quote/$quoteId/auto-view'),
            headers: await _getHeaders(),
            body: jsonEncode({
              'viewedBy': username,
            }),
          )
          .timeout(const Duration(seconds: 10));

      print('Request URL: ${response.request?.url}'); // Debug log
      print('Response status: ${response.statusCode}');
      print('Response headers: ${response.headers}'); // Debug log
      print('Response body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Failed to add auto view: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error adding auto view: $e');
    }
  }

  static Future<void> addReaction(
    int quoteId,
    String username,
    String reaction,
  ) async {
    try {
      final response = await _client
          .post(
            Uri.parse('$baseUrl/Quote/$quoteId/reaction'),
            headers: await _getHeaders(),
            body: jsonEncode({
              'username': username,
              'reaction': reaction,
            }),
          )
          .timeout(const Duration(seconds: 10));

      print('Request URL: ${response.request?.url}'); // Debug log
      print('Response status: ${response.statusCode}');
      print('Response headers: ${response.headers}'); // Debug log
      print('Response body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Failed to add reaction: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error adding reaction: $e');
    }
  }

  static Future<PagedResponse<Moment>> getMoments({
    int page = 1,
    int pageSize = 3,
  }) async {
    final queryParams = {
      'page': page.toString(),
      'pageSize': pageSize.toString(),
    };

    final uri =
        Uri.parse('$baseUrl${ApiConstants.moments}').replace(queryParameters: queryParams);
    final headers = await _getHeaders();

    print(page.toString());
    print(pageSize.toString());

    try {
      final response = await _client
          .get(
            uri,
            headers: headers,
          )
          .timeout(
            Duration(seconds: 20),
            onTimeout: () =>
                throw TimeoutException('Network request timed out'),
          );
      print('Request1 URL: ${response.request?.url}');
      print('Response1 status: ${response.statusCode}');
      print('Response1 headers: ${response.headers}');
      print('Response1 body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return PagedResponse<Moment>.fromJson(
          responseData,
          (json) => Moment.fromJson(json),
        );
      } else {
        throw HttpException('Failed to load moments: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading moments xx: $e');
      rethrow;
    }
  }

  static Future<Moment> createMoment({//20250205
    required String title,
    required String description,
    required List<MediaItem> media,
  }) async {
    try {
      final headers = await _getHeaders();
      headers.remove('Content-Type');

      var request =
      http.MultipartRequest('POST', Uri.parse('$baseUrl${ApiConstants.moments}'));
      request.fields['title'] =
          title; // Use lowercase 'title' if the API expects it
      request.fields['description'] = description;

      // Add all media files
      for (var mediaItem in media) {
        if (mediaItem.file == null) {
          throw Exception('MediaItem file is null');
        }
        final bytes = await mediaItem.file.readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes(
            'Media', // Use 'mediaFiles' if the API expects it
            bytes,
            filename: mediaItem.file.name,
          ),
        );
      }

      request.headers.addAll(headers);
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        print(response.statusCode);
        print(response.body);
        final momentJson = json.decode(response.body);

        return Moment.fromJson(momentJson);
      } else {
        throw HttpException('Failed to create moment: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception(
        e,
      );
    }
  }

  //upload moment img into backend 3/12/2024
  Future<void> uploadMomentImage(Uint8List imageBytes) async {
    try {
      final headers = await _getHeaders();
      headers.remove('Content-Type');

      var request = http.MultipartRequest(
          'POST', Uri.parse('$baseUrl${ApiConstants.momentsUploadImage}'));
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: 'image.jpg',
        ),
      );

      request.headers.addAll(headers);

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final responseJson = json.decode(response.body);
        print('Image uploaded successfully: ${responseJson['ImagePath']}');
      } else {
        throw HttpException('Failed to upload image: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<MomentReaction>> reactToMoment({
    required int momentId,
    required String reactionType,
  }) async {
    try {
      final headers = await _getHeaders();

      final response = await _client.post(
        Uri.parse('$baseUrl${ApiConstants.momentsReactions}/$momentId/reactions'),
        body: json.encode({'reactionType': reactionType}),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return (responseData as List)
            .map((json) => MomentReaction.fromJson(json))
            .toList();
      } else {
        throw HttpException('Failed to add reaction: ${response.statusCode}');
      }
    } catch (e) {
      throw HttpException('Error adding reaction: $e');
    }
  }


  static Future<Map<String, dynamic>> reportMoment({
    required int momentId,
    required String reportType,
  }) async {
    final uri = Uri.parse('$baseUrl${ApiConstants.momentsReports}/$momentId/reports');
    final headers = {
      'Content-Type': 'application/json',
      ...(await _getHeaders()),
    };

    try {
      final response = await _client.post(
        uri,
        headers: headers,
        body: json.encode({'reportType': reportType}),
      );

      if (response.statusCode != 200 && response.statusCode != 400) {
        throw HttpException('Failed to report moment: ${response.statusCode}');
      }

      final responseData = json.decode(response.body);

      if (response.statusCode == 400) {
        return {
          'status': 'AlreadyReported',
          'message': responseData['Message'] ?? responseData['message'],
          'reportDate': responseData['ReportDate'] ?? responseData['reportDate'],
        };
      }

      return {
        'status': 'Success',
        'message': responseData['Message'] ?? responseData['message'],
      };
    } catch (e) {
      print('API Error: $e');
      throw HttpException('Error reporting moment: $e');
    }
  }




  static Future<int> getUnreadCount() async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('$baseUrl${ApiConstants.documentsUnreadCount}');

      final response = await _client.get(uri, headers: headers);

      if (response.statusCode == 200) {
        return int.parse(response.body);
      }
      throw Exception('Failed to get unread count');
    } catch (e) {
      throw _handleApiError(e, 'Get unread count');
    }
  }

  static Future<void> markAsRead(int docId) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('$baseUrl${ApiConstants.documentsMarkRead}/$docId/mark-read');

      final response =
      await _client.post(uri, headers: headers).timeout(timeoutDuration);

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to mark document as read: ${response.statusCode}');
      }
    } catch (e) {
      throw _handleApiError(e, 'Mark document as read');
    }
  }

  static Future<PaginatedResponse<NewsItem>> getUpdateDocuments({
    int page = 1,
    int? year,
    int? month,
  }) async {
    try {
      final headers = await _getHeaders();
      final queryParams = {
        'type': 'UPDATES',
        'page': page.toString(),
      };

      if (year != null && month != null) {
        queryParams['year'] = year.toString();
        queryParams['month'] = month.toString();
      }

      final endpoint = (year != null && month != null)
          ? '$baseUrl/Document/updates/history'
          : '$baseUrl/Document/updates';

      final uri = Uri.parse(endpoint).replace(queryParameters: queryParams);

      final response =
      await _client.get(uri, headers: headers).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        print("News: ${response.body}");

        return PaginatedResponse.fromJson(json, (item) {
          return NewsItem(
              id: item['id'],
              title: item['title'] ?? '',
              content: item['content'] ?? '',
              datePosted: DateTime.parse(item['postDate']),
              author: item['posterName'] ?? 'Unknown Author',
              isRead: item['isRead'] ?? false, // This will now persist properly
              uid: item['userid']);
        });
      } else {
        throw Exception(
            'Failed to fetch update documents: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getUpdateDocuments: $e');
      throw _handleApiError(e, 'Fetch update documents');
    }
  }

  static Future<void> addUpdateDocument(Map<String, dynamic> data) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('$baseUrl${ApiConstants.documentsUpdates}');

      // We don't need to send departmentId as it will be derived from the current user in backend
      final response = await _client
          .post(
        uri,
        headers: headers,
        body: jsonEncode({
          'title': data['title'],
          'content': data['content'],
          'type': 'UPDATES',
        }),
      )
          .timeout(timeoutDuration);

      if (response.statusCode != 201) {
        throw Exception(
            'Failed to add update document: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in addUpdateDocument: $e');
      throw _handleApiError(e, 'Add update document');
    }
  }

  static Future<void> editUpdateDocument(
      int id, Map<String, dynamic> data) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('$baseUrl/Document/updates/$id');

      final response = await _client
          .put(
        uri,
        headers: headers,
        body: jsonEncode(data),
      )
          .timeout(timeoutDuration);

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to edit update document: ${response.statusCode}');
      }
    } catch (e) {
      throw _handleApiError(e, 'Edit update document');
    }
  }

  static Future<void> deleteUpdateDocument(int id) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('$baseAdminUrl/Updates/$id');

      final response = await _client
          .delete(
        uri,
        headers: headers,
      )
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        return;
      } else if (response.statusCode == 404) {
        throw Exception('Document not found');
      } else if (response.statusCode == 403) {
        throw Exception('You don\'t have permission to delete this document');
      } else {
        throw Exception(
            'Failed to delete update document: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error in deleteUpdateDocument: $e');
      throw _handleApiError(e, 'Delete update document');
    }
  }

  static Future<PaginatedResponse<Document>> getDocuments({
    String? type,
    int page = 1,
  }) async {
    try {
      final headers = await _getHeaders();
      final queryParams = {
        if (type != null) 'type': type,
        'page': page.toString(),
      };

      final uri =
      Uri.parse('$baseUrl/Document').replace(queryParameters: queryParams);

      final response =
      await _client.get(uri, headers: headers)
          .timeout(
        Duration(seconds: 20),
        onTimeout: () =>
        throw TimeoutException('Network request timed out'),
      );

      // Debug print the full response
      print('Request URL: ${response.request?.url}');
      print('Response status: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        // Debug print the parsed JSON
        final json = jsonDecode(response.body);

        // Check if the JSON is already a List or a Map
        if (json is List) {
          // If it's a list, wrap it in a map to match PaginatedResponse
          return PaginatedResponse.fromJson({
            'items': json,
            'currentPage': page,
            'totalPages': 1, // Default value if not provided
            'totalCount': json.length
          }, (item) => Document.fromJson(item));
        } else if (json is Map<String, dynamic>) {
          // If it's already a map, use it directly
          return PaginatedResponse.fromJson(
              json, (item) => Document.fromJson(item));
        } else {
          throw Exception('Unexpected JSON format: ${json.runtimeType}');
        }
      } else {
        throw Exception('Failed to fetch documents: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getDocuments: $e');
      throw _handleApiError(e, 'Fetch documents');
    }
  }

  static Future<Map<String, int>> getDocumentUnreadCounts() async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('$baseUrl${ApiConstants.documentUnreadCounts}');

      final response = await _client.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data.map((key, value) => MapEntry(key, value as int));
      }
      throw Exception('Failed to get unread counts');
    } catch (e) {
      throw _handleApiError(e, 'Get document unread counts');
    }
  }

  static Future<void> markDocumentAsRead(int docId) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('$baseUrl/Document/$docId/mark-read');

      final response = await _client.post(uri, headers: headers);

      if (response.statusCode != 200) {
        throw Exception('Failed to mark document as read');
      }
    } catch (e) {
      throw _handleApiError(e, 'Mark document as read');
    }
  }

  static Future<Document> getDocument(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await _client
          .get(
        Uri.parse('$baseUrl/Document/$id'),
        headers: headers,
      )
          .timeout(timeoutDuration);

      // Debug print the full response
      print('Request URL: ${response.request?.url}');
      print('Response status: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        // Add some logging to verify file type
        final jsonResponse = json.decode(response.body);
        print('Document JSON: $jsonResponse');

        return Document.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to fetch document: ${response.statusCode}');
      }
    } catch (e) {
      throw _handleApiError(e, 'Fetch document');
    }
  }


  static Future<void> downloadToCustomLocation(
    int documentId,
    String savePath,
    Function(int received, int total) onProgress,
  ) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/Document/$documentId/download');

      final response = await _client.send(
        http.Request('GET', url)..headers.addAll(headers),
      );

      if (response.statusCode == 200) {
        final contentLength = response.contentLength ?? 0;
        int received = 0;
        final file = File(savePath);
        final sink = file.openWrite();

        await response.stream.forEach((chunk) {
          sink.add(chunk);
          received += chunk.length;
          onProgress(received, contentLength);
        });

        await sink.close();

        if (contentLength > 0 && received != contentLength) {
          throw Exception('Download incomplete');
        }
      } else {
        throw Exception('Failed to download: ${response.statusCode}');
      }
    } catch (e) {
      print('Download service error: $e');
      rethrow;
    }
  }

  static Future<List<LeaveCalendar>> getLeaveCalendar(
      int year, int month) async {
    final requestUrl = '$baseUrl${ApiConstants.leaveCalendar}?year=$year&month=$month';
    print('Requesting URL: $requestUrl');

    try {
      final headers = await _getHeaders();
      final response = await _client
          .get(
            Uri.parse(requestUrl),
            headers: headers,
          )
          .timeout(timeoutDuration);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        List<dynamic> leaveJson = json.decode(response.body);
        return leaveJson.map((json) => LeaveCalendar.fromJson(json)).toList();
      } else {
        throw Exception(
            'Failed to load leave calendar: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching leave calendar: $e');
      rethrow;
    }
  }


  static final Map<int, bool> _readStatusCache = {};

  static Future<void> markEventAsRead(int eventId) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('$baseUrl/Events/$eventId/mark-read');

      // Add error handling for existing read status
      if (_readStatusCache[eventId] == true) {
        return; // Event already marked as read, skip API call
      }

      final response = await _client.post(
          uri,
          headers: headers,
          body: json.encode({
            'eventId': eventId,
            'readDate': DateTime.now().toIso8601String()
          })
      );

      if (response.statusCode == 200) {
        _readStatusCache[eventId] = true;
      } else if (response.statusCode == 409) {
        // Handle conflict - event already marked as read
        _readStatusCache[eventId] = true;
      } else {
        print('Error Response: ${response.body}');
        throw Exception('Failed to mark event as read: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception details: $e');
      throw Exception('Error marking event as read: $e');
    }
  }

  static Future<bool> getEventReadStatus(int eventId) async {
    if (eventId == null) {
      throw Exception('Invalid event ID');
    }

    try {
      // Get headers (e.g., for authentication)
      final headers = await _getHeaders();
      // Correct the endpoint to match the backend's read-status route
      final uri = Uri.parse('$baseUrl/Events/$eventId/read-status');

      print('GET $uri');
      print('Headers: $headers');

      // Make the GET request
      final response = await http.get(uri, headers: headers);

      // Check the response status
      if (response.statusCode == 200) {
        // Decode the response body
        final responseData = jsonDecode(response.body);
        // Ensure `isRead` exists in the response
        return responseData['isRead'] ?? false;
      } else if (response.statusCode == 404) {
        print('Event not found. Status code: 404');
        return false;
      } else {
        print(
            'Failed to fetch read status. Status code: ${response.statusCode}, Body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error getting event read status: $e');
      return false;
    }
  }

  //get unread event by current month 20250117
  static Future<int> getUnreadEventsCount() async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('$baseUrl${ApiConstants.eventsAll}');

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        print(response.body); // Debug print to check the API response
        final List<dynamic> eventsList = jsonDecode(response.body);
        final events = eventsList.map((json) => Event.fromJson(json)).toList();

        // Get the current month and year
        final now = DateTime.now();
        final currentMonth = now.month;
        final currentYear = now.year;

        // Filter events for the current month and where isRead = false
        final currentMonthUnreadEvents = events.where((event) {
          final eventDate =
              event.date; // Assuming event.date is already a DateTime
          return eventDate.month == currentMonth &&
              eventDate.year == currentYear &&
              !event.isRead;
        }).toList();

        print(
            'Current month unread events count: ${currentMonthUnreadEvents.length}'); // Debug print
        return currentMonthUnreadEvents.length;
      } else {
        print('Failed to fetch events. Status code: ${response.statusCode}');
        return 0;
      }
    } catch (e) {
      print('Error fetching unread count: $e');
      return 0;
    }
  }

  static void dispose() {
    _client.close();
  }
}

