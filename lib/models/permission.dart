/// Representa los permisos de un rol sobre un módulo específico.
class Permission {
  final bool ver;
  final bool crear;
  final bool editar;
  final bool eliminar;

  const Permission({
    this.ver = false,
    this.crear = false,
    this.editar = false,
    this.eliminar = false,
  });

  factory Permission.fromJson(Map<String, dynamic> json) {
    return Permission(
      ver:      json['ver']      as bool? ?? false,
      crear:    json['crear']    as bool? ?? false,
      editar:   json['editar']   as bool? ?? false,
      eliminar: json['eliminar'] as bool? ?? false,
    );
  }

  /// Permiso nulo: sin acceso a nada (valor por defecto seguro).
  static const Permission none = Permission();
}

/// Mapa de permisos indexado por nombre de módulo.
/// Ej: permisos['clientes']?.editar ?? false
typedef PermissionMap = Map<String, Permission>;
