import 'package:dartz/dartz.dart';
import '../../../../core/usecases/usecase.dart';
import '../entites/user_entity.dart';
import '../repository/user_repository.dart';
import '../../../../core/errors/failures.dart';

class GetUserDetail implements UseCase<UserEntity, IdParams> {
  final UserRepository repository;

  GetUserDetail(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(IdParams params) async {
    return await repository.getUserById(params.id);
  }
}