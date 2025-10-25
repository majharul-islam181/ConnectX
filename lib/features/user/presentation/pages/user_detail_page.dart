import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../domain/entites/user_entity.dart';
import '../bloc/user_bloc.dart';
import '../bloc/user_event.dart';
import '../bloc/user_state.dart';
import '../widgets/user_avatar_widget.dart';

class UserDetailPage extends StatefulWidget {
  final int userId;
  final UserEntity? user; // Optional: if passed from list

  const UserDetailPage({
    super.key,
    required this.userId,
    this.user,
  });

  @override
  State<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage>
    with SingleTickerProviderStateMixin {
  late UserBloc _userBloc;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _userBloc = getIt<UserBloc>();
    
    _animationController = AnimationController(
      duration: AppConstants.mediumAnimationDuration,
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    // Load user detail if not provided
    if (widget.user == null) {
      _userBloc.add(LoadUserDetailEvent(widget.userId));
    } else {
      // Start animation immediately if user data is available
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _userBloc,
      child: Scaffold(
        appBar: _buildAppBar(),
        body: BlocConsumer<UserBloc, UserState>(
          listener: _handleStateChanges,
          builder: _buildContent,
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('User Details'),
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 2,
      actions: [
        PopupMenuButton<String>(
          onSelected: _handleMenuAction,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'refresh',
              child: ListTile(
                leading: Icon(Icons.refresh),
                title: Text('Refresh'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'back_to_list',
              child: ListTile(
                leading: Icon(Icons.list),
                title: Text('Back to List'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'refresh':
        _userBloc.add(LoadUserDetailEvent(widget.userId));
        break;
      case 'back_to_list':
        _userBloc.add(const ResetUserDetailEvent());
        Navigator.of(context).pop();
        break;
    }
  }

  void _handleStateChanges(BuildContext context, UserState state) {
    if (state is UserDetailLoadedState) {
      _animationController.forward();
    } else if (state is UserErrorState) {
      _showErrorSnackBar(state.userFriendlyMessage);
    }
  }

  Widget _buildContent(BuildContext context, UserState state) {
    if (widget.user != null) {
      return _buildUserDetailContent(widget.user!);
    }

    if (state is UserDetailLoadingState) {
      return _buildLoadingState();
    } else if (state is UserDetailLoadedState) {
      return _buildUserDetailContent(state.user);
    } else if (state is UserErrorState) {
      return _buildErrorState(state);
    }

    return _buildLoadingState();
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: AppConstants.defaultPadding),
          Text(
            'Loading user details...',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildUserDetailContent(UserEntity user) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.largePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Header
              _buildProfileHeader(user, theme),
              
              const SizedBox(height: AppConstants.largePadding * 2),
              
              // User Information Cards
              _buildInfoCard(
                title: 'Personal Information',
                icon: Icons.person,
                children: [
                  _buildInfoRow(
                    'Full Name',
                    user.fullName,
                    Icons.badge,
                    theme,
                  ),
                  _buildInfoRow(
                    'First Name',
                    user.firstName,
                    Icons.person_outline,
                    theme,
                  ),
                  _buildInfoRow(
                    'Last Name',
                    user.lastName,
                    Icons.person_outline,
                    theme,
                  ),
                ],
                theme: theme,
              ),
              
              const SizedBox(height: AppConstants.defaultPadding),
              
              _buildInfoCard(
                title: 'Contact Information',
                icon: Icons.contact_mail,
                children: [
                  _buildInfoRow(
                    'Email Address',
                    user.email,
                    Icons.email,
                    theme,
                  ),
                  _buildInfoRow(
                    'User ID',
                    '#${user.id}',
                    Icons.fingerprint,
                    theme,
                  ),
                ],
                theme: theme,
              ),
              
              const SizedBox(height: AppConstants.defaultPadding),
              
              _buildInfoCard(
                title: 'Profile Settings',
                icon: Icons.settings,
                children: [
                  _buildInfoRow(
                    'Profile Picture',
                    'Available',
                    Icons.image,
                    theme,
                  ),
                  _buildInfoRow(
                    'Account Status',
                    'Active',
                    Icons.check_circle,
                    theme,
                  ),
                ],
                theme: theme,
              ),
              
              const SizedBox(height: AppConstants.largePadding * 2),
              
              // Action Buttons
              _buildActionButtons(user, theme),
              
              const SizedBox(height: AppConstants.largePadding),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(UserEntity user, ThemeData theme) {
    return Column(
      children: [
        // Avatar with Hero Animation
        LargeUserAvatarWidget(
          imageUrl: user.avatar,
          heroTag: 'user_avatar_${user.id}',
        ),
        
        const SizedBox(height: AppConstants.defaultPadding),
        
        // Name
        Text(
          user.fullName,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: AppConstants.smallPadding),
        
        // Email
        Text(
          user.email,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: AppConstants.smallPadding),
        
        // User ID Badge
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.defaultPadding,
            vertical: AppConstants.smallPadding,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
          ),
          child: Text(
            'ID: ${user.id}',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
    required ThemeData theme,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Header
            Row(
              children: [
                Icon(
                  icon,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: AppConstants.smallPadding),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppConstants.defaultPadding),
            
            // Card Content
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    IconData icon,
    ThemeData theme,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.defaultPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: AppConstants.defaultPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(UserEntity user, ThemeData theme) {
    return Column(
      children: [
        // Primary Actions
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _sendEmail(user.email),
                icon: const Icon(Icons.email),
                label: const Text('Send Email'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppConstants.defaultPadding,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppConstants.defaultPadding),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _shareUser(user),
                icon: const Icon(Icons.share),
                label: const Text('Share'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppConstants.defaultPadding,
                  ),
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: AppConstants.defaultPadding),
        
        // Secondary Actions
        SizedBox(
          width: double.infinity,
          child: TextButton.icon(
            onPressed: () => _viewFullProfile(user),
            icon: const Icon(Icons.open_in_new),
            label: const Text('View Full Profile'),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(UserErrorState state) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.largePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              state.isNetworkError 
                  ? Icons.wifi_off 
                  : Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            Text(
              'Failed to load user details',
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Text(
              state.userFriendlyMessage,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.largePadding),
            if (state.canRetry) ...[
              ElevatedButton.icon(
                onPressed: () => _userBloc.add(const RetryEvent()),
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
              const SizedBox(height: AppConstants.defaultPadding),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Go Back'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _sendEmail(String email) {
    _showSnackBar('Opening email app for $email');
    // In a real app, you would use url_launcher to open email app
    // await launch('mailto:$email');
  }

  void _shareUser(UserEntity user) {
    _showSnackBar('Sharing ${user.fullName}');
    // In a real app, you would use share_plus package
    // await Share.share('Check out ${user.fullName} at ${user.email}');
  }

  void _viewFullProfile(UserEntity user) {
    _showSnackBar('Opening full profile for ${user.fullName}');
    // In a real app, you might open a web view or another detailed screen
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Retry',
          textColor: Theme.of(context).colorScheme.onError,
          onPressed: () => _userBloc.add(LoadUserDetailEvent(widget.userId)),
        ),
      ),
    );
  }
}