// Modelo que representa un usuario para persistir su información.

import '../../domain/entities/user_entity.dart';

// Modelo para guardar y leer usuarios desde Firestore.
class UserModel extends UserEntity {
  const UserModel({required super.id, required super.email, required super.displayName});

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
        id: map['id'] as String,
        email: map['email'] as String,
        displayName: map['displayName'] as String,
      );

  // Ejecuta la lógica relacionada con to map.
  Map<String, dynamic> toMap() => {
        'id': id,
        'email': email,
        'displayName': displayName,
      };
}
