import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({required super.id, required super.email, required super.displayName});

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
        id: map['id'] as String,
        email: map['email'] as String,
        displayName: map['displayName'] as String,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'email': email,
        'displayName': displayName,
      };
}
