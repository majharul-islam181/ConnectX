import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import 'user_list_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.4, 1.0, curve: Curves.easeOutBack),
    ));

    _startAnimation();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _startAnimation() async {
    await _animationController.forward();
    
    // Wait a bit before navigating
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => 
              const UserListPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: AppConstants.mediumAnimationDuration,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Icon/Logo
            FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: colorScheme.onPrimary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.people,
                    size: 60,
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: AppConstants.largePadding * 2),
            
            // App Name
            SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    Text(
                      AppConstants.appName,
                      style: theme.textTheme.headlineLarge?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                      ),
                    ),
                    
                    const SizedBox(height: AppConstants.smallPadding),
                    
                    Text(
                      AppConstants.appDescription,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onPrimary.withOpacity(0.8),
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: AppConstants.largePadding * 3),
            
            // Loading Indicator
            FadeTransition(
              opacity: _fadeAnimation,
              child: SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    colorScheme.onPrimary,
                  ),
                  strokeWidth: 3,
                ),
              ),
            ),
            
            const SizedBox(height: AppConstants.defaultPadding),
            
            // Loading Text
            SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  'Loading amazing people...',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onPrimary.withOpacity(0.7),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}