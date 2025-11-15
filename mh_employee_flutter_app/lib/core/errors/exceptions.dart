class ServerException implements Exception {
  final String message;

  ServerException({required this.message});

  @override
  String toString() => message;
}

class NetworkException implements Exception {
  final String message;

  NetworkException({this.message = 'No internet connection'});

  @override
  String toString() => message;
}

class CacheException implements Exception {
  final String message;

  CacheException({this.message = 'Cache error'});

  @override
  String toString() => message;
}

class AuthenticationException implements Exception {
  final String message;

  AuthenticationException({this.message = 'Authentication failed'});

  @override
  String toString() => message;
}

class ValidationException implements Exception {
  final String message;

  ValidationException({required this.message});

  @override
  String toString() => message;
}

class FileException implements Exception {
  final String message;

  FileException({required this.message});

  @override
  String toString() => message;
}

class TimeoutException implements Exception {
  final String message;

  TimeoutException({this.message = 'Request timeout'});

  @override
  String toString() => message;
}

class NotFoundException implements Exception {
  final String message;

  NotFoundException({this.message = 'Resource not found'});

  @override
  String toString() => message;
}

class UnauthorizedException implements Exception {
  final String message;

  UnauthorizedException({this.message = 'Unauthorized'});

  @override
  String toString() => message;
}

