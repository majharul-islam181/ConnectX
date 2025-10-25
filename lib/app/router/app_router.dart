import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/user/domain/entites/user_entity.dart';
import '../../features/user/presentation/pages/splash_page.dart';
import '../../features/user/presentation/pages/user_detail_page.dart';
import '../../features/user/presentation/pages/user_list_page.dart';



class AppRouter {
  // Route names
  static const String splash = '/';
  static const String userList = '/users';
  static const String userDetail = '/user'; // Changed to support path parameters

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
      
      // User Detail Screen with userId parameter
      GoRoute(
        path: '$userDetail/:userId',
        name: 'userDetail',
        builder: (context, state) {
          final userIdString = state.pathParameters['userId'];
          final userId = int.tryParse(userIdString ?? '');
          
          if (userId == null) {
            // If invalid userId, redirect to user list
            return const UserListPage();
          }
          
          // Check if user object was passed as extra
          final user = state.extra as UserEntity?;
          
          return UserDetailPage(
            userId: userId,
            user: user, // Pass user object if available
          );
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
  
  static void goToUserDetail(BuildContext context, int userId, {UserEntity? user}) {
    context.go('$userDetail/$userId', extra: user);
  }
  
  static void pushUserDetail(BuildContext context, int userId, {UserEntity? user}) {
    context.push('$userDetail/$userId', extra: user);
  }
  
  // Navigate to user detail with UserEntity (extracts userId)
  static void goToUserDetailWithEntity(BuildContext context, UserEntity user) {
    context.go('$userDetail/${user.id}', extra: user);
  }
  
  static void pushUserDetailWithEntity(BuildContext context, UserEntity user) {
    context.push('$userDetail/${user.id}', extra: user);
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
