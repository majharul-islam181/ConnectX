// ignore_for_file: use_super_parameters

import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

// General failures
class ServerFailure extends Failure {
  const ServerFailure([String message = 'Server Failure']) : super(message);
}

class CacheFailure extends Failure {
  const CacheFailure([String message = 'Cache Failure']) : super(message);
}

class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'Network Failure']) : super(message);
}

class ConnectionFailure extends Failure {
  const ConnectionFailure([String message = 'Connection Failure']) : super(message);
}

class TimeoutFailure extends Failure {
  const TimeoutFailure([String message = 'Request Timeout']) : super(message);
}

class UnknownFailure extends Failure {
  const UnknownFailure([String message = 'Unknown Error']) : super(message);
}

class ValidationFailure extends Failure {
  const ValidationFailure([String message = 'Validation Error']) : super(message);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([String message = 'Not Found']) : super(message);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([String message = 'Unauthorized']) : super(message);
}

class ForbiddenFailure extends Failure {
  const ForbiddenFailure([String message = 'Forbidden']) : super(message);
}

// User-specific failures
class UserNotFoundFailure extends Failure {
  const UserNotFoundFailure([String message = 'User not found']) : super(message);
}

class UsersLoadFailure extends Failure {
  const UsersLoadFailure([String message = 'Failed to load users']) : super(message);
}

class UserSearchFailure extends Failure {
  const UserSearchFailure([String message = 'Failed to search users']) : super(message);
}

// Parse failures
class JsonParseFailure extends Failure {
  const JsonParseFailure([String message = 'Failed to parse JSON data']) : super(message);
}

class DataParseFailure extends Failure {
  const DataParseFailure([String message = 'Failed to parse data']) : super(message);
}

// Cache specific failures
class CacheNotFoundFailure extends Failure {
  const CacheNotFoundFailure([String message = 'Data not found in cache']) : super(message);
}

class CacheExpiredFailure extends Failure {
  const CacheExpiredFailure([String message = 'Cached data has expired']) : super(message);
}

class CacheWriteFailure extends Failure {
  const CacheWriteFailure([String message = 'Failed to write to cache']) : super(message);
}

class CacheReadFailure extends Failure {
  const CacheReadFailure([String message = 'Failed to read from cache']) : super(message);
}