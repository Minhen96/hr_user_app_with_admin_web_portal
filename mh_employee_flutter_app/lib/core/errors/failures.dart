import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure({required this.message});

  @override
  List<Object?> get props => [message];
}

// Server Failures
class ServerFailure extends Failure {
  const ServerFailure({required super.message});
}

// Network Failures
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'No internet connection. Please check your network.',
  });
}

// Cache Failures
class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'Failed to access local cache.',
  });
}

// Authentication Failures
class AuthenticationFailure extends Failure {
  const AuthenticationFailure({
    super.message = 'Authentication failed. Please login again.',
  });
}

// Validation Failures
class ValidationFailure extends Failure {
  const ValidationFailure({required super.message});
}

// File Failures
class FileFailure extends Failure {
  const FileFailure({required super.message});
}

// Timeout Failures
class TimeoutFailure extends Failure {
  const TimeoutFailure({
    super.message = 'Request timeout. Please try again.',
  });
}

// Permission Failures
class PermissionFailure extends Failure {
  const PermissionFailure({
    super.message = 'Permission denied.',
  });
}

// Not Found Failures
class NotFoundFailure extends Failure {
  const NotFoundFailure({
    super.message = 'Resource not found.',
  });
}

// Unauthorized Failures
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({
    super.message = 'Unauthorized access. Please login.',
  });
}

