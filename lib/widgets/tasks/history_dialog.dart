import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/history_entry.dart';
import '../../services/history_service.dart';

class HistoryDialog extends StatefulWidget {
  final String entity;
  final int entityId;
  final String title;

  const HistoryDialog({
    super.key,
    required this.entity,
    required this.entityId,
    required this.title,
  });

  @override
  State<HistoryDialog> createState() => _HistoryDialogState();
}

class _HistoryDialogState extends State<HistoryDialog> {
  late Future<List<HistoryEntry>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = HistoryService.getEntityHistory(widget.entity, widget.entityId);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      titlePadding: EdgeInsets.zero,
      title: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.teal,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Historial de Estados',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 4),
            Text(
              widget.title,
              style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w400),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
      content: SizedBox(
        width: 400,
        height: 450,
        child: FutureBuilder<List<HistoryEntry>>(
          future: _historyFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.teal));
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
            }
            final history = snapshot.data ?? [];
            if (history.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history, size: 48, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text('Sin cambios registrados', style: TextStyle(color: Colors.grey[400])),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.only(top: 16),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final entry = history[index];
                final date = DateTime.parse(entry.changedAt);
                final formattedDate = DateFormat('dd MMM, yyyy · HH:mm').format(date);

                return IntrinsicHeight(
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: _getStatusColor(entry.newStatus),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: _getStatusColor(entry.newStatus).withOpacity(0.3),
                                    blurRadius: 4,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                            if (index != history.length - 1)
                              Expanded(
                                child: Container(
                                  width: 2,
                                  color: Colors.grey[200],
                                ),
                              ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildTransitionLine(entry),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(Icons.person_outline, size: 12, color: Colors.grey[600]),
                                  const SizedBox(width: 4),
                                  Text(
                                    entry.userName,
                                    style: TextStyle(fontSize: 12, color: Colors.grey[700], fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(width: 12),
                                  Icon(Icons.access_time, size: 12, color: Colors.grey[600]),
                                  const SizedBox(width: 4),
                                  Text(
                                    formattedDate,
                                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(foregroundColor: Colors.grey[600]),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }

  Widget _buildTransitionLine(HistoryEntry entry) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (entry.oldStatus != null) ...[
          Text(entry.oldStatus!, style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500)),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 6),
            child: Icon(Icons.arrow_forward, size: 12, color: Colors.grey),
          ),
        ],
        Text(
          entry.newStatus,
          style: TextStyle(fontSize: 14, color: _getStatusColor(entry.newStatus), fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completada':
      case 'finalizada':
      case 'activo':
        return Colors.green;
      case 'en progreso':
        return Colors.blue;
      case 'cancelada':
      case 'cancelado':
      case 'inactivo':
        return Colors.red;
      case 'pendiente':
      default:
        return Colors.orange;
    }
  }
}
