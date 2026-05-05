import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../models/project.dart';
import '../../services/project_service.dart';
import '../../widgets/app_drawer.dart';

class ProjectListScreen extends StatefulWidget {
  const ProjectListScreen({super.key});

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  late Future<List<Project>> _projectsFuture;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _projectsFuture = ProjectService.getProjects();
    });
  }

  Future<void> _deleteProject(int id) async {
    try {
      await ProjectService.deleteProject(id);
      _refresh();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Proyecto eliminado exitosamente')),
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
    final canCrearProyecto  = auth.puedeCrear('proyectos');
    final canEditar         = auth.puedeEditar('proyectos');
    final canEliminar       = auth.puedeEliminar('proyectos');
    final canCrearTarea     = auth.puedeCrear('tareas');

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Proyectos', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 2,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          if (canCrearProyecto)
            IconButton(
              icon: const Icon(Icons.add_task),
              onPressed: () async {
                await context.push('/projects/new');
                _refresh();
              },
            )
        ],
      ),
      body: FutureBuilder<List<Project>>(
        future: _projectsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay proyectos registrados'));
          }

          final projects = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: projects.length,
            itemBuilder: (context, index) {
              final project = projects[index];
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
                            backgroundColor: Colors.deepPurple.withOpacity(0.1),
                            foregroundColor: Colors.deepPurple,
                            child: const Icon(Icons.work),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  project.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(project.status).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: _getStatusColor(project.status).withOpacity(0.5)),
                                  ),
                                  child: Text(
                                    project.status,
                                    style: TextStyle(
                                      color: _getStatusColor(project.status),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuButton<String>(
                            onSelected: (value) async {
                              if (value == 'tasks') {
                                context.push('/tasks?projectId=${project.id}&projectName=${Uri.encodeComponent(project.name)}');
                              } else if (value == 'add_task') {
                                await context.push('/tasks/new', extra: project.id);
                                _refresh();
                              } else if (value == 'edit') {
                                await context.push('/projects/edit', extra: project);
                                _refresh();
                              } else if (value == 'delete') {
                                if (project.id != null) _deleteProject(project.id!);
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'tasks',
                                child: ListTile(
                                  leading: Icon(Icons.list_alt, color: Colors.teal),
                                  title: Text('Ver Tareas'),
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                              if (canCrearTarea)
                                const PopupMenuItem(
                                  value: 'add_task',
                                  child: ListTile(
                                    leading: Icon(Icons.playlist_add, color: Colors.green),
                                    title: Text('Agregar Tarea'),
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
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
                      if (project.description.isNotEmpty) ...[
                        Text(
                          project.description,
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
                              '${project.clientName} (${project.clientCompany})',
                              style: const TextStyle(fontSize: 13, color: Colors.grey),
                              overflow: TextOverflow.ellipsis,
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
                            '${project.startDate} — ${project.endDate.isNotEmpty ? project.endDate : 'En curso'}',
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
      case 'completado':
      case 'finalizado':
        return Colors.green;
      case 'en progreso':
      case 'activo':
        return Colors.blue;
      case 'cancelado':
        return Colors.red;
      case 'pendiente':
      default:
        return Colors.orange;
    }
  }
}
