import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../models/user.dart';

class UserFormScreen extends StatefulWidget {
  final User? user;

  const UserFormScreen({super.key, this.user});

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passController;
  
  int _roleId = 2; // Default to Usuario
  bool _active = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user?.name ?? '');
    _emailController = TextEditingController(text: widget.user?.email ?? '');
    _passController = TextEditingController();
    
    if (widget.user != null) {
      _roleId = widget.user!.roleId;
      _active = widget.user!.activo;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final prov = context.read<UserProvider>();
      
      bool success = false;
      try {
        if (widget.user == null) {
          success = await prov.createUser(
            _nameController.text,
            _emailController.text,
            _passController.text,
            _roleId,
          );
        } else {
          success = await prov.updateUser(
            widget.user!.id,
            _nameController.text,
            _emailController.text,
            _roleId,
            _active,
          );
        }

        if (mounted) {
          setState(() => _isLoading = false);
          if (success) {
            context.pop();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error: Revisa los datos o permisos')));
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user == null ? 'Nuevo Usuario' : 'Editar Usuario'),
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre Completo', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Correo Electrónico', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 20),
              if (widget.user == null) ...[
                TextFormField(
                  controller: _passController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Contraseña', border: OutlineInputBorder()),
                  validator: (v) => v!.length < 6 ? 'Mínimo 6 caracteres' : null,
                ),
                const SizedBox(height: 20),
              ],
              DropdownButtonFormField<int>(
                value: _roleId,
                decoration: const InputDecoration(labelText: 'Rol', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 1, child: Text('Administrador')),
                  DropdownMenuItem(value: 2, child: Text('Usuario Estándar')),
                  DropdownMenuItem(value: 3, child: Text('Cliente')),
                ],
                onChanged: (val) => setState(() => _roleId = val!),
              ),
              if (widget.user != null) ...[
                const SizedBox(height: 20),
                SwitchListTile(
                  title: const Text('Usuario Activo'),
                  value: _active,
                  onChanged: (val) => setState(() => _active = val),
                ),
              ],
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blueGrey,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
