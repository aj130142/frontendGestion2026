import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../models/task.dart';
import '../../services/task_service.dart';
import '../../widgets/app_drawer.dart';
import '../../services/pdf_service.dart';

class TaskListScreen extends StatefulWidget {
  final int? projectId;
  final String? projectName;

  const TaskListScreen({super.key, this.projectId, this.projectName});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<AppTask> _allTasks = [];
  List<AppTask> _filteredTasks = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTasks() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      // Filtrado directo desde el servidor para máxima precisión
      final tasks = await TaskService.getTasks(projectId: widget.projectId);
      
      setState(() {
        _allTasks = tasks;
        _filterTasks(_searchController.text);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterTasks(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredTasks = _allTasks;
      } else {
        final lowercaseQuery = query.toLowerCase();
        _filteredTasks = _allTasks.where((task) {
          return task.title.toLowerCase().contains(lowercaseQuery) ||
                 task.description.toLowerCase().contains(lowercaseQuery) ||
                 task.responsible.toLowerCase().contains(lowercaseQuery) ||
                 task.status.toLowerCase().contains(lowercaseQuery) ||
                 task.priority.toLowerCase().contains(lowercaseQuery);
        }).toList();
      }
    });
  }

  Future<void> _deleteTask(int id) async {
    try {
      await TaskService.deleteTask(id);
      _loadTasks();
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
          IconButton(
            icon: const Icon(Icons.print, color: Colors.white),
            tooltip: 'Imprimir Resumen PDF',
            onPressed: () async {
              try {
                if (_filteredTasks.isNotEmpty) {
                  await PdfService.generateTasksSummaryPdf(widget.projectName ?? 'General', _filteredTasks);
                } else {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No hay tareas para imprimir')),
                  );
                }
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error al generar PDF: $e')),
                );
              }
            },
          ),
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
                _loadTasks();
              },
            )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterTasks,
              decoration: InputDecoration(
                hintText: 'Buscar tareas...',
                prefixIcon: const Icon(Icons.search, color: Colors.teal),
                suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _filterTasks('');
                      },
                    )
                  : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.teal),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.teal, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                ? Center(child: Text('Error: $_error'))
                : _filteredTasks.isEmpty
                  ? const Center(child: Text('No se encontraron tareas'))
                  : RefreshIndicator(
                      onRefresh: _loadTasks,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: _filteredTasks.length,
                        itemBuilder: (context, index) {
                          final task = _filteredTasks[index];
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
                                      if (canEditar || canEliminar)
                                        PopupMenuButton<String>(
                                          onSelected: (value) async {
                                            if (value == 'edit') {
                                              await context.push('/tasks/edit', extra: task);
                                              _loadTasks();
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
                      ),
                    ),
          ),
        ],
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
