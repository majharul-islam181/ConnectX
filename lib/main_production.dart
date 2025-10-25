import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app/app.dart';
import 'core/config/app_flavor.dart';
import 'core/constants/app_constants.dart';
import 'core/di/dependency_injection.dart';
import 'core/utils/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  AppFlavor.instance.set(
    flavor: AppFlavorType.production,
    values:  AppFlavorValues(
      baseUrl: AppConstants.baseUrl,
      appName: 'ConnectX',
      enableLogging: false,
      showFlavorBanner: false,
      enableAnalytics: true,
      enableCrashlytics: true,
      cacheValidDuration: Duration(hours: 2),
      itemsPerPage: AppConstants.itemsPerPage,
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
                  'Something went wrong',
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