import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/logger.dart';
import '../models/user_model.dart';

abstract class UserLocalDataSource {
  /// Get cached users
  Future<List<UserModel>> getCachedUsers();

  /// Cache users locally
  Future<void> cacheUsers(List<UserModel> users);

  /// Search users in cache
  Future<List<UserModel>> searchCachedUsers(String query);

  /// Clear user cache
  Future<void> clearCache();

  /// Check if cache exists
  Future<bool> hasCache();

  /// Get cache timestamp
  Future<DateTime?> getCacheTimestamp();

  /// Check if cache is valid
  Future<bool> isCacheValid();
}

class UserLocalDataSourceImpl implements UserLocalDataSource {
  final SharedPreferences sharedPreferences;

  UserLocalDataSourceImpl(this.sharedPreferences);

  static const String _usersKey = 'cached_users';
  static const String _timestampKey = 'cache_timestamp';

  @override
  Future<List<UserModel>> getCachedUsers() async {
    try {
      AppLogger.cache(operation: 'read', key: _usersKey);

      final jsonString = sharedPreferences.getString(_usersKey);
      if (jsonString == null) {
        AppLogger.cache(operation: 'read', key: _usersKey, hit: false);
        throw const CacheException('No cached users found');
      }

      final jsonList = json.decode(jsonString) as List<dynamic>;
      final users = jsonList
          .map((json) => UserModel.fromJson(json as Map<String, dynamic>))
          .toList();

      AppLogger.cache(
        operation: 'read',
        key: _usersKey,
        hit: true,
        size: '${users.length} users',
      );

      AppLogger.debug('Retrieved ${users.length} users from cache');
      return users;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to get cached users',
        error: e,
        stackTrace: stackTrace,
      );
      
      if (e is CacheException) rethrow;
      throw CacheException('Failed to read cached users: ${e.toString()}');
    }
  }

  @override
  Future<void> cacheUsers(List<UserModel> users) async {
    try {
      AppLogger.cache(operation: 'write', key: _usersKey, size: '${users.length} users');

      final jsonList = users.map((user) => user.toJson()).toList();
      final jsonString = json.encode(jsonList);

      final success = await sharedPreferences.setString(_usersKey, jsonString);
      if (!success) {
        throw const CacheException('Failed to save users to cache');
      }

      // Save timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      await sharedPreferences.setInt(_timestampKey, timestamp);

      AppLogger.debug('Cached ${users.length} users successfully');
      AppLogger.cache(
        operation: 'write',
        key: _usersKey,
        size: '${jsonString.length} bytes',
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to cache users',
        error: e,
        stackTrace: stackTrace,
      );
      
      if (e is CacheException) rethrow;
      throw CacheException('Failed to write users to cache: ${e.toString()}');
    }
  }

  @override
  Future<List<UserModel>> searchCachedUsers(String query) async {
    try {
      final cachedUsers = await getCachedUsers();
      final normalizedQuery = query.toLowerCase().trim();

      if (normalizedQuery.isEmpty) {
        return cachedUsers;
      }

      final filteredUsers = cachedUsers.where((user) {
        final fullName = user.fullName.toLowerCase();
        final firstName = user.firstName.toLowerCase();
        final lastName = user.lastName.toLowerCase();
        final email = user.email.toLowerCase();

        return fullName.contains(normalizedQuery) ||
               firstName.contains(normalizedQuery) ||
               lastName.contains(normalizedQuery) ||
               email.contains(normalizedQuery);
      }).toList();

      AppLogger.debug(
        'Search completed: "${query}" found ${filteredUsers.length} results out of ${cachedUsers.length} users',
      );

      return filteredUsers;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to search cached users',
        error: e,
        stackTrace: stackTrace,
      );
      
      if (e is CacheException) rethrow;
      throw CacheException('Failed to search cached users: ${e.toString()}');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      AppLogger.cache(operation: 'clear', key: _usersKey);

      await sharedPreferences.remove(_usersKey);
      await sharedPreferences.remove(_timestampKey);

      AppLogger.debug('User cache cleared successfully');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to clear cache',
        error: e,
        stackTrace: stackTrace,
      );
      throw CacheException('Failed to clear cache: ${e.toString()}');
    }
  }

  @override
  Future<bool> hasCache() async {
    try {
      final hasData = sharedPreferences.containsKey(_usersKey);
      AppLogger.cache(operation: 'check', key: _usersKey, hit: hasData);
      return hasData;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to check cache existence',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  @override
  Future<DateTime?> getCacheTimestamp() async {
    try {
      final timestamp = sharedPreferences.getInt(_timestampKey);
      if (timestamp == null) return null;

      final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      AppLogger.debug('Cache timestamp: $dateTime');
      return dateTime;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to get cache timestamp',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  @override
  Future<bool> isCacheValid() async {
    try {
      final timestamp = await getCacheTimestamp();
      if (timestamp == null) return false;

      final now = DateTime.now();
      final difference = now.difference(timestamp);
      final isValid = difference < AppConstants.cacheValidDuration;

      AppLogger.debug(
        'Cache validity check: ${isValid ? 'VALID' : 'EXPIRED'} '
        '(age: ${difference.inMinutes} minutes, max: ${AppConstants.cacheValidDuration.inMinutes} minutes)',
      );

      return isValid;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to check cache validity',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }
}
