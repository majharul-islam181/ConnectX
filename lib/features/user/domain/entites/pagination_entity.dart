import 'package:equatable/equatable.dart';

class PaginationEntity<T> extends Equatable {
  final List<T> data;
  final int page;
  final int perPage;
  final int total;
  final int totalPages;

  const PaginationEntity({
    required this.data,
    required this.page,
    required this.perPage,
    required this.total,
    required this.totalPages,
  });

  /// Check if there are more pages available
  bool get hasMorePages => page < totalPages;

  /// Check if this is the first page
  bool get isFirstPage => page == 1;

  /// Check if this is the last page
  bool get isLastPage => page == totalPages;

  /// Get the next page number (null if no more pages)
  int? get nextPage => hasMorePages ? page + 1 : null;

  /// Get the previous page number (null if first page)
  int? get previousPage => page > 1 ? page - 1 : null;

  /// Calculate the range of items on current page
  String get itemRange {
    final start = (page - 1) * perPage + 1;
    final end = page * perPage > total ? total : page * perPage;
    return '$start-$end of $total';
  }

  /// Create a copy with new data (useful for combining pages)
  PaginationEntity<T> copyWith({
    List<T>? data,
    int? page,
    int? perPage,
    int? total,
    int? totalPages,
  }) {
    return PaginationEntity<T>(
      data: data ?? this.data,
      page: page ?? this.page,
      perPage: perPage ?? this.perPage,
      total: total ?? this.total,
      totalPages: totalPages ?? this.totalPages,
    );
  }

  /// Combine with another pagination entity (for infinite scroll)
  PaginationEntity<T> combineWith(PaginationEntity<T> other) {
    return PaginationEntity<T>(
      data: [...data, ...other.data],
      page: other.page,
      perPage: perPage,
      total: other.total,
      totalPages: other.totalPages,
    );
  }

  @override
  List<Object?> get props => [data, page, perPage, total, totalPages];

  @override
  String toString() {
    return 'PaginationEntity(data: ${data.length} items, page: $page/$totalPages, perPage: $perPage, total: $total)';
  }
}