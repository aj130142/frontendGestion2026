import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/history_entry.dart';
import '../../services/history_service.dart';

class GeneralHistoryScreen extends StatefulWidget {
  const GeneralHistoryScreen({super.key});

  @override
  State<GeneralHistoryScreen> createState() => _GeneralHistoryScreenState();
}

class _GeneralHistoryScreenState extends State<GeneralHistoryScreen> {
  List<HistoryEntry> _allHistory = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final history = await HistoryService.getAllHistory(entity: 'tarea');
      setState(() {
        _allHistory = history;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Actividad Reciente', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.teal.withOpacity(0.05), Colors.white],
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text('Error: $_error'))
                : _allHistory.isEmpty
                    ? const Center(child: Text('No hay actividad reciente registrada', style: TextStyle(color: Colors.grey, fontSize: 16)))
                    : RefreshIndicator(
                        onRefresh: _loadHistory,
                        color: Colors.teal,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                          itemCount: _allHistory.length,
                          itemBuilder: (context, index) {
                            final entry = _allHistory[index];
                            final date = DateTime.parse(entry.changedAt);
                            final formattedDate = DateFormat('dd MMM, HH:mm').format(date);

                            return Container(
                              margin: const EdgeInsets.only(bottom: 20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: IntrinsicHeight(
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 6,
                                        color: _getStatusColor(entry.newStatus),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      entry.entityName ?? 'Tarea #${entry.entityId}',
                                                      style: const TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 16,
                                                        color: Color(0xFF2D3436),
                                                      ),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  Text(
                                                    formattedDate,
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      color: Colors.grey[500],
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              if (entry.description != null && entry.description!.isNotEmpty) ...[
                                                Text(
                                                  entry.description!,
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 13,
                                                    fontStyle: FontStyle.italic,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 12),
                                              ],
                                              Row(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: Colors.teal.withOpacity(0.05),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        const Icon(Icons.person, size: 12, color: Colors.teal),
                                                        const SizedBox(width: 4),
                                                        Text(
                                                          entry.userName,
                                                          style: const TextStyle(fontSize: 11, color: Colors.teal, fontWeight: FontWeight.bold),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const Spacer(),
                                                  _buildStatusTransition(entry),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
      ),
    );
  }

  Widget _buildStatusTransition(HistoryEntry entry) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (entry.oldStatus != null) ...[
          _statusChip(entry.oldStatus!, isOld: true),
          const Icon(Icons.arrow_forward_rounded, size: 14, color: Colors.grey),
        ],
        _statusChip(entry.newStatus),
      ],
    );
  }

  Widget _statusChip(String status, {bool isOld = false}) {
    final color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: isOld ? Colors.grey[100] : color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isOld ? Colors.grey[300]! : color.withOpacity(0.3)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: isOld ? Colors.grey[600] : color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
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
