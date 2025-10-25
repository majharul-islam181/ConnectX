import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'app/app.dart';
import 'core/config/app_flavor.dart';
import 'core/constants/app_constants.dart';
import 'core/di/dependency_injection.dart';
import 'core/utils/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure Staging Flavor
  AppFlavor.instance.set(
    flavor: AppFlavorType.staging,
    values:  AppFlavorValues(
      baseUrl: AppConstants.baseUrl,
      appName: 'ConnectX [STAGING]',
      enableLogging: true,
      showFlavorBanner: true,
      enableAnalytics: true,
      enableCrashlytics: true,
      cacheValidDuration: Duration(minutes: 45),
      itemsPerPage: 8,
    ),
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize dependencies
  try {
    await initializeDependencies();
    AppLogger.info('🧪 Staging mode initialized successfully');
    AppLogger.debug('App Flavor: ${AppFlavor.instance.environmentName}');
    AppLogger.debug('Base URL: ${AppFlavor.instance.values.baseUrl}');
  } catch (e, stackTrace) {
    AppLogger.fatal(
      'Failed to initialize app in staging mode',
      error: e,
      stackTrace: stackTrace,
    );
  }

  runApp(
    const FlavorBanner(
      color: Colors.orange,
      location: BannerLocation.topStart,
      child: ConnectXApp(),
    ),
  );
}
