import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app/app.dart';
import 'core/config/app_flavor.dart';
import 'core/constants/app_constants.dart';
import 'core/di/dependency_injection.dart';
import 'core/utils/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure Default Flavor (Development)
  AppFlavor.instance.set(
    flavor: AppFlavorType.development,
    values: AppFlavorValues(
      baseUrl: AppConstants.baseUrl,
      appName: 'ConnectX',
      enableLogging: true,
      showFlavorBanner: false,
      enableAnalytics: false,
      enableCrashlytics: false,
    ),
  );

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
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
    AppLogger.info('📱 ConnectX app initialization completed successfully');
    AppLogger.debug('Environment: ${AppFlavor.instance.environmentName}');
  } catch (e, stackTrace) {
    AppLogger.fatal(
      'Failed to initialize ConnectX app',
      error: e,
      stackTrace: stackTrace,
    );
  }

  runApp(const ConnectXApp());
}