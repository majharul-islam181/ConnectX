import 'package:equatable/equatable.dart';
import '../../domain/entites/pagination_entity.dart';
import '../../domain/entites/user_entity.dart';
import 'user_event.dart';

/// Base class for all user states
abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object?> get props => [];
}

/// Initial state when bloc is created
class UserInitialState extends UserState {
  const UserInitialState();

  @override
  String toString() => 'UserInitialState()';
}

/// Loading state for initial data fetch
class UserLoadingState extends UserState {
  const UserLoadingState();

  @override
  String toString() => 'UserLoadingState()';
}

/// Users loaded successfully
class UsersLoadedState extends UserState {
  final List<UserEntity> users;
  final PaginationEntity<UserEntity> pagination;
  final bool hasReachedMax;
  final bool isLoadingMore;
  final bool isSearching;
  final String searchQuery;

  const UsersLoadedState({
    required this.users,
    required this.pagination,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
    this.isSearching = false,
    this.searchQuery = '',
  });

  /// Get current page number
  int get currentPage => pagination.page;

  /// Check if there are more pages to load
  bool get canLoadMore => !hasReachedMax && !isLoadingMore;

  /// Check if this is the first page
  bool get isFirstPage => pagination.isFirstPage;

  /// Get total number of users
  int get totalUsers => pagination.total;

  /// Create copy with modified fields
  UsersLoadedState copyWith({
    List<UserEntity>? users,
    PaginationEntity<UserEntity>? pagination,
    bool? hasReachedMax,
    bool? isLoadingMore,
    bool? isSearching,
    String? searchQuery,
  }) {
    return UsersLoadedState(
      users: users ?? this.users,
      pagination: pagination ?? this.pagination,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isSearching: isSearching ?? this.isSearching,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
        users,
        pagination,
        hasReachedMax,
        isLoadingMore,
        isSearching,
        searchQuery,
      ];

  @override
  String toString() {
    return 'UsersLoadedState(users: ${users.length}, page: ${pagination.page}/${pagination.totalPages}, hasReachedMax: $hasReachedMax, isLoadingMore: $isLoadingMore, isSearching: $isSearching, searchQuery: "$searchQuery")';
  }
}

/// Search results state
class UserSearchResultsState extends UserState {
  final List<UserEntity> searchResults;
  final String query;
  final bool isSearching;

  const UserSearchResultsState({
    required this.searchResults,
    required this.query,
    this.isSearching = false,
  });

  /// Check if search returned no results
  bool get hasNoResults => searchResults.isEmpty && query.isNotEmpty;

  /// Create copy with modified fields
  UserSearchResultsState copyWith({
    List<UserEntity>? searchResults,
    String? query,
    bool? isSearching,
  }) {
    return UserSearchResultsState(
      searchResults: searchResults ?? this.searchResults,
      query: query ?? this.query,
      isSearching: isSearching ?? this.isSearching,
    );
  }

  @override
  List<Object?> get props => [searchResults, query, isSearching];

  @override
  String toString() {
    return 'UserSearchResultsState(results: ${searchResults.length}, query: "$query", isSearching: $isSearching)';
  }
}

/// User detail loading state
class UserDetailLoadingState extends UserState {
  final int userId;

  const UserDetailLoadingState(this.userId);

  @override
  List<Object?> get props => [userId];

  @override
  String toString() => 'UserDetailLoadingState(userId: $userId)';
}

/// User detail loaded successfully
class UserDetailLoadedState extends UserState {
  final UserEntity user;

  const UserDetailLoadedState(this.user);

  @override
  List<Object?> get props => [user];

  @override
  String toString() => 'UserDetailLoadedState(user: ${user.fullName})';
}

/// Error state with retry capability
class UserErrorState extends UserState {
  final String message;
  final String? errorCode;
  final bool canRetry;
  final UserEvent? lastEvent;

  const UserErrorState({
    required this.message,
    this.errorCode,
    this.canRetry = true,
    this.lastEvent,
  });

  /// Check if this is a network error
  bool get isNetworkError => 
      errorCode?.contains('network') == true || 
      message.toLowerCase().contains('network') ||
      message.toLowerCase().contains('internet') ||
      message.toLowerCase().contains('connection');

  /// Check if this is a server error
  bool get isServerError => 
      errorCode?.contains('server') == true || 
      message.toLowerCase().contains('server');

  /// Check if this is a cache error (offline mode issue)
  bool get isCacheError => 
      errorCode?.contains('cache') == true || 
      message.toLowerCase().contains('cache') ||
      message.toLowerCase().contains('offline');

  /// Get user-friendly error message
  String get userFriendlyMessage {
    if (isNetworkError) {
      return 'Please check your internet connection and try again.';
    } else if (isServerError) {
      return 'Server is currently unavailable. Please try again later.';
    } else if (isCacheError) {
      return 'No offline data available. Please connect to the internet.';
    } else {
      return message;
    }
  }

  @override
  List<Object?> get props => [message, errorCode, canRetry, lastEvent];

  @override
  String toString() {
    return 'UserErrorState(message: "$message", errorCode: $errorCode, canRetry: $canRetry)';
  }
}

/// Empty state when no users are available
class UserEmptyState extends UserState {
  final String message;
  final bool isSearchResult;

  const UserEmptyState({
    this.message = 'No users found',
    this.isSearchResult = false,
  });

  @override
  List<Object?> get props => [message, isSearchResult];

  @override
  String toString() => 'UserEmptyState(message: "$message", isSearchResult: $isSearchResult)';
}

/// Cache cleared state
class UserCacheClearedState extends UserState {
  const UserCacheClearedState();

  @override
  String toString() => 'UserCacheClearedState()';
}

/// Offline mode state
class UserOfflineState extends UserState {
  final List<UserEntity> cachedUsers;
  final String message;

  const UserOfflineState({
    required this.cachedUsers,
    this.message = 'You are offline. Showing cached data.',
  });

  /// Check if there are cached users available
  bool get hasCachedData => cachedUsers.isNotEmpty;

  @override
  List<Object?> get props => [cachedUsers, message];

  @override
  String toString() => 'UserOfflineState(cachedUsers: ${cachedUsers.length}, message: "$message")';
}