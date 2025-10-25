import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import '../utils/logger.dart';
import 'dio_interceptors.dart';

class DioClient {
  late final Dio _dio;

  DioClient() {
    _dio = Dio();
    _setupInterceptors();
  }

  Dio get dio => _dio;

  void _setupInterceptors() {
    _dio.options = BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: AppConstants.connectTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
      sendTimeout: AppConstants.apiTimeout,
      headers: _getDefaultHeaders(),
    );

    // Add interceptors
    _dio.interceptors.addAll([
      LoggerInterceptor(),
      ErrorInterceptor(),
      RetryInterceptor(dio: _dio),
    ]);

    AppLogger.debug('Dio client configured with base URL: ${AppConstants.baseUrl}');
    AppLogger.debug('API key configured: ${AppConstants.apiKey.isNotEmpty}');
  }

  /// Get default headers including API key
  Map<String, String> _getDefaultHeaders() {
    try {
      return {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-API-Key': AppConstants.apiKey,
        'X-API-Version': AppConstants.apiVersion,
        'User-Agent': '${AppConstants.appName}/${AppConstants.appVersion}',
      };
    } catch (e) {
      AppLogger.error('Failed to get API key for headers', error: e);
      // Return headers without API key as fallback
      return {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'ConnectX/1.0.0',
      };
    }
  }

  // GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) {
    // Add API key to query parameters for ReqRes API
    final modifiedQueryParams = <String, dynamic>{
      ...?queryParameters,
    };

    // ReqRes API expects API key as query parameter
    try {
      modifiedQueryParams['api_key'] = AppConstants.apiKey;
    } catch (e) {
      AppLogger.warning('API key not available for request', error: e);
    }

    return _dio.get(
      path,
      queryParameters: modifiedQueryParams,
      options: options,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
  }

  // POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    // Add API key to query parameters for ReqRes API
    final modifiedQueryParams = <String, dynamic>{
      ...?queryParameters,
    };

    try {
      modifiedQueryParams['api_key'] = AppConstants.apiKey;
    } catch (e) {
      AppLogger.warning('API key not available for request', error: e);
    }

    return _dio.post(
      path,
      data: data,
      queryParameters: modifiedQueryParams,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  // PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    // Add API key to query parameters for ReqRes API
    final modifiedQueryParams = <String, dynamic>{
      ...?queryParameters,
    };

    try {
      modifiedQueryParams['api_key'] = AppConstants.apiKey;
    } catch (e) {
      AppLogger.warning('API key not available for request', error: e);
    }

    return _dio.put(
      path,
      data: data,
      queryParameters: modifiedQueryParams,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  // DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    // Add API key to query parameters for ReqRes API
    final modifiedQueryParams = <String, dynamic>{
      ...?queryParameters,
    };

    try {
      modifiedQueryParams['api_key'] = AppConstants.apiKey;
    } catch (e) {
      AppLogger.warning('API key not available for request', error: e);
    }

    return _dio.delete(
      path,
      data: data,
      queryParameters: modifiedQueryParams,
      options: options,
      cancelToken: cancelToken,
    );
  }

  // Cancel all requests
  void cancelRequests({CancelToken? cancelToken}) {
    if (cancelToken != null) {
      cancelToken.cancel('Request cancelled');
    }
  }

  /// Update base URL (useful for different environments)
  void updateBaseUrl(String newBaseUrl) {
    _dio.options.baseUrl = newBaseUrl;
    AppLogger.info('Dio client base URL updated to: $newBaseUrl');
  }

  /// Update headers (useful for authentication changes)
  void updateHeaders(Map<String, String> headers) {
    _dio.options.headers.addAll(headers);
    AppLogger.debug('Dio client headers updated');
  }

  /// Clear all headers
  void clearHeaders() {
    _dio.options.headers.clear();
    _dio.options.headers.addAll(_getDefaultHeaders());
    AppLogger.debug('Dio client headers reset to defaults');
  }
}