import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entites/user_entity.dart';
import '../repository/user_repository.dart';

class SearchUsers implements UseCase<List<UserEntity>, SearchParams> {
  final UserRepository repository;

  SearchUsers(this.repository);

  @override
  Future<Either<Failure, List<UserEntity>>> call(SearchParams params) async {
    return await repository.searchUsers(params.query);
  }
}