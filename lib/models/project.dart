class Project {
  final int? id;
  final int clientId;
  final String name;
  final String description;
  final String startDate;
  final String endDate;
  final String status; 

  Project({this.id, required this.clientId, required this.name, required this.description, required this.startDate, required this.endDate, required this.status});

  factory Project.fromJson(Map<String, dynamic> json) {
    String stName = 'Pendiente';
    if (json['estado'] != null) stName = json['estado']['nombre'] ?? 'Pendiente';
    return Project(
      id: json['id_proyecto'],
      clientId: json['id_cliente'],
      name: json['nombre'] ?? '',
      description: json['descripcion'] ?? '',
      startDate: json['fecha_inicio'] ?? '',
      endDate: json['fecha_fin'] ?? '',
      status: stName,
    );
  }

  Map<String, dynamic> toJson() {
    int stId = 6; 
    if (status == 'En progreso' || status == 'En Progreso') stId = 3;
    if (status == 'Completado' || status == 'Finalizado') stId = 4;
    return {
      if (id != null) 'id_proyecto': id,
      'id_cliente': clientId,
      'nombre': name,
      'descripcion': description,
      if (startDate.isNotEmpty) 'fecha_inicio': startDate,
      if (endDate.isNotEmpty) 'fecha_fin': endDate,
      'id_estado': stId,
    };
  }
}
