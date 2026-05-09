class Project {
  final int? id;
  final int clientId;
  final String name;
  final String description;
  final String startDate;
  final String endDate;
  final String status; 

  final String clientName;
  final String clientCompany;

  Project({this.id, required this.clientId, required this.name, required this.description, required this.startDate, required this.endDate, required this.status, this.clientName = '', this.clientCompany = ''});

  factory Project.fromJson(Map<String, dynamic> json) {
    String stName = 'Pendiente';
    if (json['estado'] != null) stName = json['estado']['nombre'] ?? 'Pendiente';
    
    String cName = 'Desconocido';
    String cComp = 'N/A';
    if (json['cliente'] != null) {
      cName = json['cliente']['nombre'] ?? 'Desconocido';
      cComp = json['cliente']['empresa'] ?? 'N/A';
    }

    return Project(
      id: json['id_proyecto'],
      clientId: json['id_cliente'],
      name: json['nombre'] ?? '',
      description: json['descripcion'] ?? '',
      startDate: json['fecha_inicio'] ?? '',
      endDate: json['fecha_fin'] ?? '',
      status: stName,
      clientName: cName,
      clientCompany: cComp,
    );
  }

  Map<String, dynamic> toJson() {
    int stId = 6; // Pendiente
    if (status == 'En progreso' || status == 'En Progreso') stId = 3;
    if (status == 'Completado' || status == 'Finalizado') stId = 4;
    if (status == 'Cancelado') stId = 5;
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
