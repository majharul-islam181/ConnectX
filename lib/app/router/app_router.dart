import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  // Route names
  static const String splash = '/';
  static const String userList = '/users';
  static const String userDetail = '/user-detail';

  // GoRouter configuration
  static final GoRouter router = GoRouter(
    initialLocation: splash,
    routes: [
      // Splash Screen
      GoRoute(
        path: splash,
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      
      // User List Screen
      GoRoute(
        path: userList,
        name: 'userList',
        builder: (context, state) => const UserListPage(),
      ),
      
      // User Detail Screen
      GoRoute(
        path: userDetail,
        name: 'userDetail',
        builder: (context, state) {
          final user = state.extra as UserEntity?;
          if (user == null) {
            // If no user is passed, redirect to user list
            return const UserListPage();
          }
          return UserDetailPage(user: user);
        },
      ),
    ],
    
    // Error handling
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
        backgroundColor: Theme.of(context).colorScheme.error,
        foregroundColor: Theme.of(context).colorScheme.onError,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 80,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 24),
              Text(
                'Page Not Found',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'The page you are looking for does not exist or may have been moved.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => context.go(userList),
                icon: const Icon(Icons.home),
                label: const Text('Go to Home'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  
  // Navigation helper methods
  static void goToSplash(BuildContext context) {
    context.go(splash);
  }
  
  static void goToUserList(BuildContext context) {
    context.go(userList);
  }
  
  static void goToUserDetail(BuildContext context, UserEntity user) {
    context.go(userDetail, extra: user);
  }
  
  static void pushUserDetail(BuildContext context, UserEntity user) {
    context.push(userDetail, extra: user);
  }
  
  // Pop navigation
  static void pop(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(userList);
    }
  }
}