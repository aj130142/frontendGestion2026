import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_drawer.dart';
import '../../models/project.dart';
import '../../models/dashboard_stats.dart';
import '../../services/project_service.dart';
import '../../services/dashboard_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Project> _projects = [];
  Project? _selectedProject;
  List<StatusCount> _stats = [];
  bool _isLoadingProjects = true;
  bool _isLoadingStats = false;
  String? _statsError;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    setState(() => _isLoadingProjects = true);
    try {
      final projects = await ProjectService.getProjects();
      setState(() {
        _projects = projects;
        if (_projects.isNotEmpty) {
          _selectedProject = _projects.first;
          _loadStats(_selectedProject!.id!);
        }
        _isLoadingProjects = false;
      });
    } catch (e) {
      setState(() => _isLoadingProjects = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar proyectos: $e')),
        );
      }
    }
  }

  Future<void> _loadStats(int projectId) async {
    setState(() {
      _isLoadingStats = true;
      _statsError = null;
    });
    try {
      final stats = await DashboardService.getProjectTaskStats(projectId);
      setState(() {
        _stats = stats;
        _isLoadingStats = false;
      });
    } catch (e) {
      setState(() {
        _stats = [];
        _isLoadingStats = false;
        _statsError = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TechSolutions S.A.',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                    ),
                    if (user != null)
                      Text(
                        'Bienvenido, ${user.name}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                      ),
                  ],
                ),
                // Logo o avatar opcional
                const CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.blueAccent,
                  child: Icon(Icons.business, color: Colors.white, size: 30),
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            // --- Sección de Gráfica ---
            Text(
              'Estado de Tareas por Proyecto',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    if (_isLoadingProjects)
                      const Center(child: CircularProgressIndicator())
                    else if (_projects.isEmpty)
                      const Center(child: Text('No hay proyectos disponibles'))
                    else
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<Project>(
                            value: _selectedProject,
                            decoration: InputDecoration(
                              labelText: 'Seleccionar Proyecto',
                              prefixIcon: const Icon(Icons.folder_open, color: Colors.blueAccent),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            items: _projects.map((p) {
                              return DropdownMenuItem(
                                value: p,
                                child: Text(p.name, overflow: TextOverflow.ellipsis),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _selectedProject = val);
                                _loadStats(val.id!);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () {
                            if (_selectedProject != null) _loadStats(_selectedProject!.id!);
                          },
                          icon: const Icon(Icons.refresh, color: Colors.blueAccent),
                          tooltip: 'Refrescar estadísticas',
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    if (!_isLoadingProjects && _projects.isNotEmpty) ...[
                      Builder(
                        builder: (context) {
                          final total = _stats.fold<int>(0, (sum, item) => sum + item.count);
                          final completed = _stats
                              .where((s) => s.status.toLowerCase().contains('completada') || s.status.toLowerCase().contains('finalizada'))
                              .fold<int>(0, (sum, item) => sum + item.count);
                          final double progress = total > 0 ? (completed / total) : 0;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Resumen de Progreso
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Progreso General: ${(progress * 100).toStringAsFixed(0)}%',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  Text(
                                    '$completed / $total tareas completadas',
                                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  minHeight: 12,
                                  backgroundColor: Colors.grey[200],
                                  valueColor: AlwaysStoppedAnimation<Color>(progress == 1.0 ? Colors.green : Colors.blueAccent),
                                ),
                              ),
                              const SizedBox(height: 32),
                              _isLoadingStats
                                  ? const SizedBox(height: 250, child: Center(child: CircularProgressIndicator()))
                                  : _statsError != null
                                      ? Container(
                                          height: 250,
                                          width: double.infinity,
                                          alignment: Alignment.center,
                                          child: Text(
                                            'Error: $_statsError',
                                            style: const TextStyle(color: Colors.redAccent),
                                            textAlign: TextAlign.center,
                                          ),
                                        )
                                      : _stats.isEmpty
                                          ? Container(
                                              height: 250,
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                color: Colors.grey[50],
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(color: Colors.grey[200]!),
                                              ),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.assignment_late_outlined, size: 48, color: Colors.grey[300]),
                                                  const SizedBox(height: 16),
                                                  const Text(
                                                    'Este proyecto no tiene tareas asignadas aún.',
                                                    style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : Column(
                                          children: [
                                            SizedBox(
                                              height: 250,
                                              child: Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  PieChart(
                                                    PieChartData(
                                                      sections: _stats.map((s) {
                                                        final double percentage = total > 0 ? (s.count / total * 100) : 0;
                                                        return PieChartSectionData(
                                                          value: s.count.toDouble(),
                                                          title: total > 0 ? '${percentage.toStringAsFixed(0)}%' : '0%',
                                                          radius: 60,
                                                          color: _getStatusColor(s.status),
                                                          titleStyle: const TextStyle(
                                                            fontSize: 16,
                                                            color: Colors.white,
                                                            fontWeight: FontWeight.bold,
                                                            shadows: [Shadow(color: Colors.black45, blurRadius: 2)],
                                                          ),
                                                        );
                                                      }).toList(),
                                                      sectionsSpace: 3,
                                                      centerSpaceRadius: 60,
                                                    ),
                                                  ),
                                                  Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Text(
                                                        '$total',
                                                        style: const TextStyle(
                                                          fontSize: 32,
                                                          fontWeight: FontWeight.bold,
                                                          color: Colors.blueAccent,
                                                        ),
                                                      ),
                                                      const Text(
                                                        'Tareas',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.grey,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 24),
                                            Wrap(
                                              spacing: 16,
                                              runSpacing: 8,
                                              children: _stats.map((s) {
                                                final double percentage = total > 0 ? (s.count / total * 100) : 0;
                                                return Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Container(
                                                      width: 12,
                                                      height: 12,
                                                      decoration: BoxDecoration(
                                                        color: _getStatusColor(s.status),
                                                        shape: BoxShape.circle,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      '${s.status}: ${s.count} (${percentage.toStringAsFixed(1)}%)',
                                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                                    ),
                                                  ],
                                                );
                                              }).toList(),
                                            ),
                                          ],
                                        ),
                            ],
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            
            // --- Accesos Directos ---
            Text(
              'Accesos Directos',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildMenuGrid(context, auth),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuGrid(BuildContext context, AuthProvider auth) {
    final cards = <Widget>[
      if (auth.puedeVer('clientes'))
        _buildMenuCard(context, 'Clientes', Icons.people_alt, Colors.orange, '/clients'),
      if (auth.puedeVer('proyectos'))
        _buildMenuCard(context, 'Proyectos', Icons.folder_copy, Colors.blue, '/projects'),
      if (auth.puedeVer('tareas'))
        _buildMenuCard(context, 'Tareas', Icons.task_alt, Colors.green, '/tasks'),
      if (auth.puedeVer('usuarios'))
        _buildMenuCard(context, 'Usuarios', Icons.manage_accounts, Colors.blueGrey, '/users'),
    ];

    if (cards.isEmpty) return const SizedBox();

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: MediaQuery.of(context).size.width > 900 ? 4 : (MediaQuery.of(context).size.width > 600 ? 2 : 1),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 2.5,
      children: cards,
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, IconData icon, Color color, String route) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => context.go(route),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const Spacer(),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
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
}
