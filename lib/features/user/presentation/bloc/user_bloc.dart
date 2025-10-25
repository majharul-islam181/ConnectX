import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:connectx_app/core/constants/app_constants.dart';
import 'package:connectx_app/core/errors/failures.dart';
import 'package:connectx_app/core/usecases/usecase.dart';
import 'package:connectx_app/core/utils/logger.dart';
import 'package:connectx_app/features/user/domain/entities/user_entity.dart';
import 'package:connectx_app/features/user/domain/entities/pagination_entity.dart';
import 'package:connectx_app/features/user/domain/usecases/get_users.dart';
import 'package:connectx_app/features/user/domain/usecases/get_user_detail.dart';
import 'package:connectx_app/features/user/domain/usecases/search_users.dart';
import 'package:connectx_app/features/user/domain/usecases/refresh_users.dart';
import 'package:connectx_app/features/user/presentation/bloc/user_event.dart';
import 'package:connectx_app/features/user/presentation/bloc/user_state.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entites/user_entity.dart';
import '../../domain/usecases/refresh_users.dart';
import '../../domain/usecases/search_users.dart';
import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final GetUsers _getUsers;
  final GetUserDetail _getUserDetail;
  final SearchUsers _searchUsers;
  final RefreshUsers _refreshUsers;

  // Internal state tracking
  int _currentPage = 1;
  List<UserEntity> _allUsers = [];
  bool _hasReachedMax = false;
  String _currentSearchQuery = '';
  Timer? _searchDebounceTimer;

  UserBloc({
    required GetUsers getUsers,
    required GetUserDetail getUserDetail,
    required SearchUsers searchUsers,
    required RefreshUsers refreshUsers,
  })  : _getUsers = getUsers,
        _getUserDetail = getUserDetail,
        _searchUsers = searchUsers,
        _refreshUsers = refreshUsers,
        super(const UserInitialState()) {
    // Register event handlers
    on<LoadUsersEvent>(_onLoadUsers);
    on<LoadMoreUsersEvent>(_onLoadMoreUsers);
    on<SearchUsersEvent>(_onSearchUsers);
    on<ClearSearchEvent>(_onClearSearch);
    on<LoadUserDetailEvent>(_onLoadUserDetail);
    on<RefreshUsersEvent>(_onRefreshUsers);
    on<RetryEvent>(_onRetry);
    on<ResetUserDetailEvent>(_onResetUserDetail);
  }

  @override
  Future<void> close() {
    _searchDebounceTimer?.cancel();
    return super.close();
  }

  /// Load initial users or refresh
  Future<void> _onLoadUsers(LoadUsersEvent event, Emitter<UserState> emit) async {
    try {
      AppLogger.bloc('UserBloc', 'LoadUsersEvent', {'refresh': event.refresh});

      if (event.refresh) {
        // Reset pagination for refresh
        _currentPage = 1;
        _allUsers.clear();
        _hasReachedMax = false;
      }

      if (state is! UsersLoadedState || event.refresh) {
        emit(const UserLoadingState());
      }

      final result = await _getUsers(PaginationParams(
        page: _currentPage,
        perPage: AppConstants.defaultPerPage,
      ));

      result.fold(
        (failure) {
          AppLogger.error('Failed to load users', error: failure);
          emit(UserErrorState(
            message: _mapFailureToMessage(failure),
            canRetry: true,
            lastEvent: event,
          ));
        },
        (paginationEntity) {
          _currentPage = paginationEntity.page;
          _hasReachedMax = !paginationEntity.hasMorePages;

          if (event.refresh) {
            _allUsers = paginationEntity.data;
          } else {
            _allUsers.addAll(paginationEntity.data);
          }

          AppLogger.info(
            'Users loaded successfully: ${_allUsers.length} total, page $_currentPage/${paginationEntity.totalPages}',
          );

          emit(UsersLoadedState(
            users: List.from(_allUsers),
            pagination: paginationEntity,
            hasReachedMax: _hasReachedMax,
          ));
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error in LoadUsersEvent', error: e, stackTrace: stackTrace);
      emit(UserErrorState(
        message: 'An unexpected error occurred. Please try again.',
        canRetry: true,
        lastEvent: event,
      ));
    }
  }

  /// Load more users for infinite scrolling
  Future<void> _onLoadMoreUsers(LoadMoreUsersEvent event, Emitter<UserState> emit) async {
    try {
      AppLogger.bloc('UserBloc', 'LoadMoreUsersEvent', {'currentPage': _currentPage});

      if (_hasReachedMax) {
        AppLogger.debug('Already reached max pages, ignoring load more');
        return;
      }

      final currentState = state;
      if (currentState is UsersLoadedState) {
        // Show loading indicator for pagination
        emit(currentState.copyWith(isLoadingMore: true));

        final nextPage = _currentPage + 1;
        final result = await _getUsers(PaginationParams(
          page: nextPage,
          perPage: AppConstants.defaultPerPage,
        ));

        result.fold(
          (failure) {
            AppLogger.error('Failed to load more users', error: failure);
            // Restore previous state and show error
            emit(currentState.copyWith(isLoadingMore: false));
            emit(UserErrorState(
              message: _mapFailureToMessage(failure),
              canRetry: true,
              lastEvent: event,
            ));
          },
          (paginationEntity) {
            _currentPage = paginationEntity.page;
            _hasReachedMax = !paginationEntity.hasMorePages;
            _allUsers.addAll(paginationEntity.data);

            AppLogger.info(
              'More users loaded: ${paginationEntity.data.length} new, ${_allUsers.length} total',
            );

            emit(UsersLoadedState(
              users: List.from(_allUsers),
              pagination: paginationEntity.copyWith(data: _allUsers),
              hasReachedMax: _hasReachedMax,
              isLoadingMore: false,
            ));
          },
        );
      }
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error in LoadMoreUsersEvent', error: e, stackTrace: stackTrace);
      final currentState = state;
      if (currentState is UsersLoadedState) {
        emit(currentState.copyWith(isLoadingMore: false));
      }
      emit(UserErrorState(
        message: 'Failed to load more users. Please try again.',
        canRetry: true,
        lastEvent: event,
      ));
    }
  }

  /// Search users with debouncing
  Future<void> _onSearchUsers(SearchUsersEvent event, Emitter<UserState> emit) async {
    try {
      AppLogger.bloc('UserBloc', 'SearchUsersEvent', {'query': event.query});

      _currentSearchQuery = event.query;

      // Cancel previous search timer
      _searchDebounceTimer?.cancel();

      if (event.query.isEmpty) {
        // Return to normal list if query is empty
        add(const ClearSearchEvent());
        return;
      }

      if (event.query.length < AppConstants.minSearchLength) {
        AppLogger.debug('Search query too short, ignoring');
        return;
      }

      // Update current state to show search in progress
      final currentState = state;
      if (currentState is UsersLoadedState) {
        emit(currentState.copyWith(
          isSearching: true,
          searchQuery: event.query,
        ));
      }

      // Debounce search
      _searchDebounceTimer = Timer(AppConstants.searchDebounceTime, () async {
        if (_currentSearchQuery == event.query) {
          await _performSearch(event.query, emit);
        }
      });
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error in SearchUsersEvent', error: e, stackTrace: stackTrace);
      emit(UserErrorState(
        message: 'Search failed. Please try again.',
        canRetry: true,
        lastEvent: event,
      ));
    }
  }

  /// Perform the actual search
  Future<void> _performSearch(String query, Emitter<UserState> emit) async {
    try {
      final result = await _searchUsers(SearchParams(query: query));

      result.fold(
        (failure) {
          AppLogger.error('Search failed', error: failure);
          emit(UserErrorState(
            message: _mapFailureToMessage(failure),
            canRetry: true,
            lastEvent: SearchUsersEvent(query),
          ));
        },
        (searchResults) {
          AppLogger.info('Search completed: ${searchResults.length} results for "$query"');

          if (searchResults.isEmpty) {
            emit(UserEmptyState(
              message: 'No users found for "$query"',
              isSearchResult: true,
            ));
          } else {
            emit(UserSearchResultsState(
              searchResults: searchResults,
              query: query,
              isSearching: false,
            ));
          }
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error during search', error: e, stackTrace: stackTrace);
      emit(UserErrorState(
        message: 'Search failed. Please try again.',
        canRetry: true,
        lastEvent: SearchUsersEvent(query),
      ));
    }
  }

  /// Clear search and return to normal list
  Future<void> _onClearSearch(ClearSearchEvent event, Emitter<UserState> emit) async {
    try {
      AppLogger.bloc('UserBloc', 'ClearSearchEvent', {});

      _currentSearchQuery = '';
      _searchDebounceTimer?.cancel();

      if (_allUsers.isNotEmpty) {
        // Return to the normal loaded state
        final pagination = PaginationEntity<UserEntity>(
          data: _allUsers,
          page: _currentPage,
          perPage: AppConstants.defaultPerPage,
          total: _allUsers.length,
          totalPages: (_allUsers.length / AppConstants.defaultPerPage).ceil(),
        );

        emit(UsersLoadedState(
          users: List.from(_allUsers),
          pagination: pagination,
          hasReachedMax: _hasReachedMax,
        ));
      } else {
        // Reload users if no data available
        add(const LoadUsersEvent());
      }
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error in ClearSearchEvent', error: e, stackTrace: stackTrace);
      emit(UserErrorState(
        message: 'Failed to clear search. Please try again.',
        canRetry: true,
        lastEvent: event,
      ));
    }
  }

  /// Load user detail
  Future<void> _onLoadUserDetail(LoadUserDetailEvent event, Emitter<UserState> emit) async {
    try {
      AppLogger.bloc('UserBloc', 'LoadUserDetailEvent', {'userId': event.userId});

      emit(UserDetailLoadingState(event.userId));

      final result = await _getUserDetail(IdParams(id: event.userId));

      result.fold(
        (failure) {
          AppLogger.error('Failed to load user detail', error: failure);
          emit(UserErrorState(
            message: _mapFailureToMessage(failure),
            canRetry: true,
            lastEvent: event,
          ));
        },
        (user) {
          AppLogger.info('User detail loaded: ${user.fullName}');
          emit(UserDetailLoadedState(user));
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error in LoadUserDetailEvent', error: e, stackTrace: stackTrace);
      emit(UserErrorState(
        message: 'Failed to load user details. Please try again.',
        canRetry: true,
        lastEvent: event,
      ));
    }
  }

  /// Refresh users (pull-to-refresh)
  Future<void> _onRefreshUsers(RefreshUsersEvent event, Emitter<UserState> emit) async {
    try {
      AppLogger.bloc('UserBloc', 'RefreshUsersEvent', {});

      // Reset pagination
      _currentPage = 1;
      _allUsers.clear();
      _hasReachedMax = false;

      final result = await _refreshUsers(PaginationParams(
        page: 1,
        perPage: AppConstants.defaultPerPage,
      ));

      result.fold(
        (failure) {
          AppLogger.error('Failed to refresh users', error: failure);
          emit(UserErrorState(
            message: _mapFailureToMessage(failure),
            canRetry: true,
            lastEvent: event,
          ));
        },
        (paginationEntity) {
          _currentPage = paginationEntity.page;
          _hasReachedMax = !paginationEntity.hasMorePages;
          _allUsers = paginationEntity.data;

          AppLogger.info('Users refreshed successfully: ${_allUsers.length} users');

          emit(UsersLoadedState(
            users: List.from(_allUsers),
            pagination: paginationEntity,
            hasReachedMax: _hasReachedMax,
          ));
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error in RefreshUsersEvent', error: e, stackTrace: stackTrace);
      emit(UserErrorState(
        message: 'Failed to refresh. Please try again.',
        canRetry: true,
        lastEvent: event,
      ));
    }
  }

  /// Retry last failed operation
  Future<void> _onRetry(RetryEvent event, Emitter<UserState> emit) async {
    try {
      AppLogger.bloc('UserBloc', 'RetryEvent', {});

      final currentState = state;
      if (currentState is UserErrorState && currentState.lastEvent != null) {
        AppLogger.info('Retrying last event: ${currentState.lastEvent.runtimeType}');
        add(currentState.lastEvent!);
      } else {
        // Default retry behavior - reload users
        add(const LoadUsersEvent());
      }
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error in RetryEvent', error: e, stackTrace: stackTrace);
      emit(UserErrorState(
        message: 'Retry failed. Please try again.',
        canRetry: true,
        lastEvent: event,
      ));
    }
  }

  /// Reset user detail state
  Future<void> _onResetUserDetail(ResetUserDetailEvent event, Emitter<UserState> emit) async {
    try {
      AppLogger.bloc('UserBloc', 'ResetUserDetailEvent', {});

      // Return to previous state or initial state
      if (_allUsers.isNotEmpty) {
        final pagination = PaginationEntity<UserEntity>(
          data: _allUsers,
          page: _currentPage,
          perPage: AppConstants.defaultPerPage,
          total: _allUsers.length,
          totalPages: (_allUsers.length / AppConstants.defaultPerPage).ceil(),
        );

        emit(UsersLoadedState(
          users: List.from(_allUsers),
          pagination: pagination,
          hasReachedMax: _hasReachedMax,
        ));
      } else {
        emit(const UserInitialState());
      }
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error in ResetUserDetailEvent', error: e, stackTrace: stackTrace);
      emit(const UserInitialState());
    }
  }

  /// Map failures to user-friendly messages
  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case NetworkFailure:
        return AppConstants.networkErrorMessage;
      case ServerFailure:
        return AppConstants.serverErrorMessage;
      case ConnectionFailure:
        return 'Connection failed. Please check your internet connection.';
      case TimeoutFailure:
        return 'Request timeout. Please try again.';
      case NotFoundFailure:
        return 'User not found.';
      case CacheFailure:
        return 'No offline data available.';
      case ValidationFailure:
        return 'Invalid request. Please try again.';
      case UnauthorizedFailure:
        return 'Authentication failed. Please check your API key.';
      case ForbiddenFailure:
        return 'Access denied.';
      default:
        return failure.message ?? AppConstants.unknownErrorMessage;
    }
  }
}