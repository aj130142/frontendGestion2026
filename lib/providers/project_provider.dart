import 'package:flutter/material.dart';
import '../models/project.dart';
import '../services/project_service.dart';

class ProjectProvider extends ChangeNotifier {
  List<Project> _projects = [];
  bool _isLoading = false;

  List<Project> get projects => _projects;
  bool get isLoading => _isLoading;

  Future<void> fetchProjects() async {
    _isLoading = true;
    notifyListeners();
    try {
      _projects = await ProjectService.getProjects();
    } catch (e) {
      debugPrint("Error loading projects: $e");
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createProject(Project project) async {
    try {
      final newProject = await ProjectService.createProject(project);
      _projects.add(newProject);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Error creating project: $e");
      return false;
    }
  }

  Future<bool> updateProject(int id, Project project) async {
    try {
      final updatedProject = await ProjectService.updateProject(id, project);
      final index = _projects.indexWhere((p) => p.id == id);
      if (index != -1) {
        _projects[index] = updatedProject;
        notifyListeners();
      }
      return true;
    } catch (e) {
      debugPrint("Error updating project: $e");
      return false;
    }
  }

  Future<bool> deleteProject(int id) async {
    try {
      await ProjectService.deleteProject(id);
      _projects.removeWhere((p) => p.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Error deleting project: $e");
      return false;
    }
  }
}
