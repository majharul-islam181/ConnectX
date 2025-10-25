import 'package:json_annotation/json_annotation.dart';
import '../../domain/entites/pagination_entity.dart';

part 'pagination_model.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class PaginationModel<T> extends PaginationEntity<T> {
  const PaginationModel({
    required super.data,
    required super.page,
    required super.perPage,
    required super.total,
    required super.totalPages,
  });

  factory PaginationModel.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$PaginationModelFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object Function(T value) toJsonT) =>
      _$PaginationModelToJson(this, toJsonT);

  /// Convert from entity to model
  factory PaginationModel.fromEntity(PaginationEntity<T> entity) {
    return PaginationModel<T>(
      data: entity.data,
      page: entity.page,
      perPage: entity.perPage,
      total: entity.total,
      totalPages: entity.totalPages,
    );
  }

  /// Convert to entity
  PaginationEntity<T> toEntity() {
    return PaginationEntity<T>(
      data: data,
      page: page,
      perPage: perPage,
      total: total,
      totalPages: totalPages,
    );
  }

  /// Create copy with modified fields
  PaginationModel<T> copyWith({
    List<T>? data,
    int? page,
    int? perPage,
    int? total,
    int? totalPages,
  }) {
    return PaginationModel<T>(
      data: data ?? this.data,
      page: page ?? this.page,
      perPage: perPage ?? this.perPage,
      total: total ?? this.total,
      totalPages: totalPages ?? this.totalPages,
    );
  }

  @override
  String toString() {
    return 'PaginationModel(data: ${data.length} items, page: $page/$totalPages, perPage: $perPage, total: $total)';
  }
}