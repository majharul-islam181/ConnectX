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

  AppFlavor.instance.set(
    flavor: AppFlavorType.production,
    values: const AppFlavorValues(
      baseUrl: 'https://reqres.in/api',
      appName: 'ConnectX',
      enableLogging: false,
      showFlavorBanner: false,
      enableAnalytics: true,
      enableCrashlytics: true,
    ),
  );

  // Initialize environment configuration
  try {
    await EnvironmentConfig.instance.initialize();
    AppLogger.info('🚀 Environment configuration loaded for production');
  } catch (e, stackTrace) {
    AppLogger.fatal(
      'Failed to initialize environment configuration',
      error: e,
      stackTrace: stackTrace,
    );
  
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red.shade400,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Configuration Error',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Unable to load app configuration',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    return;
  }

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style for production
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  try {
    await initializeDependencies();
    AppLogger.info('🚀 Production mode initialized successfully');
  } catch (e, stackTrace) {
    AppLogger.fatal(
      'Failed to initialize app in production mode',
      error: e,
      stackTrace: stackTrace,
    );
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red.shade400,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Initialization Error',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please try again later',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    return;
  }

  // Run app (no banner for production)
  runApp(const ConnectXApp());
}