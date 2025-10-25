import 'dart:developer';
import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import '../errors/exceptions.dart';

class LoggerInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (AppConstants.enableLogging) {
      log('🚀 REQUEST[${options.method}] => PATH: ${options.path}',
          name: AppConstants.logTag);
      log('📝 Headers: ${options.headers}', name: AppConstants.logTag);
      if (options.data != null) {
        log('📦 Data: ${options.data}', name: AppConstants.logTag);
      }
      if (options.queryParameters.isNotEmpty) {
        log('🔍 Query: ${options.queryParameters}', name: AppConstants.logTag);
      }
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (AppConstants.enableLogging) {
      log('✅ RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
          name: AppConstants.logTag);
      log('📋 Data: ${response.data}', name: AppConstants.logTag);
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (AppConstants.enableLogging) {
      log('❌ ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}',
          name: AppConstants.logTag);
      log('💥 Error: ${err.message}', name: AppConstants.logTag);
      if (err.response?.data != null) {
        log('📋 Error Data: ${err.response?.data}', name: AppConstants.logTag);
      }
    }
    super.onError(err, handler);
  }
}

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    Exception exception;

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        exception = const TimeoutException('Request timeout. Please try again.');
        break;
      case DioExceptionType.connectionError:
        exception = const ConnectionException('Connection failed. Please check your internet connection.');
        break;
      case DioExceptionType.badResponse:
        exception = _handleStatusCode(err.response?.statusCode, err.response?.data);
        break;
      case DioExceptionType.cancel:
        exception = const NetworkException('Request was cancelled.');
        break;
      case DioExceptionType.unknown:
        exception = NetworkException('Network error: ${err.message}');
        break;
      default:
        exception = NetworkException('Unknown error: ${err.message}');
    }

    handler.reject(DioException(
      requestOptions: err.requestOptions,
      error: exception,
      type: err.type,
      response: err.response,
    ));
  }

  Exception _handleStatusCode(int? statusCode, dynamic data) {
    String message = 'An error occurred';
    
    if (data is Map<String, dynamic> && data.containsKey('message')) {
      message = data['message'].toString();
    } else if (data is Map<String, dynamic> && data.containsKey('error')) {
      message = data['error'].toString();
    }

    switch (statusCode) {
      case 400:
        return ValidationException(message: 'Bad request: $message');
      case 401:
        return UnauthorizedException('Unauthorized: $message');
      case 403:
        return ForbiddenException('Forbidden: $message');
      case 404:
        return NotFoundedException('Not found: $message');
      case 409:
        return ValidationException(message: 'Conflict: $message');
      case 422:
        return ValidationException(message: 'Validation error: $message');
      case 429:
        return ServerException(message: 'Too many requests: $message', statusCode: statusCode);
      case 500:
      case 502:
      case 503:
      case 504:
        return ServerException(message: 'Server error: $message', statusCode: statusCode);
      default:
        return ServerException(message: 'HTTP $statusCode: $message', statusCode: statusCode);
    }
  }
}

class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;
  final Duration retryDelay;

  RetryInterceptor({
    required this.dio,
    this.maxRetries = AppConstants.maxRetryCount,
    this.retryDelay = const Duration(seconds: 1),
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (_shouldRetry(err) && err.requestOptions.extra['retryCount'] != null) {
      final retryCount = err.requestOptions.extra['retryCount'] as int;
      
      if (retryCount < maxRetries) {
        err.requestOptions.extra['retryCount'] = retryCount + 1;
        
        // Wait before retrying
        await Future.delayed(retryDelay * (retryCount + 1));
        
        if (AppConstants.enableLogging) {
          log('🔄 Retrying request (${retryCount + 1}/$maxRetries): ${err.requestOptions.path}',
              name: AppConstants.logTag);
        }
        
        try {
          final response = await dio.fetch(err.requestOptions);
          handler.resolve(response);
          return;
        } catch (e) {
          // Continue to next retry or fail
        }
      }
    }
    
    super.onError(err, handler);
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Initialize retry count
    if (options.extra['retryCount'] == null) {
      options.extra['retryCount'] = 0;
    }
    super.onRequest(options, handler);
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
           err.type == DioExceptionType.receiveTimeout ||
           err.type == DioExceptionType.sendTimeout ||
           err.type == DioExceptionType.connectionError ||
           (err.response?.statusCode != null && 
            err.response!.statusCode! >= 500);
  }
}