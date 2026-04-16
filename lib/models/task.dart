class AppTask {
  final int? id;
  final int projectId;
  final String title;
  final String description;
  final String responsible;
  final String priority;
  final String status;
  final int? assignedUserId;

  AppTask({
    this.id,
    required this.projectId,
    required this.title,
    required this.description,
    required this.responsible,
    required this.priority,
    required this.status,
    this.assignedUserId,
  });

  factory AppTask.fromJson(Map<String, dynamic> json) {
    String stName = 'Pendiente';
    if (json['estado'] != null) stName = json['estado']['nombre'] ?? 'Pendiente';
    String prName = 'Media';
    if (json['prioridad'] != null) prName = json['prioridad']['nombre'] ?? 'Media';

    return AppTask(
      id: json['id_tarea'],
      projectId: json['id_proyecto'],
      title: json['nombre'] ?? '',
      description: json['descripcion'] ?? '',
      responsible: 'Usuario', 
      priority: prName,
      status: stName,
      // Nota: El backend retorna una lista de usuarios. Tomamos el primero si existe.
    );
  }

  Map<String, dynamic> toJson() {
    int stId = 18; // Pendiente
    if (status == 'En Progreso' || status == 'En progreso') stId = 19;
    if (status == 'Completada') stId = 20;
    if (status == 'Cancelada') stId = 21;

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
    };
  }
}
