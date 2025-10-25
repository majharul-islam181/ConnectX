import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/config/app_flavor.dart';
import 'core/utils/logger.dart';

class EnvironmentConfig {
  static EnvironmentConfig? _instance;
  static EnvironmentConfig get instance => _instance ??= EnvironmentConfig._();

  EnvironmentConfig._();

  bool _isInitialized = false;

  /// Initialize environment configuration based on current flavor
  Future<void> initialize() async {
    if (_isInitialized) {
      AppLogger.warning('Environment config already initialized');
      return;
    }

    try {
      final envFile = _getEnvFileName();
      await dotenv.load(fileName: envFile);
      _isInitialized = true;

      AppLogger.info('Environment config loaded from: $envFile');
      AppLogger.debug('API Base URL: $apiBaseUrl');
      AppLogger.debug('Environment: $environment');
      AppLogger.debug('Logging enabled: $enableLogging');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to load environment configuration',
        error: e,
        stackTrace: stackTrace,
      );

      // Fallback to loading default .env file
      try {
        await dotenv.load(fileName: '.env');
        _isInitialized = true;
        AppLogger.warning('Loaded fallback environment configuration');
      } catch (fallbackError) {
        AppLogger.fatal(
          'Failed to load fallback environment configuration',
          error: fallbackError,
        );
        rethrow;
      }
    }
  }

  /// Get environment file name based on current flavor
  String _getEnvFileName() {
    try {
      switch (AppFlavor.instance.flavor) {
        case AppFlavorType.development:
          return '.env.development';
        case AppFlavorType.staging:
          return '.env.staging';
        case AppFlavorType.production:
          return '.env.production';
      }
    } catch (e) {
      AppLogger.warning('Could not determine flavor, using default .env file');
      return '.env';
    }
  }

  /// Ensure environment is initialized before accessing values
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError(
        'Environment configuration not initialized. Call EnvironmentConfig.instance.initialize() first.',
      );
    }
  }

  // API Configuration
  String get apiBaseUrl {
    _ensureInitialized();
    return dotenv.env['API_BASE_URL'] ?? 'https://reqres.in/api';
  }

  String get apiKey {
    _ensureInitialized();
    final key = dotenv.env['API_KEY'];
    if (key == null || key.isEmpty) {
      throw StateError('API_KEY not found in environment configuration');
    }
    return key;
  }

  String get apiVersion {
    _ensureInitialized();
    return dotenv.env['API_VERSION'] ?? 'v1';
  }

  // App Configuration
  String get appName {
    _ensureInitialized();
    return dotenv.env['APP_NAME'] ?? 'ConnectX';
  }

  String get appVersion {
    _ensureInitialized();
    return dotenv.env['APP_VERSION'] ?? '1.0.0';
  }

  String get environment {
    _ensureInitialized();
    return dotenv.env['ENVIRONMENT'] ?? 'development';
  }

  // Feature Flags
  bool get enableLogging {
    _ensureInitialized();
    return dotenv.env['ENABLE_LOGGING']?.toLowerCase() == 'true';
  }

  bool get enableAnalytics {
    _ensureInitialized();
    return dotenv.env['ENABLE_ANALYTICS']?.toLowerCase() == 'true';
  }

  bool get enableCrashlytics {
    _ensureInitialized();
    return dotenv.env['ENABLE_CRASHLYTICS']?.toLowerCase() == 'true';
  }

  bool get showFlavorBanner {
    _ensureInitialized();
    return dotenv.env['SHOW_FLAVOR_BANNER']?.toLowerCase() == 'true';
  }

  // Cache Configuration
  Duration get cacheDuration {
    _ensureInitialized();
    final hours = int.tryParse(dotenv.env['CACHE_DURATION_HOURS'] ?? '1') ?? 1;
    return Duration(hours: hours);
  }

  int get cacheMaxSize {
    _ensureInitialized();
    return int.tryParse(dotenv.env['CACHE_MAX_SIZE'] ?? '50') ?? 50;
  }

  // Pagination Configuration
  int get itemsPerPage {
    _ensureInitialized();
    return int.tryParse(dotenv.env['ITEMS_PER_PAGE'] ?? '10') ?? 10;
  }

  int get maxRetryCount {
    _ensureInitialized();
    return int.tryParse(dotenv.env['MAX_RETRY_COUNT'] ?? '3') ?? 3;
  }

  // Network Configuration
  Duration get connectionTimeout {
    _ensureInitialized();
    final seconds =
        int.tryParse(dotenv.env['CONNECTION_TIMEOUT_SECONDS'] ?? '30') ?? 30;
    return Duration(seconds: seconds);
  }

  Duration get receiveTimeout {
    _ensureInitialized();
    final seconds =
        int.tryParse(dotenv.env['RECEIVE_TIMEOUT_SECONDS'] ?? '30') ?? 30;
    return Duration(seconds: seconds);
  }

  Duration get sendTimeout {
    _ensureInitialized();
    final seconds =
        int.tryParse(dotenv.env['SEND_TIMEOUT_SECONDS'] ?? '30') ?? 30;
    return Duration(seconds: seconds);
  }

  // Debug Configuration
  bool get enableNetworkLogs {
    _ensureInitialized();
    return dotenv.env['ENABLE_NETWORK_LOGS']?.toLowerCase() == 'true';
  }

  bool get enableBlocLogs {
    _ensureInitialized();
    return dotenv.env['ENABLE_BLOC_LOGS']?.toLowerCase() == 'true';
  }

  bool get enablePerformanceLogs {
    _ensureInitialized();
    return dotenv.env['ENABLE_PERFORMANCE_LOGS']?.toLowerCase() == 'true';
  }

  // Utility methods
  String? getCustomValue(String key) {
    _ensureInitialized();
    return dotenv.env[key];
  }

  Map<String, String> getAllValues() {
    _ensureInitialized();
    return Map<String, String>.from(dotenv.env);
  }

  /// Print all configuration values for debugging
  void printConfiguration() {
    if (!enableLogging) return;

    AppLogger.debug('=== Environment Configuration ===');
    AppLogger.debug('Environment: $environment');
    AppLogger.debug('App Name: $appName');
    AppLogger.debug('App Version: $appVersion');
    AppLogger.debug('API Base URL: $apiBaseUrl');
    AppLogger.debug(
        'API Key: ${apiKey.isNotEmpty ? '***${apiKey.substring(apiKey.length - 4)}' : 'Not set'}');
    AppLogger.debug('API Version: $apiVersion');
    AppLogger.debug('Enable Logging: $enableLogging');
    AppLogger.debug('Enable Analytics: $enableAnalytics');
    AppLogger.debug('Enable Crashlytics: $enableCrashlytics');
    AppLogger.debug('Show Flavor Banner: $showFlavorBanner');
    AppLogger.debug('Cache Duration: ${cacheDuration.inHours} hours');
    AppLogger.debug('Cache Max Size: $cacheMaxSize');
    AppLogger.debug('Items Per Page: $itemsPerPage');
    AppLogger.debug('Max Retry Count: $maxRetryCount');
    AppLogger.debug('Connection Timeout: ${connectionTimeout.inSeconds}s');
    AppLogger.debug('Receive Timeout: ${receiveTimeout.inSeconds}s');
    AppLogger.debug('Send Timeout: ${sendTimeout.inSeconds}s');
    AppLogger.debug('Enable Network Logs: $enableNetworkLogs');
    AppLogger.debug('Enable Bloc Logs: $enableBlocLogs');
    AppLogger.debug('Enable Performance Logs: $enablePerformanceLogs');
    AppLogger.debug('=== End Configuration ===');
  }

  @override
  String toString() {
    return 'EnvironmentConfig{environment: $environment, apiBaseUrl: $apiBaseUrl}';
  }
}
