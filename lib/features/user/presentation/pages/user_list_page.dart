import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../domain/entites/user_entity.dart';
import '../bloc/user_bloc.dart';
import '../bloc/user_event.dart';
import '../bloc/user_state.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/user_list_item_widget.dart';
import 'user_detail_page.dart';

class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  late UserBloc _userBloc;
  late RefreshController _refreshController;
  late ScrollController _scrollController;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _userBloc = getIt<UserBloc>();
    _refreshController = RefreshController(initialRefresh: false);
    _scrollController = ScrollController();
    
    // Setup scroll listener for infinite loading
    _scrollController.addListener(_onScroll);
    
    // Load initial users
    _userBloc.add(const LoadUsersEvent());
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      final currentState = _userBloc.state;
      if (currentState is UsersLoadedState && 
          currentState.canLoadMore && 
          !_isSearching) {
        _userBloc.add(const LoadMoreUsersEvent());
      }
    }
  }

  void _onRefresh() {
    _userBloc.add(const RefreshUsersEvent());
  }

  void _onSearch(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
    });
    
    if (query.isEmpty) {
      _userBloc.add(const ClearSearchEvent());
    } else {
      _userBloc.add(SearchUsersEvent(query));
    }
  }

  void _onClearSearch() {
    setState(() {
      _isSearching = false;
    });
    _userBloc.add(const ClearSearchEvent());
  }

  void _navigateToUserDetail(UserEntity user) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => UserDetailPage(userId: user.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _userBloc,
      child: Scaffold(
        appBar: _buildAppBar(),
        body: Column(
          children: [
            // Search Bar
            SearchBarWidget(
              onChanged: _onSearch,
              onClear: _onClearSearch,
              hintText: AppConstants.searchHintText,
            ),
            
            // Main Content
            Expanded(
              child: BlocConsumer<UserBloc, UserState>(
                listener: _handleStateChanges,
                builder: _buildContent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('ConnectX'),
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 2,
      actions: [
        // Menu button
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
              value: 'clear_cache',
              child: ListTile(
                leading: Icon(Icons.clear_all),
                title: Text('Clear Cache'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'about',
              child: ListTile(
                leading: Icon(Icons.info),
                title: Text('About'),
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
        _userBloc.add(const RefreshUsersEvent());
        break;
      case 'clear_cache':
        _userBloc.add(const ClearCacheEvent());
        _showSnackBar('Cache cleared');
        break;
      case 'about':
        _showAboutDialog();
        break;
    }
  }

  void _handleStateChanges(BuildContext context, UserState state) {
    if (state is UsersLoadedState) {
      _refreshController.refreshCompleted();
    } else if (state is UserErrorState) {
      _refreshController.refreshFailed();
      if (state.canRetry) {
        _showErrorSnackBar(state.userFriendlyMessage);
      }
    } else if (state is UserCacheClearedState) {
      _userBloc.add(const LoadUsersEvent());
    }
  }

  Widget _buildContent(BuildContext context, UserState state) {
    if (state is UserInitialState || state is UserLoadingState) {
      return _buildLoadingState();
    } else if (state is UsersLoadedState) {
      return _buildLoadedState(state);
    } else if (state is UserSearchResultsState) {
      return _buildSearchResultsState(state);
    } else if (state is UserEmptyState) {
      return _buildEmptyState(state);
    } else if (state is UserErrorState) {
      return _buildErrorState(state);
    } else if (state is UserOfflineState) {
      return _buildOfflineState(state);
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
            AppConstants.loadingMessage,
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadedState(UsersLoadedState state) {
    return SmartRefresher(
      controller: _refreshController,
      onRefresh: _onRefresh,
      enablePullDown: true,
      enablePullUp: false,
      header: const WaterDropMaterialHeader(),
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: state.users.length + (state.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= state.users.length) {
            return _buildPaginationLoader();
          }

          final user = state.users[index];
          return UserListItemWidget(
            user: user,
            onTap: () => _navigateToUserDetail(user),
            showDivider: index < state.users.length - 1,
          );
        },
      ),
    );
  }

  Widget _buildSearchResultsState(UserSearchResultsState state) {
    if (state.isSearching) {
      return _buildSearchLoadingState();
    }

    if (state.hasNoResults) {
      return _buildNoSearchResults(state.query);
    }

    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: state.searchResults.length,
      itemBuilder: (context, index) {
        final user = state.searchResults[index];
        return UserListItemWidget(
          user: user,
          onTap: () => _navigateToUserDetail(user),
          showDivider: index < state.searchResults.length - 1,
        );
      },
    );
  }

  Widget _buildSearchLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: AppConstants.defaultPadding),
          Text('Searching...'),
        ],
      ),
    );
  }

  Widget _buildNoSearchResults(String query) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          Text(
            'No results found',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            'No users found for "$query"',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.largePadding),
          ElevatedButton.icon(
            onPressed: _onClearSearch,
            icon: const Icon(Icons.clear),
            label: const Text('Clear Search'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(UserEmptyState state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            state.isSearchResult ? Icons.search_off : Icons.people_outline,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          Text(
            state.isSearchResult ? 'No search results' : 'No users',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            state.message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.largePadding),
          ElevatedButton.icon(
            onPressed: () => _userBloc.add(const LoadUsersEvent(refresh: true)),
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(UserErrorState state) {
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
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            Text(
              state.isNetworkError 
                  ? 'Connection Error' 
                  : 'Something went wrong',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Text(
              state.userFriendlyMessage,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                onPressed: () => _userBloc.add(const LoadUsersEvent(refresh: true)),
                child: const Text('Refresh Data'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOfflineState(UserOfflineState state) {
    return Column(
      children: [
        // Offline Banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppConstants.smallPadding),
          color: Theme.of(context).colorScheme.errorContainer,
          child: Row(
            children: [
              Icon(
                Icons.wifi_off,
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
              const SizedBox(width: AppConstants.smallPadding),
              Expanded(
                child: Text(
                  state.message,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Cached Users List
        if (state.hasCachedData)
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: state.cachedUsers.length,
              itemBuilder: (context, index) {
                final user = state.cachedUsers[index];
                return UserListItemWidget(
                  user: user,
                  onTap: () => _navigateToUserDetail(user),
                  showDivider: index < state.cachedUsers.length - 1,
                );
              },
            ),
          )
        else
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.wifi_off,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: AppConstants.defaultPadding),
                  const Text(
                    'No offline data available',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: AppConstants.defaultPadding),
                  const Text(
                    'Please connect to the internet to load users',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPaginationLoader() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
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
          onPressed: () => _userBloc.add(const RetryEvent()),
        ),
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: AppConstants.appName,
      applicationVersion: AppConstants.appVersion,
      applicationIcon: const Icon(Icons.people, size: 48),
      children: [
        Text(AppConstants.appDescription),
        const SizedBox(height: 16),
        const Text('Features:'),
        const Text('• User list with pagination'),
        const Text('• Search functionality'),
        const Text('• User detail view'),
        const Text('• Offline support'),
        const Text('• Pull-to-refresh'),
      ],
    );
  }
}