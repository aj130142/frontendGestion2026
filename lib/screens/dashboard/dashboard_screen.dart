import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_drawer.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    // Solo mostrar las tarjetas de módulos que el usuario puede ver
    final cards = <Widget>[
      if (auth.puedeVer('clientes'))
        _buildMenuCard(
          context,
          'Clientes',
          'Gestión de cartera de clientes',
          Icons.people_alt,
          Colors.orange,
          '/clients',
        ),
      if (auth.puedeVer('proyectos'))
        _buildMenuCard(
          context,
          'Proyectos',
          'Seguimiento de proyectos activos',
          Icons.folder_copy,
          Colors.blue,
          '/projects',
        ),
      if (auth.puedeVer('tareas'))
        _buildMenuCard(
          context,
          'Tareas',
          'Listado general de tareas',
          Icons.task_alt,
          Colors.green,
          '/tasks',
        ),
      if (auth.puedeVer('usuarios'))
        _buildMenuCard(
          context,
          'Usuarios',
          'Gestión de cuentas de usuario',
          Icons.manage_accounts,
          Colors.blueGrey,
          '/users',
        ),
    ];

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
            Text(
              'TechSolutions S.A.',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
            ),
            const SizedBox(height: 4),
            if (user != null)
              Text(
                'Bienvenido, ${user.name}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
              ),
            const SizedBox(height: 8),
            Text(
              'Panel de Control del Sistema',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 40),
            if (cards.isEmpty)
              Center(
                child: Column(
                  children: [
                    Icon(Icons.lock_outline, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No tienes acceso a ningún módulo.',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                  ],
                ),
              )
            else
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: MediaQuery.of(context).size.width > 900
                    ? 3
                    : (MediaQuery.of(context).size.width > 600 ? 2 : 1),
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 1.6,
                children: cards,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    String route,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => context.go(route),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
