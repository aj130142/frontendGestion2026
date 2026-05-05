import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../models/task.dart';
import '../../services/task_service.dart';
import '../../widgets/app_drawer.dart';

class TaskListScreen extends StatefulWidget {
  final int? projectId;
  final String? projectName;

  const TaskListScreen({super.key, this.projectId, this.projectName});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  late Future<List<AppTask>> _tasksFuture;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      if (widget.projectId != null) {
        _tasksFuture = TaskService.getTasks().then((tasks) => 
          tasks.where((t) => t.projectId == widget.projectId).toList());
      } else {
        _tasksFuture = TaskService.getTasks();
      }
    });
  }

  Future<void> _deleteTask(int id) async {
    try {
      await TaskService.deleteTask(id);
      _refresh();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tarea eliminada exitosamente')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final canCrear    = auth.puedeCrear('tareas');
    final canEditar   = auth.puedeEditar('tareas');
    final canEliminar = auth.puedeEliminar('tareas');

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Text(
          widget.projectName != null ? 'Tareas: ${widget.projectName}' : 'Todas las Tareas',
          style: const TextStyle(fontWeight: FontWeight.bold)
        ),
        elevation: 2,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          if (widget.projectId != null)
            TextButton.icon(
              onPressed: () => context.go('/projects'),
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
              label: const Text('Proyectos', style: TextStyle(color: Colors.white)),
            ),
          if (canCrear)
            IconButton(
              icon: const Icon(Icons.playlist_add),
              onPressed: () async {
                await context.push('/tasks/new', extra: widget.projectId);
                _refresh();
              },
            )
        ],
      ),
      body: FutureBuilder<List<AppTask>>(
        future: _tasksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay tareas registradas'));
          }

          final tasks = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.teal.withOpacity(0.1),
                            foregroundColor: Colors.teal,
                            child: const Icon(Icons.assignment),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  task.title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(task.status).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: _getStatusColor(task.status).withOpacity(0.5)),
                                      ),
                                      child: Text(
                                        task.status,
                                        style: TextStyle(
                                          color: _getStatusColor(task.status),
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: _getPriorityColor(task.priority).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        task.priority,
                                        style: TextStyle(
                                          color: _getPriorityColor(task.priority),
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          PopupMenuButton<String>(
                            onSelected: (value) async {
                              if (value == 'edit') {
                                await context.push('/tasks/edit', extra: task);
                                _refresh();
                              } else if (value == 'delete') {
                                if (task.id != null) _deleteTask(task.id!);
                              }
                            },
                            itemBuilder: (context) => [
                              if (canEditar)
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: ListTile(
                                    leading: Icon(Icons.edit, color: Colors.blue),
                                    title: Text('Editar'),
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              if (canEliminar)
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: ListTile(
                                    leading: Icon(Icons.delete, color: Colors.redAccent),
                                    title: Text('Eliminar'),
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (task.description.isNotEmpty) ...[
                        Text(
                          task.description,
                          style: TextStyle(color: Colors.grey[800], height: 1.4),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 16),
                      ],
                      const Divider(),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Responsable: ${task.responsible}',
                              style: const TextStyle(fontSize: 13, color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            '${task.startDate} — ${task.endDate ?? 'Pendiente'}',
                            style: const TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completada':
      case 'finalizada':
        return Colors.green;
      case 'en progreso':
        return Colors.blue;
      case 'cancelada':
        return Colors.red;
      case 'pendiente':
      default:
        return Colors.orange;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'alta':
        return Colors.red;
      case 'media':
        return Colors.orange;
      case 'baja':
      default:
        return Colors.blue;
    }
  }
}
