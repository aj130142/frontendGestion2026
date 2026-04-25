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
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;
  
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
    _startDateController = TextEditingController(text: widget.task?.startDate ?? DateTime.now().toString().split(' ')[0]);
    _endDateController = TextEditingController(text: widget.task?.endDate ?? '');
    
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
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller, {DateTime? firstDate, DateTime? lastDate}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(controller.text) ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(2000),
      lastDate: lastDate ?? DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        controller.text = picked.toString().split(' ')[0];
      });
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedProjectId == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor, selecciona un Proyecto')));
        return;
      }

      // Project range validation
      final projects = context.read<ProjectProvider>().projects;
      final project = projects.firstWhere((p) => p.id == _selectedProjectId);
      
      final taskStart = DateTime.parse(_startDateController.text);
      final projectStart = DateTime.parse(project.startDate);
      
      if (taskStart.isBefore(projectStart)) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('La fecha de inicio no puede ser anterior a la del proyecto (${project.startDate})')));
        return;
      }

      if (project.endDate.isNotEmpty) {
        final projectEnd = DateTime.parse(project.endDate);
        if (taskStart.isAfter(projectEnd)) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('La fecha de inicio no puede ser posterior a la del proyecto (${project.endDate})')));
           return;
        }
        if (_endDateController.text.isNotEmpty) {
           final taskEnd = DateTime.parse(_endDateController.text);
           if (taskEnd.isAfter(projectEnd)) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('La fecha de fin no puede ser posterior a la del proyecto (${project.endDate})')));
              return;
           }
        }
      }

      if (_endDateController.text.isNotEmpty) {
        final taskEnd = DateTime.parse(_endDateController.text);
        if (taskEnd.isBefore(taskStart)) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('La fecha de fin no puede ser anterior a la de inicio')));
          return;
        }
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
          startDate: _startDateController.text,
          endDate: _endDateController.text.isEmpty ? null : _endDateController.text,
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
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al guardar la tarea (Verifica las fechas con el proyecto)')));
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
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _startDateController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Fecha Inicio',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today, color: Colors.teal),
                      ),
                      onTap: () => _selectDate(context, _startDateController),
                      validator: (v) => v!.isEmpty ? 'Requerido' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _endDateController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Fecha Fin (Opcional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_month, color: Colors.teal),
                      ),
                      onTap: () => _selectDate(context, _endDateController),
                    ),
                  ),
                ],
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
