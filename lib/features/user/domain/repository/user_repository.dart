import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entites/pagination_entity.dart';
import '../entites/user_entity.dart';

abstract class UserRepository {
  /// Get paginated list of users
  Future<Either<Failure, PaginationEntity<UserEntity>>> getUsers({
    required int page,
    required int perPage,
  });

  Future<Either<Failure, UserEntity>> getUserById(int id);

  Future<Either<Failure, List<UserEntity>>> searchUsers(String query);

  /// Get cached users for offline access
  Future<Either<Failure, List<UserEntity>>> getCachedUsers();

  /// Cache users locally
  Future<Either<Failure, void>> cacheUsers(List<UserEntity> users);

  /// Clear user cache
  Future<Either<Failure, void>> clearCache();

  /// Check if users are cached
  Future<bool> hasCache();

  /// Get cache timestamp
  Future<DateTime?> getCacheTimestamp();

  /// Refresh users (clear cache and fetch new data)
  Future<Either<Failure, PaginationEntity<UserEntity>>> refreshUsers({
    required int page,
    required int perPage,
  });
}