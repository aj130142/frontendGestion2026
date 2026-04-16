import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/task_service.dart';

class TaskProvider extends ChangeNotifier {
  List<AppTask> _tasks = [];
  bool _isLoading = false;

  List<AppTask> get tasks => _tasks;
  bool get isLoading => _isLoading;

  Future<void> fetchTasks() async {
    _isLoading = true;
    notifyListeners();
    try {
      _tasks = await TaskService.getTasks();
    } catch (e) {
      debugPrint("Error loading tasks: $e");
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createTask(AppTask task) async {
    try {
      final newTask = await TaskService.createTask(task);
      _tasks.add(newTask);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Error creating task: $e");
      return false;
    }
  }

  Future<bool> updateTask(int id, AppTask t) async {
    try {
      await TaskService.updateTask(id, t);
      if (t.assignedUserId != null) {
        await TaskService.assignUser(id, t.assignedUserId!);
      }
      await fetchTasks();
      return true;
    } catch (e) {
      debugPrint("Error updating task: $e");
      return false;
    }
  }

  Future<bool> deleteTask(int id) async {
    try {
      await TaskService.deleteTask(id);
      _tasks.removeWhere((t) => t.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Error deleting task: $e");
      return false;
    }
  }
}
