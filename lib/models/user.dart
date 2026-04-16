class User {
  final int id;
  final String name;
  final String email;
  final int roleId;
  final bool activo;

  User({required this.id, required this.name, required this.email, required this.roleId, required this.activo});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id_usuario'] ?? 0,
      name: json['nombre'] ?? '',
      email: json['correo'] ?? '',
      roleId: json['id_rol'] ?? 2,
      activo: json['activo'] ?? true,
    );
  }
}
