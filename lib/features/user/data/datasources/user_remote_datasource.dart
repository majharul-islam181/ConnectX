import 'package:dio/dio.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/logger.dart';
import '../models/api_response_model.dart';

abstract class UserRemoteDataSource {
  /// Fetch paginated users from API
  Future<UsersResponseModel> getUsers({
    required int page,
    required int perPage,
  });
  
  Future<UserResponseModel> getUserById(int id);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final DioClient dioClient;

  UserRemoteDataSourceImpl(this.dioClient);

  @override
  Future<UsersResponseModel> getUsers({
    required int page,
    required int perPage,
  }) async {
    try {
      AppLogger.apiRequest(
        method: 'GET',
        url: '${AppConstants.usersEndpoint}?page=$page&per_page=$perPage',
      );

      final stopwatch = Stopwatch()..start();

      final response = await dioClient.get(
        AppConstants.usersEndpoint,
        queryParameters: {
          'page': page,
          'per_page': perPage,
        },
      );

      stopwatch.stop();

      AppLogger.apiResponse(
        method: 'GET',
        url: AppConstants.usersEndpoint,
        statusCode: response.statusCode ?? 0,
        duration: stopwatch.elapsed,
      );

      AppLogger.performance(
        operation: 'Get Users API',
        duration: stopwatch.elapsed,
        metadata: {
          'page': page,
          'per_page': perPage,
          'response_size': response.data.toString().length,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return UsersResponseModel.fromJson(data);
      } else {
        throw ServerException(
          message: 'Failed to fetch users',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      AppLogger.apiError(
        method: 'GET',
        url: AppConstants.usersEndpoint,
        error: e,
        statusCode: e.response?.statusCode,
      );

      if (e.error is Exception) {
        throw e.error as Exception;
      }

      _handleDioException(e);
      throw const ServerException(message: 'Unknown server error');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in getUsers',
        error: e,
        stackTrace: stackTrace,
      );
      throw ServerException(message: 'Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<UserResponseModel> getUserById(int id) async {
    try {
      AppLogger.apiRequest(
        method: 'GET',
        url: '${AppConstants.usersEndpoint}/$id',
      );

      final stopwatch = Stopwatch()..start();

      final response = await dioClient.get(
        '${AppConstants.usersEndpoint}/$id',
      );

      stopwatch.stop();

      AppLogger.apiResponse(
        method: 'GET',
        url: '${AppConstants.usersEndpoint}/$id',
        statusCode: response.statusCode ?? 0,
        duration: stopwatch.elapsed,
      );

      AppLogger.performance(
        operation: 'Get User Detail API',
        duration: stopwatch.elapsed,
        metadata: {
          'user_id': id,
          'response_size': response.data.toString().length,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return UserResponseModel.fromJson(data);
      } else {
        throw ServerException(
          message: 'Failed to fetch user with ID: $id',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      AppLogger.apiError(
        method: 'GET',
        url: '${AppConstants.usersEndpoint}/$id',
        error: e,
        statusCode: e.response?.statusCode,
      );

      if (e.error is Exception) {
        throw e.error as Exception;
      }

      _handleDioException(e);
      throw const ServerException(message: 'Unknown server error');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in getUserById',
        error: e,
        stackTrace: stackTrace,
      );
      throw ServerException(message: 'Unexpected error: ${e.toString()}');
    }
  }

  /// Handle DioException and convert to appropriate custom exceptions
  void _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw const TimeoutException('Request timeout. Please try again.');

      case DioExceptionType.connectionError:
        throw const ConnectionException(
          'Connection failed. Please check your internet connection.',
        );

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final responseData = e.response?.data;

        // Try to parse error response
        if (responseData is Map<String, dynamic>) {
          try {
            final errorResponse = ErrorResponseModel.fromJson(responseData);
            throw ServerException(
              message: errorResponse.mainMessage,
              statusCode: statusCode,
            );
          } catch (_) {
            // If parsing fails, use default message
          }
        }

        // Handle specific status codes
        switch (statusCode) {
          case 400:
            throw const ValidationException(
              message: 'Invalid request parameters',
            );
          case 401:
            throw const UnauthorizedException('Invalid API key');
          case 403:
            throw const ForbiddenException('Access forbidden');
          case 404:
            throw const NotFoundedException('User not found');
          case 429:
            throw const ServerException(
              message: 'Too many requests. Please try again later.',
            );
          case 500:
          case 502:
          case 503:
          case 504:
            throw const ServerException(
              message: 'Server error. Please try again later.',
            );
          default:
            throw ServerException(
              message: 'HTTP Error: $statusCode',
              statusCode: statusCode,
            );
        }

      case DioExceptionType.cancel:
        throw const NetworkException('Request was cancelled');

      case DioExceptionType.unknown:
        throw NetworkException('Network error: ${e.message}');

      default:
        throw ServerException(message: 'Unknown error: ${e.message}');
    }
  }
}