import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:task_manager_app/src/features/user/domain/entities/user.dart';


part 'user_model.freezed.dart';
part 'user_model.g.dart';

/// User model returned by the server
@freezed
abstract class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String email,
    required String name,
    String? picture,
    String? googleId,
    String? createdAt,
    String? updatedAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
}

/// Extension to convert UserModel to domain entity
extension UserModelX on UserModel {
  User toEntity() {
    return User(
      id: id,
      email: email,
      name: name,
      picture: picture,
      googleId: googleId,
      createdAt: createdAt != null ? DateTime.tryParse(createdAt!) : null,
      updatedAt: updatedAt != null ? DateTime.tryParse(updatedAt!) : null,
    );
  }
}
