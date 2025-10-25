class ServerException implements Exception {
  final String message;
  final int? statusCode;
  
  const ServerException({
    required this.message,
    this.statusCode,
  });

  @override
  String toString() => 'ServerException: $message (Status Code: $statusCode)';
}

class CacheException implements Exception {
  final String message;
  
  const CacheException(this.message);

  @override
  String toString() => 'CacheException: $message';
}

class NetworkException implements Exception {
  final String message;
  
  const NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}

class ConnectionException implements Exception {
  final String message;
  
  const ConnectionException(this.message);

  @override
  String toString() => 'ConnectionException: $message';
}

class TimeoutException implements Exception {
  final String message;
  
  const TimeoutException(this.message);

  @override
  String toString() => 'TimeoutException: $message';
}

class ValidationException implements Exception {
  final String message;
  final Map<String, dynamic>? errors;
  
  const ValidationException({
    required this.message,
    this.errors,
  });

  @override
  String toString() => 'ValidationException: $message';
}

class ParseException implements Exception {
  final String message;
  final dynamic originalError;
  
  const ParseException({
    required this.message,
    this.originalError,
  });

  @override
  String toString() => 'ParseException: $message';
}

class NotFoundedException implements Exception {
  final String message;
  
  const NotFoundedException(this.message);

  @override
  String toString() => 'NotFoundedException: $message';
}

class UnauthorizedException implements Exception {
  final String message;
  
  const UnauthorizedException(this.message);

  @override
  String toString() => 'UnauthorizedException: $message';
}

class ForbiddenException implements Exception {
  final String message;
  
  const ForbiddenException(this.message);

  @override
  String toString() => 'ForbiddenException: $message';
}

// User-specific exceptions
class UserNotFoundException implements Exception {
  final String message;
  
  const UserNotFoundException(this.message);

  @override
  String toString() => 'UserNotFoundException: $message';
}

class UsersLoadException implements Exception {
  final String message;
  
  const UsersLoadException(this.message);

  @override
  String toString() => 'UsersLoadException: $message';
}