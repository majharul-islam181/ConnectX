import 'package:dartz/dartz.dart';
import '../errors/failures.dart';

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

abstract class StreamUseCase<Type, Params> {
  Stream<Either<Failure, Type>> call(Params params);
}

class NoParams {
  const NoParams();
}

class PaginationParams {
  final int page;
  final int perPage;
  final String? searchQuery;

  const PaginationParams({
    required this.page,
    this.perPage = 10,
    this.searchQuery,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaginationParams &&
        other.page == page &&
        other.perPage == perPage &&
        other.searchQuery == searchQuery;
  }

  @override
  int get hashCode => page.hashCode ^ perPage.hashCode ^ searchQuery.hashCode;

  @override
  String toString() => 'PaginationParams(page: $page, perPage: $perPage, searchQuery: $searchQuery)';
}

class SearchParams {
  final String query;
  final int? limit;

  const SearchParams({
    required this.query,
    this.limit,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SearchParams &&
        other.query == query &&
        other.limit == limit;
  }

  @override
  int get hashCode => query.hashCode ^ limit.hashCode;

  @override
  String toString() => 'SearchParams(query: $query, limit: $limit)';
}

class IdParams {
  final int id;

  const IdParams({required this.id});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is IdParams && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'IdParams(id: $id)';
}