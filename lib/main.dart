import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app/app.dart';
import 'core/config/app_flavor.dart';
import 'core/di/dependency_injection.dart';
import 'core/utils/logger.dart';
import 'environment_config.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Configure Default Flavor (Development)
  AppFlavor.instance.set(
    flavor: AppFlavorType.development,
    values: const AppFlavorValues(
      baseUrl: 'https://reqres.in/api', // Will be overridden by environment config
      appName: 'ConnectX', // Will be overridden by environment config
      enableLogging: true,
      showFlavorBanner: false,
      enableAnalytics: false,
      enableCrashlytics: false,
    ),
  );

  // Initialize environment configuration
  try {
    await EnvironmentConfig.instance.initialize();
    AppLogger.info('📱 Environment configuration loaded');
  } catch (e, stackTrace) {
    AppLogger.fatal(
      'Failed to initialize environment configuration',
      error: e,
      stackTrace: stackTrace,
    );
  }

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
    AppLogger.debug('Environment: ${EnvironmentConfig.instance.environment}');
    
    // Safely check API key
    try {
      final apiKey = EnvironmentConfig.instance.apiKey;
      AppLogger.debug('API Key configured: ${apiKey.isNotEmpty}');
    } catch (e) {
      AppLogger.warning('Could not check API key: $e');
    }
  } catch (e, stackTrace) {
    AppLogger.fatal(
      'Failed to initialize ConnectX app',
      error: e,
      stackTrace: stackTrace,
    );
  }

  runApp(const ConnectXApp());
}
