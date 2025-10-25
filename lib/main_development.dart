import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'app/app.dart';
import 'core/config/app_flavor.dart';
import 'core/constants/app_constants.dart';
import 'core/di/dependency_injection.dart';
import 'core/utils/logger.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Configure Development Flavor
  AppFlavor.instance.set(
    flavor: AppFlavorType.development,
    values: const AppFlavorValues(
      baseUrl: AppConstants.baseUrl,
      appName: 'ConnectX [DEV]',
      enableLogging: true,
      showFlavorBanner: true,
      enableAnalytics: false,
      enableCrashlytics: false,
      cacheValidDuration: Duration(minutes: 30),
      itemsPerPage: 5,
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
    AppLogger.info('🔧 Development mode initialized successfully');
    AppLogger.debug('App Flavor: ${AppFlavor.instance.environmentName}');
    AppLogger.debug('Base URL: ${AppFlavor.instance.values.baseUrl}');
    AppLogger.debug('Logging: ${AppFlavor.instance.values.enableLogging}');
  } catch (e, stackTrace) {
    AppLogger.fatal(
      'Failed to initialize app in development mode',
      error: e,
      stackTrace: stackTrace,
    );
  }

  runApp(
    FlavorBanner(
      color: Colors.green,
      location: BannerLocation.topStart,
      child: const ConnectXApp(),
    ),
  );
}