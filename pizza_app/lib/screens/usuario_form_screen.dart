import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql/mutations.dart';
import '../models/usuario.dart';

class UsuarioFormScreen extends StatefulWidget {
  final Usuario? usuario;

  const UsuarioFormScreen({Key? key, this.usuario}) : super(key: key);

  @override
  _UsuarioFormScreenState createState() => _UsuarioFormScreenState();
}

class _UsuarioFormScreenState extends State<UsuarioFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isActive = true;
  bool _isLoading = false;
  bool _isEditing = false;
  bool _showPassword = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.usuario != null;
    if (_isEditing) {
      _nameController.text = widget.usuario!.name;
      _isActive = widget.usuario!.state ?? true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = _isEditing ? 'Editar Usuario' : 'Nuevo Usuario';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de usuario',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un nombre de usuario';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: _isEditing ? 'Nueva contraseña (opcional)' : 'Contraseña',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        _showPassword = !_showPassword;
                      });
                    },
                  ),
                ),
                obscureText: !_showPassword,
                validator: (value) {
                  if (!_isEditing && (value == null || value.isEmpty)) {
                    return 'Por favor ingrese una contraseña';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Activo'),
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
                  });
                },
              ),
              const SizedBox(height: 24),
              Mutation(
                options: MutationOptions(
                  document: gql(_isEditing
                      ? PizzaMutations.updateUsuario
                      : PizzaMutations.createUsuario),
                  onCompleted: (dynamic resultData) {
                    setState(() => _isLoading = false);
                    _showSuccess(_isEditing
                        ? 'Usuario actualizado correctamente'
                        : 'Usuario creado correctamente');
                    Navigator.pop(context, true);
                  },
                  onError: (error) {
                    setState(() => _isLoading = false);
                    _showError(error?.graphqlErrors.first.message ??
                        'Error al guardar el usuario');
                  },
                ),
                builder: (RunMutation runMutation, QueryResult? result) {
                  return ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              setState(() => _isLoading = true);
                              final variables = <String, dynamic>{
                                'nombre': _nameController.text,
                              };
                              
                              // Solo agregar estado si estamos editando
                              if (_isEditing) {
                                variables['estado'] = _isActive;
                                variables['usu_id'] = widget.usuario!.id.toString();
                                if (_passwordController.text.isNotEmpty) {
                                  variables['contrasenia'] = _passwordController.text;
                                }
                              } else {
                                variables['estado'] = _isActive;
                                variables['contrasenia'] = _passwordController.text;
                              }

                              runMutation(variables);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(_isEditing ? 'Actualizar' : 'Crear'),
                  );
                },
              ),
              if (_isEditing) ...[
                const SizedBox(height: 16),
                Mutation(
                  options: MutationOptions(
                    document: gql(PizzaMutations.deleteUsuario),
                    onCompleted: (dynamic resultData) {
                      _showSuccess('Usuario eliminado correctamente');
                      Navigator.pop(context, true);
                    },
                    onError: (error) {
                      _showError(error?.graphqlErrors.first.message ??
                          'Error al eliminar el usuario');
                    },
                  ),
                  builder: (RunMutation runMutation, QueryResult? result) {
                    return ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Confirmar eliminación'),
                            content: const Text(
                                '¿Está seguro de que desea eliminar este usuario?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  runMutation({
                                    'usu_id': widget.usuario!.id.toString(),
                                  });
                                },
                                child: const Text('Eliminar'),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text('Eliminar'),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}