class AppTask {
  final int? id;
  final int projectId;
  final String title;
  final String description;
  final String responsible;
  final String priority;
  final String status;
  final int? assignedUserId;

  final String startDate;
  final String? endDate;

  AppTask({
    this.id,
    required this.projectId,
    required this.title,
    required this.description,
    required this.responsible,
    required this.priority,
    required this.status,
    this.assignedUserId,
    required this.startDate,
    this.endDate,
  });

  factory AppTask.fromJson(Map<String, dynamic> json) {
    String stName = 'Pendiente';
    if (json['estado'] != null) stName = json['estado']['nombre'] ?? 'Pendiente';
    String prName = 'Media';
    if (json['prioridad'] != null) prName = json['prioridad']['nombre'] ?? 'Media';

    int? assignedUserId;
    String respName = 'Sin asignar';
    if (json['usuarios'] != null && (json['usuarios'] as List).isNotEmpty) {
      final firstUser = json['usuarios'][0];
      if (firstUser['usuario'] != null) {
        respName = firstUser['usuario']['nombre'] ?? 'Usuario';
      }
      assignedUserId = firstUser['id_usuario'];
    }

    return AppTask(
      id: json['id_tarea'],
      projectId: json['id_proyecto'],
      title: json['nombre'] ?? '',
      description: json['descripcion'] ?? '',
      responsible: respName, 
      priority: prName,
      status: stName,
      assignedUserId: assignedUserId,
      startDate: json['fecha_inicio'] ?? '',
      endDate: json['fecha_fin'],
    );
  }

  Map<String, dynamic> toJson() {
    int stId = 7; // Pendiente
    if (status == 'En Progreso' || status == 'En progreso') stId = 8;
    if (status == 'Completada') stId = 9;
    if (status == 'Cancelada') stId = 10;

    int prId = 2; // Media
    if (priority == 'Alta') prId = 1;
    if (priority == 'Baja') prId = 3;

    return {
      if (id != null) 'id_tarea': id,
      'id_proyecto': projectId,
      'nombre': title,
      'descripcion': description,
      'id_prioridad': prId,
      'id_estado': stId,
      'fecha_inicio': startDate,
      if (endDate != null) 'fecha_fin': endDate,
    };
  }
}
