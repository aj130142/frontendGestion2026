class HistoryEntry {
  final int id;
  final String entity;
  final int entityId;
  final String? entityName;
  final String? description;
  final String? oldStatus;
  final String newStatus;
  final int userId;
  final String userName;
  final String changedAt;

  HistoryEntry({
    required this.id,
    required this.entity,
    required this.entityId,
    this.entityName,
    this.description,
    this.oldStatus,
    required this.newStatus,
    required this.userId,
    required this.userName,
    required this.changedAt,
  });

  factory HistoryEntry.fromJson(Map<String, dynamic> json) {
    return HistoryEntry(
      id: json['id_historial'],
      entity: json['entidad'] ?? '',
      entityId: json['id_entidad'] ?? 0,
      entityName: json['nombre_entidad'],
      description: json['descripcion'],
      oldStatus: json['estado_ant'] != null ? json['estado_ant']['nombre'] : null,
      newStatus: json['estado_nuevo'] != null ? json['estado_nuevo']['nombre'] : 'Desconocido',
      userId: json['id_usuario'] ?? 0,
      userName: json['usuario'] != null ? json['usuario']['nombre'] : 'Usuario',
      changedAt: json['cambiado_en'] ?? '',
    );
  }
}
