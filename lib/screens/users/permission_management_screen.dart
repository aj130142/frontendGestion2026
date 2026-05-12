import 'package:flutter/material.dart';
import '../../models/role.dart';
import '../../models/module.dart';
import '../../models/role_permission.dart';
import '../../services/permission_service.dart';

class PermissionManagementScreen extends StatefulWidget {
  const PermissionManagementScreen({super.key});

  @override
  State<PermissionManagementScreen> createState() => _PermissionManagementScreenState();
}

class _PermissionManagementScreenState extends State<PermissionManagementScreen> {
  List<Role> _roles = [];
  List<AppModule> _modulos = [];
  Role? _selectedRole;
  List<RolePermission> _currentPermissions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    final roles = await PermissionService.getAllRoles();
    final modulos = await PermissionService.getAllModules();
    setState(() {
      _roles = roles;
      _modulos = modulos;
      if (_roles.isNotEmpty) {
        _selectedRole = _roles.first;
        _loadRolePermissions(_selectedRole!.id);
      } else {
        _isLoading = false;
      }
    });
  }

  Future<void> _loadRolePermissions(int idRol) async {
    setState(() => _isLoading = true);
    final perms = await PermissionService.getPermissionsByRole(idRol);
    
    // Asegurar que cada módulo tenga una entrada en la lista, incluso si el backend no la tiene
    final List<RolePermission> normalizedPerms = [];
    for (var mod in _modulos) {
      final existing = perms.where((p) => p.idModulo == mod.id).firstOrNull;
      if (existing != null) {
        normalizedPerms.add(existing);
      } else {
        normalizedPerms.add(RolePermission(
          idRol: idRol,
          idModulo: mod.id,
          modulo: mod,
        ));
      }
    }

    setState(() {
      _currentPermissions = normalizedPerms;
      _isLoading = false;
    });
  }

  Future<void> _togglePermission(RolePermission rp, String type, bool value) async {
    setState(() {
      if (type == 'ver') rp.puedeVer = value;
      if (type == 'crear') rp.puedeCrear = value;
      if (type == 'editar') rp.puedeEditar = value;
      if (type == 'eliminar') rp.puedeEliminar = value;
    });

    final success = await PermissionService.updateRolePermission(rp);
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al actualizar permiso')),
      );
      // Revertir en caso de error (opcional, pero mejor para UX)
      setState(() {
        if (type == 'ver') rp.puedeVer = !value;
        if (type == 'crear') rp.puedeCrear = !value;
        if (type == 'editar') rp.puedeEditar = !value;
        if (type == 'eliminar') rp.puedeEliminar = !value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Gestión de Permisos', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueGrey[800],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildRoleSelector(),
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _buildPermissionsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          const Icon(Icons.security, color: Colors.blueGrey),
          const SizedBox(width: 12),
          const Text('Seleccionar Rol:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonFormField<Role>(
              value: _selectedRole,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              items: _roles.map((r) => DropdownMenuItem(
                value: r,
                child: Text(r.name),
              )).toList(),
              onChanged: (role) {
                if (role != null) {
                  setState(() => _selectedRole = role);
                  _loadRolePermissions(role.id);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionsList() {
    if (_currentPermissions.isEmpty) {
      return const Center(child: Text('No hay módulos disponibles'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _currentPermissions.length,
      itemBuilder: (context, index) {
        final rp = _currentPermissions[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.view_module, color: Colors.blueGrey),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      rp.modulo?.nombre.toUpperCase() ?? 'MÓDULO',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.1),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildPermissionToggle('VER', rp.puedeVer, (val) => _togglePermission(rp, 'ver', val)),
                    _buildPermissionToggle('CREAR', rp.puedeCrear, (val) => _togglePermission(rp, 'crear', val)),
                    _buildPermissionToggle('EDITAR', rp.puedeEditar, (val) => _togglePermission(rp, 'editar', val)),
                    _buildPermissionToggle('ELIMINAR', rp.puedeEliminar, (val) => _togglePermission(rp, 'eliminar', val)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPermissionToggle(String label, bool value, Function(bool) onChanged) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600], fontWeight: FontWeight.bold)),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.teal,
        ),
      ],
    );
  }
}
