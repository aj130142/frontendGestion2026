import 'module.dart';

class RolePermission {
  final int idRol;
  final int idModulo;
  bool puedeVer;
  bool puedeCrear;
  bool puedeEditar;
  bool puedeEliminar;
  final AppModule? modulo;

  RolePermission({
    required this.idRol,
    required this.idModulo,
    this.puedeVer = false,
    this.puedeCrear = false,
    this.puedeEditar = false,
    this.puedeEliminar = false,
    this.modulo,
  });

  factory RolePermission.fromJson(Map<String, dynamic> json) {
    return RolePermission(
      idRol: json['id_rol'] ?? 0,
      idModulo: json['id_modulo'] ?? 0,
      puedeVer: json['puede_ver'] ?? false,
      puedeCrear: json['puede_crear'] ?? false,
      puedeEditar: json['puede_editar'] ?? false,
      puedeEliminar: json['puede_eliminar'] ?? false,
      modulo: json['modulo'] != null ? AppModule.fromJson(json['modulo']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_rol': idRol,
      'id_modulo': idModulo,
      'puede_ver': puedeVer,
      'puede_crear': puedeCrear,
      'puede_editar': puedeEditar,
      'puede_eliminar': puedeEliminar,
    };
  }
}
