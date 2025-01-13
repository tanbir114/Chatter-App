import 'package:chatter/features/auth/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel(
      {required super.id,
      required super.username,
      required super.email,
      required super.token});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    print("TTTTTTTTTTTTToken: " + json['token']);
    return UserModel(
      id: json['_id'],
      username: json['username'],
      email: json['email'],
      token: json['token'],
    );
  }
}
