import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/task.dart';
import '../../providers/project_provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/user_provider.dart';

class TaskFormScreen extends StatefulWidget {
  final AppTask? task;
  final int? projectId;

  const TaskFormScreen({super.key, this.task, this.projectId});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  
  int? _selectedProjectId;
  int? _selectedUserId;
  String _priority = 'Media';
  String _status = 'Pendiente';
  bool _isLoading = false;

  final _priorities = ['Alta', 'Media', 'Baja'];
  final _statuses = ['Pendiente', 'En Progreso', 'Completada'];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descController = TextEditingController(text: widget.task?.description ?? '');
    
    if (widget.task != null) {
      _selectedProjectId = widget.task!.projectId;
      _selectedUserId = widget.task!.assignedUserId;
      _priority = widget.task!.priority;
      _status = widget.task!.status;
      
      if (!_priorities.contains(_priority)) _priority = 'Media';
      if (!_statuses.contains(_status)) _status = 'Pendiente';
    } else if (widget.projectId != null) {
      _selectedProjectId = widget.projectId;
    }
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProjectProvider>().fetchProjects();
      context.read<UserProvider>().fetchUsers();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedProjectId == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor, selecciona un Proyecto')));
        return;
      }

      setState(() => _isLoading = true);
      try {
        final taskData = AppTask(
          id: widget.task?.id,
          projectId: _selectedProjectId!,
          assignedUserId: _selectedUserId,
          title: _titleController.text,
          description: _descController.text,
          responsible: 'Usuario', 
          priority: _priority,
          status: _status,
        );

        bool success;
        final provider = context.read<TaskProvider>();
        if (widget.task == null) {
          success = await provider.createTask(taskData);
        } else {
          success = await provider.updateTask(widget.task!.id!, taskData);
        }

        if (!mounted) return;
        if (success) {
          context.pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al guardar la tarea')));
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final projects = context.watch<ProjectProvider>().projects;
    final users = context.watch<UserProvider>().users;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'Nueva Tarea' : 'Editar Tarea', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<int>(
                value: _selectedProjectId,
                decoration: const InputDecoration(
                  labelText: 'Proyecto Asociado',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.work, color: Colors.teal),
                ),
                items: projects.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))).toList(),
                onChanged: (val) => setState(() => _selectedProjectId = val),
                validator: (v) => v == null ? 'Selecciona un proyecto' : null,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<int>(
                value: _selectedUserId,
                decoration: const InputDecoration(
                  labelText: 'Responsable (Asignar a Usuario)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person, color: Colors.teal),
                ),
                items: users.map((u) => DropdownMenuItem(value: u.id, child: Text(u.name))).toList(),
                onChanged: (val) => setState(() => _selectedUserId = val),
                hint: const Text('Opcional: Seleccionar responsable'),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Título de la Tarea',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title, color: Colors.teal),
                ),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: 'Descripción Corta',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description, color: Colors.teal),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _priority,
                      items: _priorities.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _priority = val);
                      },
                      decoration: const InputDecoration(
                        labelText: 'Prioridad',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.warning_amber, color: Colors.teal),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _status,
                      items: _statuses.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _status = val);
                      },
                      decoration: const InputDecoration(
                        labelText: 'Estado',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.flag, color: Colors.teal),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : const Text('Guardar Tarea', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
