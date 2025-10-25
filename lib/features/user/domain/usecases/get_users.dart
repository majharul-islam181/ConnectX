import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entites/pagination_entity.dart';
import '../entites/user_entity.dart';
import '../repository/user_repository.dart';

class GetUsers implements UseCase<PaginationEntity<UserEntity>, PaginationParams> {
  final UserRepository repository;

  GetUsers(this.repository);

  @override
  Future<Either<Failure, PaginationEntity<UserEntity>>> call(PaginationParams params) async {
    return await repository.getUsers(
      page: params.page,
      perPage: params.perPage,
    );
  }
}