class AppConstants {
  // API Constants
  static const String baseUrl = 'https://reqres.in/api';
  static const String usersEndpoint = '/users';
  static const int defaultPerPage = 10;
  static const int maxRetryCount = 3;
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Pagination Constants
  static const int initialPage = 1;
  static const int itemsPerPage = 10;

  // Cache Constants
  static const String usersCacheKey = 'users_cache';
  static const String userCachePrefix = 'user_';
  static const Duration cacheValidDuration = Duration(hours: 1);
  static const int maxCacheSize = 100;

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

  // Success Messages
  static const String dataLoadedMessage = 'Data loaded successfully.';
  static const String refreshSuccessMessage = 'Data refreshed successfully.';

  // App Info
  static const String appName = 'ConnectX';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Connect with People';

  // Hive Box Names
  static const String userHiveBox = 'users';
  static const String settingsHiveBox = 'settings';
  static const String cacheHiveBox = 'cache';

  // SharedPreferences Keys
  static const String firstLaunchKey = 'first_launch';
  static const String themeKey = 'theme_mode';
  static const String lastSyncKey = 'last_sync';

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

  // Feature Flags
  static const bool enablePullToRefresh = true;
  static const bool enableInfiniteScroll = true;
  static const bool enableOfflineMode = true;
  static const bool enableCaching = true;
  static const bool enableAnalytics = false;

  // Logging
  static const bool enableLogging = true;
  static const String logTag = 'ConnectX';

  // Private constructor to prevent instantiation
  AppConstants._();
}