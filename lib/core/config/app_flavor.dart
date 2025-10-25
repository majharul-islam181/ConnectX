
enum AppFlavorType {
  development,
  staging,
  production,
}

class AppFlavorValues {
  final String baseUrl;
  final String appName;
  final bool enableLogging;
  final bool showFlavorBanner;
  final bool enableAnalytics;
  final bool enableCrashlytics;
  final Duration cacheValidDuration;
  final int itemsPerPage;

  const AppFlavorValues({
    required this.baseUrl,
    required this.appName,
    required this.enableLogging,
    required this.showFlavorBanner,
    this.enableAnalytics = false,
    this.enableCrashlytics = false,
    this.cacheValidDuration = const Duration(hours: 1),
    this.itemsPerPage = 10,
  });
}

class AppFlavor {
  static AppFlavor? _instance;
  static AppFlavor get instance => _instance ??= AppFlavor._();

  AppFlavor._();

  AppFlavorType _flavor = AppFlavorType.development;
  AppFlavorValues _values = const AppFlavorValues(
    baseUrl: 'https://reqres.in/api',
    appName: 'ConnectX',
    enableLogging: true,
    showFlavorBanner: true,
  );

  AppFlavorType get flavor => _flavor;
  AppFlavorValues get values => _values;

  bool get isDevelopment => _flavor == AppFlavorType.development;
  bool get isStaging => _flavor == AppFlavorType.staging;
  bool get isProduction => _flavor == AppFlavorType.production;

  void set({
    required AppFlavorType flavor,
    required AppFlavorValues values,
  }) {
    _flavor = flavor;
    _values = values;
  }

  String get environmentName {
    switch (_flavor) {
      case AppFlavorType.development:
        return 'Development';
      case AppFlavorType.staging:
        return 'Staging';
      case AppFlavorType.production:
        return 'Production';
    }
  }

  String get environmentShort {
    switch (_flavor) {
      case AppFlavorType.development:
        return 'DEV';
      case AppFlavorType.staging:
        return 'STG';
      case AppFlavorType.production:
        return 'PROD';
    }
  }

  @override
  String toString() {
    return 'AppFlavor{flavor: $_flavor, values: $_values}';
  }
}

extension AppFlavorExtension on AppFlavor {
  Duration get apiTimeout {
    switch (flavor) {
      case AppFlavorType.development:
        return const Duration(seconds: 60);
      case AppFlavorType.staging:
        return const Duration(seconds: 45);
      case AppFlavorType.production:
        return const Duration(seconds: 30);
    }
  }

  /// Get retry count based on flavor
  int get maxRetryCount {
    switch (flavor) {
      case AppFlavorType.development:
        return 5;
      case AppFlavorType.staging:
        return 3;
      case AppFlavorType.production:
        return 2;
    }
  }

  /// Get cache strategy based on flavor
  bool get enableAggressiveCaching {
    return flavor == AppFlavorType.production;
  }
}