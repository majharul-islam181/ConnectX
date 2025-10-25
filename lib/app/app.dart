import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/config/app_flavor.dart';
import '../core/di/dependency_injection.dart';
import '../features/user/presentation/bloc/user_bloc.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';


class ConnectXApp extends StatelessWidget {
  const ConnectXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<UserBloc>(
          create: (context) => getIt<UserBloc>(),
        ),
        // BlocProvider<ConnectivityBloc>(
        //   create: (context) => getIt<ConnectivityBloc>()..add(ConnectivityStarted()),
        // ),
      ],
      child: MaterialApp.router(
        title: _getAppTitle(),
        debugShowCheckedModeBanner: _showDebugBanner(),
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: AppRouter.router,
      ),
    );
  }

  String _getAppTitle() {
    try {
      return AppFlavor.instance.values.appName;
    } catch (e) {
      return 'ConnectX';
    }
  }

  bool _showDebugBanner() {
    try {
      return AppFlavor.instance.isDevelopment && AppFlavor.instance.values.showFlavorBanner;
    } catch (e) {
      return false;
    }
  }
}