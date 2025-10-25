import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class ConnectXApp extends StatelessWidget {
  const ConnectXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<UserBloc>(
          create: (context) => getIt<UserBloc>(),
        ),
        BlocProvider<ConnectivityBloc>(
          create: (context) => getIt<ConnectivityBloc>()..add(ConnectivityStarted()),
        ),
      ],
      child: MaterialApp.router(
        title: 'ConnectX',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: AppRouter.router,
      ),
    );
  }
}