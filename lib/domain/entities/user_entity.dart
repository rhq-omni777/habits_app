// Entidad de dominio que representa a un usuario.

// Representa a un usuario de la app.
class UserEntity {
  final String id;
  final String email;
  final String displayName;

  const UserEntity({required this.id, required this.email, required this.displayName});
}
