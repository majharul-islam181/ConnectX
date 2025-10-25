import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entites/pagination_entity.dart';
import '../../domain/entites/user_entity.dart';
import '../../domain/repository/user_repository.dart';
import '../datasources/user_local_datasource.dart';
import '../datasources/user_remote_datasource.dart';
import '../models/user_model.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;
  final UserLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  UserRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, PaginationEntity<UserEntity>>> getUsers({
    required int page,
    required int perPage,
  }) async {
    try {
      // Check network connectivity
      final isConnected = await networkInfo.isConnected;
      
      if (isConnected) {
        // Fetch from API
        return await _getUsersFromRemote(page: page, perPage: perPage);
      } else {
        // Fallback to cache when offline
        return await _getUsersFromCache();
      }
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in getUsers',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(UnknownFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getUserById(int id) async {
    try {
      // Check network connectivity
      final isConnected = await networkInfo.isConnected;
      
      if (isConnected) {
        // Fetch from API
        try {
          final response = await remoteDataSource.getUserById(id);
          final user = response.toEntity();
          
          AppLogger.info('User $id fetched successfully from API');
          return Right(user);
        } on ServerException catch (e) {
          AppLogger.error('Server error while fetching user $id', error: e);
          return Left(ServerFailure(e.message));
        } on NetworkException catch (e) {
          AppLogger.error('Network error while fetching user $id', error: e);
          return Left(NetworkFailure(e.message));
        } on NotFoundedException catch (e) {
          AppLogger.error('User $id not found', error: e);
          return Left(NotFoundFailure(e.message));
        }
      } else {
        // Try to find user in cache when offline
        return await _getUserFromCache(id);
      }
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in getUserById',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(UnknownFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<UserEntity>>> searchUsers(String query) async {
    try {
      // Search is performed locally on cached data
      final users = await localDataSource.searchCachedUsers(query);
      final entities = users.map((model) => model.toEntity()).toList();
      
      AppLogger.info('Search completed: found ${entities.length} users for query "$query"');
      return Right(entities);
    } on CacheException catch (e) {
      AppLogger.error('Cache error during search', error: e);
      return Left(CacheFailure(e.message));
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in searchUsers',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(UnknownFailure('Search failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<UserEntity>>> getCachedUsers() async {
    try {
      final users = await localDataSource.getCachedUsers();
      final entities = users.map((model) => model.toEntity()).toList();
      
      AppLogger.info('Retrieved ${entities.length} users from cache');
      return Right(entities);
    } on CacheException catch (e) {
      AppLogger.error('Cache error while getting cached users', error: e);
      return Left(CacheFailure(e.message));
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in getCachedUsers',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(UnknownFailure('Failed to get cached users: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> cacheUsers(List<UserEntity> users) async {
    try {
      final models = users.map((entity) => UserModel.fromEntity(entity)).toList();
      await localDataSource.cacheUsers(models);
      
      AppLogger.info('Successfully cached ${users.length} users');
      return const Right(null);
    } on CacheException catch (e) {
      AppLogger.error('Cache error while caching users', error: e);
      return Left(CacheFailure(e.message));
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in cacheUsers',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(UnknownFailure('Failed to cache users: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> clearCache() async {
    try {
      await localDataSource.clearCache();
      AppLogger.info('User cache cleared successfully');
      return const Right(null);
    } on CacheException catch (e) {
      AppLogger.error('Cache error while clearing cache', error: e);
      return Left(CacheFailure(e.message));
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in clearCache',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(UnknownFailure('Failed to clear cache: ${e.toString()}'));
    }
  }

  @override
  Future<bool> hasCache() async {
    try {
      return await localDataSource.hasCache();
    } catch (e, stackTrace) {
      AppLogger.error(
        'Error checking cache existence',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  @override
  Future<DateTime?> getCacheTimestamp() async {
    try {
      return await localDataSource.getCacheTimestamp();
    } catch (e, stackTrace) {
      AppLogger.error(
        'Error getting cache timestamp',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  @override
  Future<Either<Failure, PaginationEntity<UserEntity>>> refreshUsers({
    required int page,
    required int perPage,
  }) async {
    try {
      // Clear cache first
      await localDataSource.clearCache();
      AppLogger.info('Cache cleared for refresh');
      
      // Fetch fresh data
      return await _getUsersFromRemote(page: page, perPage: perPage);
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in refreshUsers',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(UnknownFailure('Refresh failed: ${e.toString()}'));
    }
  }

  // Private helper methods

  Future<Either<Failure, PaginationEntity<UserEntity>>> _getUsersFromRemote({
    required int page,
    required int perPage,
  }) async {
    try {
      final response = await remoteDataSource.getUsers(
        page: page,
        perPage: perPage,
      );
      
      final paginationEntity = response.toPaginationEntity();
      
      // Cache the fetched users (only first page or append to existing cache)
      if (page == 1) {
        // Replace cache with new data for first page
        final models = response.data;
        await localDataSource.cacheUsers(models);
        AppLogger.info('Cached ${models.length} users from first page');
      } else {
        // For subsequent pages, append to existing cache
        try {
          final existingUsers = await localDataSource.getCachedUsers();
          final newUsers = [...existingUsers, ...response.data];
          await localDataSource.cacheUsers(newUsers);
          AppLogger.info('Appended ${response.data.length} users to cache (total: ${newUsers.length})');
        } catch (e) {
          // If cache append fails, just cache current page data
          await localDataSource.cacheUsers(response.data);
          AppLogger.warning('Failed to append to cache, cached current page only', error: e);
        }
      }
      
      AppLogger.info('Users fetched successfully from API: page $page, ${paginationEntity.data.length} users');
      return Right(paginationEntity);
      
    } on ServerException catch (e) {
      AppLogger.error('Server error while fetching users', error: e);
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      AppLogger.error('Network error while fetching users', error: e);
      return Left(NetworkFailure(e.message));
    } on TimeoutException catch (e) {
      AppLogger.error('Timeout error while fetching users', error: e);
      return Left(TimeoutFailure(e.message));
    } on ConnectionException catch (e) {
      AppLogger.error('Connection error while fetching users', error: e);
      return Left(ConnectionFailure(e.message));
    }
  }

  Future<Either<Failure, PaginationEntity<UserEntity>>> _getUsersFromCache() async {
    try {
      // Check if cache is valid
      final isCacheValid = await localDataSource.isCacheValid();
      if (!isCacheValid) {
        AppLogger.warning('Cache is expired, but no network available');
        return Left(NetworkFailure('No internet connection and cache is expired'));
      }

      final users = await localDataSource.getCachedUsers();
      if (users.isEmpty) {
        AppLogger.warning('No cached users available');
        return Left(CacheFailure('No cached data available'));
      }

      final entities = users.map((model) => model.toEntity()).toList();
      
      // Create pagination entity for cached data
      final paginationEntity = PaginationEntity<UserEntity>(
        data: entities,
        page: 1,
        perPage: entities.length,
        total: entities.length,
        totalPages: 1,
      );
      
      AppLogger.info('Retrieved ${entities.length} users from cache (offline mode)');
      return Right(paginationEntity);
      
    } on CacheException catch (e) {
      AppLogger.error('Cache error while getting offline users', error: e);
      return Left(CacheFailure(e.message));
    }
  }

  Future<Either<Failure, UserEntity>> _getUserFromCache(int id) async {
    try {
      final users = await localDataSource.getCachedUsers();
      final user = users.where((user) => user.id == id).firstOrNull;
      
      if (user == null) {
        AppLogger.warning('User $id not found in cache');
        return Left(NotFoundFailure('User not found in cache'));
      }
      
      AppLogger.info('User $id found in cache (offline mode)');
      return Right(user.toEntity());
      
    } on CacheException catch (e) {
      AppLogger.error('Cache error while getting user from cache', error: e);
      return Left(CacheFailure(e.message));
    }
  }
}

extension _ListExtension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}