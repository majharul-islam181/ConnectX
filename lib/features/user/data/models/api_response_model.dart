import 'package:json_annotation/json_annotation.dart';
import '../../domain/entites/pagination_entity.dart';
import '../../domain/entites/user_entity.dart';
import 'user_model.dart';

part 'api_response_model.g.dart';

/// Response model for ReqRes API user list endpoint
@JsonSerializable()
class UsersResponseModel {
  final int page;
  @JsonKey(name: 'per_page')
  final int perPage;
  final int total;
  @JsonKey(name: 'total_pages')
  final int totalPages;
  final List<UserModel> data;
  final SupportModel? support;

  const UsersResponseModel({
    required this.page,
    required this.perPage,
    required this.total,
    required this.totalPages,
    required this.data,
    this.support,
  });

  factory UsersResponseModel.fromJson(Map<String, dynamic> json) =>
      _$UsersResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$UsersResponseModelToJson(this);

  /// Convert to pagination entity
  PaginationEntity<UserEntity> toPaginationEntity() {
    return PaginationEntity<UserEntity>(
      data: data.map((model) => model.toEntity()).toList(),
      page: page,
      perPage: perPage,
      total: total,
      totalPages: totalPages,
    );
  }

  @override
  String toString() {
    return 'UsersResponseModel(page: $page, perPage: $perPage, total: $total, totalPages: $totalPages, data: ${data.length} users)';
  }
}

/// Response model for ReqRes API single user endpoint
@JsonSerializable()
class UserResponseModel {
  final UserModel data;
  final SupportModel? support;

  const UserResponseModel({
    required this.data,
    this.support,
  });

  factory UserResponseModel.fromJson(Map<String, dynamic> json) =>
      _$UserResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserResponseModelToJson(this);

  /// Convert to user entity
  UserEntity toEntity() => data.toEntity();

  @override
  String toString() {
    return 'UserResponseModel(data: $data, support: $support)';
  }
}

/// Support information from ReqRes API
@JsonSerializable()
class SupportModel {
  final String url;
  final String text;

  const SupportModel({
    required this.url,
    required this.text,
  });

  factory SupportModel.fromJson(Map<String, dynamic> json) =>
      _$SupportModelFromJson(json);

  Map<String, dynamic> toJson() => _$SupportModelToJson(this);

  @override
  String toString() {
    return 'SupportModel(url: $url, text: $text)';
  }
}

/// Generic error response model
@JsonSerializable()
class ErrorResponseModel {
  final String? error;
  final String? message;
  final List<String>? errors;

  const ErrorResponseModel({
    this.error,
    this.message,
    this.errors,
  });

  factory ErrorResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ErrorResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$ErrorResponseModelToJson(this);

  /// Get the main error message
  String get mainMessage {
    if (message != null && message!.isNotEmpty) return message!;
    if (error != null && error!.isNotEmpty) return error!;
    if (errors != null && errors!.isNotEmpty) return errors!.first;
    return 'Unknown error occurred';
  }

  @override
  String toString() {
    return 'ErrorResponseModel(error: $error, message: $message, errors: $errors)';
  }
}