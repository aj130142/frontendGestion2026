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
    final canDelete = context.watch<AuthProvider>().canDelete;

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Proyectos', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 2,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
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
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: Colors.deepPurple.withOpacity(0.2),
                    foregroundColor: Colors.deepPurple,
                    child: const Icon(Icons.work),
                  ),
                  title: Text(project.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Estado: ${project.status}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Ver Tareas',
                          icon: const Icon(Icons.list_alt, color: Colors.teal),
                          onPressed: () {
                            context.push('/tasks?projectId=${project.id}&projectName=${Uri.encodeComponent(project.name)}');
                          },
                        ),
                        IconButton(
                          tooltip: 'Agregar Tarea',
                          icon: const Icon(Icons.playlist_add, color: Colors.green),
                          onPressed: () async {
                            await context.push('/tasks/new', extra: project.id);
                            _refresh();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () async {
                            await context.push('/projects/edit', extra: project);
                            _refresh();
                          },
                        ),
                        if (canDelete)
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.redAccent),
                            onPressed: () => project.id != null ? _deleteProject(project.id!) : null,
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
}
