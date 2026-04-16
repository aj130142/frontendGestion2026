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
    final canDelete = context.watch<AuthProvider>().canDelete;

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
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: Colors.teal.withOpacity(0.2),
                    foregroundColor: Colors.teal,
                    child: const Icon(Icons.assignment),
                  ),
                  title: Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Resp: ${task.responsible} | ${task.status}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () async {
                          await context.push('/tasks/edit', extra: task);
                          _refresh();
                        },
                      ),
                      if (canDelete)
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () => task.id != null ? _deleteTask(task.id!) : null,
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
