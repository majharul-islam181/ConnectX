import '../../environment_config.dart';

class AppConstants {
  // API Constants (Now using EnvironmentConfig)
  static String get baseUrl => EnvironmentConfig.instance.apiBaseUrl;
  static String get apiKey => EnvironmentConfig.instance.apiKey;
  static String get apiVersion => EnvironmentConfig.instance.apiVersion;
  static String get usersEndpoint => '/users';
  
  // Dynamic constants from environment
  static int get defaultPerPage => EnvironmentConfig.instance.itemsPerPage;
  static int get maxRetryCount => EnvironmentConfig.instance.maxRetryCount;
  static Duration get apiTimeout => EnvironmentConfig.instance.receiveTimeout;
  static Duration get connectTimeout => EnvironmentConfig.instance.connectionTimeout;
  static Duration get receiveTimeout => EnvironmentConfig.instance.receiveTimeout;
  static Duration get cacheValidDuration => EnvironmentConfig.instance.cacheDuration;

  // Static constants (unchanged)
  static const int initialPage = 1;
  static const int itemsPerPage = 10; // Fallback value

  // Animation Constants
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double defaultBorderRadius = 12.0;
  static const double smallBorderRadius = 8.0;
  static const double largeBorderRadius = 16.0;

  // Debounce Constants
  static const Duration searchDebounceTime = Duration(milliseconds: 500);

  // Error Messages
  static const String networkErrorMessage = 'Please check your internet connection and try again.';
  static const String serverErrorMessage = 'Server error occurred. Please try again later.';
  static const String unknownErrorMessage = 'An unexpected error occurred. Please try again.';
  static const String noDataMessage = 'No users found.';
  static const String loadingMessage = 'Loading...';
  static const String apiKeyMissingMessage = 'API key is required but not found.';

  // Success Messages
  static const String dataLoadedMessage = 'Data loaded successfully.';
  static const String refreshSuccessMessage = 'Data refreshed successfully.';

  // App Info (Now using EnvironmentConfig)
  static String get appName => EnvironmentConfig.instance.appName;
  static String get appVersion => EnvironmentConfig.instance.appVersion;
  static const String appDescription = 'Connect with People';

  // Hive Box Names
  static const String userHiveBox = 'users';
  static const String settingsHiveBox = 'settings';
  static const String cacheHiveBox = 'cache';

  // SharedPreferences Keys
  static const String firstLaunchKey = 'first_launch';
  static const String themeKey = 'theme_mode';
  static const String lastSyncKey = 'last_sync';
  static const String apiKeyKey = 'api_key';

  // Network Status
  static const String connectionStatusKey = 'connection_status';

  // Image Constants
  static const String defaultAvatarUrl = 'https://via.placeholder.com/150x150.png?text=User';
  static const double avatarSize = 50.0;
  static const double largeAvatarSize = 120.0;

  // Search Constants
  static const String searchHintText = 'Search users...';
  static const int minSearchLength = 2;

  // Validation Constants
  static const int maxNameLength = 50;
  static const int maxEmailLength = 100;

  // Platform Constants
  static const String androidPackageName = 'com.connectx.app';
  static const String iosAppId = 'com.connectx.app';

  // Feature Flags (Now using EnvironmentConfig)
  static bool get enablePullToRefresh => true;
  static bool get enableInfiniteScroll => true;
  static bool get enableOfflineMode => true;
  static bool get enableCaching => true;
  static bool get enableAnalytics => EnvironmentConfig.instance.enableAnalytics;
  static bool get enableLogging => EnvironmentConfig.instance.enableLogging;

  // Logging
  static const String logTag = 'ConnectX';

  // API Headers
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'X-API-Key': apiKey,
    'X-API-Version': apiVersion,
  };

  // Environment-specific getters
  static bool get isDevelopment {
    try {
      return EnvironmentConfig.instance.environment == 'development';
    } catch (e) {
      return true; // Default to development if not initialized
    }
  }

  static bool get isStaging {
    try {
      return EnvironmentConfig.instance.environment == 'staging';
    } catch (e) {
      return false;
    }
  }

  static bool get isProduction {
    try {
      return EnvironmentConfig.instance.environment == 'production';
    } catch (e) {
      return false;
    }
  }

  // Private constructor to prevent instantiation
  AppConstants._();
}