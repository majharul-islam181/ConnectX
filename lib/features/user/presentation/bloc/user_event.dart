import 'package:equatable/equatable.dart';

/// Base class for all user events
abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

/// Load initial users (first page)
class LoadUsersEvent extends UserEvent {
  final bool refresh;

  const LoadUsersEvent({this.refresh = false});

  @override
  List<Object?> get props => [refresh];

  @override
  String toString() => 'LoadUsersEvent(refresh: $refresh)';
}

/// Load more users for pagination (infinite scroll)
class LoadMoreUsersEvent extends UserEvent {
  const LoadMoreUsersEvent();

  @override
  String toString() => 'LoadMoreUsersEvent()';
}

/// Search users locally
class SearchUsersEvent extends UserEvent {
  final String query;

  const SearchUsersEvent(this.query);

  @override
  List<Object?> get props => [query];

  @override
  String toString() => 'SearchUsersEvent(query: "$query")';
}

/// Clear search and return to normal list
class ClearSearchEvent extends UserEvent {
  const ClearSearchEvent();

  @override
  String toString() => 'ClearSearchEvent()';
}

/// Load user detail by ID
class LoadUserDetailEvent extends UserEvent {
  final int userId;

  const LoadUserDetailEvent(this.userId);

  @override
  List<Object?> get props => [userId];

  @override
  String toString() => 'LoadUserDetailEvent(userId: $userId)';
}

/// Refresh users (pull-to-refresh)
class RefreshUsersEvent extends UserEvent {
  const RefreshUsersEvent();

  @override
  String toString() => 'RefreshUsersEvent()';
}

/// Clear cache
class ClearCacheEvent extends UserEvent {
  const ClearCacheEvent();

  @override
  String toString() => 'ClearCacheEvent()';
}

/// Retry failed operation
class RetryEvent extends UserEvent {
  const RetryEvent();

  @override
  String toString() => 'RetryEvent()';
}

/// Reset user detail state
class ResetUserDetailEvent extends UserEvent {
  const ResetUserDetailEvent();

  @override
  String toString() => 'ResetUserDetailEvent()';
}