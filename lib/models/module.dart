class AppModule {
  final int id;
  final String nombre;

  AppModule({required this.id, required this.nombre});

  factory AppModule.fromJson(Map<String, dynamic> json) {
    return AppModule(
      id: json['id_modulo'] ?? 0,
      nombre: json['nombre'] ?? '',
    );
  }
}
