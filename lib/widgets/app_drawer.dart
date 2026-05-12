import 'package:flutter/material.dart';
import '../../providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.deepPurple,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: Colors.deepPurple),
                ),
                const SizedBox(height: 10),
                Text(
                  user?.name ?? 'Usuario',
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  user?.email ?? '',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard, color: Colors.deepPurple),
            title: const Text('Dashboard'),
            onTap: () => context.go('/'),
          ),
          if (auth.puedeVer('clientes'))
            ListTile(
              leading: const Icon(Icons.person_outline, color: Colors.orange),
              title: const Text('Clientes'),
              onTap: () => context.go('/clients'),
            ),
          if (auth.puedeVer('proyectos'))
            ListTile(
              leading: const Icon(Icons.folder_open, color: Colors.blue),
              title: const Text('Proyectos'),
              onTap: () => context.go('/projects'),
            ),
          if (auth.puedeVer('tareas'))
            ListTile(
              leading: const Icon(Icons.task_alt, color: Colors.green),
              title: const Text('Tareas'),
              onTap: () => context.go('/tasks'),
            ),
          if (auth.puedeVer('usuarios')) ...[
            const Divider(),
            ListTile(
              leading: const Icon(Icons.manage_accounts, color: Colors.blueGrey),
              title: const Text('Gestión de Usuarios'),
              onTap: () {
                Navigator.pop(context);
                context.go('/users');
              },
            ),
            if (auth.isAdmin)
              ListTile(
                leading: const Icon(Icons.security, color: Colors.teal),
                title: const Text('Permisos de Roles'),
                onTap: () {
                  Navigator.pop(context);
                  context.go('/users/permissions');
                },
              ),
          ],
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Cerrar Sesión'),
            onTap: () async {
              await auth.logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
    );
  }
}
