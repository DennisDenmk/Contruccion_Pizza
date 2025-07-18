import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql/mutations.dart';
import '../models/rol.dart';

class RolFormScreen extends StatefulWidget {
  final Rol? rol;

  const RolFormScreen({Key? key, this.rol}) : super(key: key);

  @override
  _RolFormScreenState createState() => _RolFormScreenState();
}

class _RolFormScreenState extends State<RolFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.rol != null) {
      _nameController.text = widget.rol!.name;
      _descriptionController.text = widget.rol!.description;
      _isActive = widget.rol!.state;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
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
    final isEditing = widget.rol != null;
    final title = isEditing ? 'Editar Rol' : 'Nuevo Rol';

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
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese una descripción';
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
                  document: gql(isEditing
                      ? PizzaMutations.updateRol
                      : PizzaMutations.createRol),
                  onCompleted: (dynamic resultData) {
                    setState(() => _isLoading = false);
                    _showSuccess(isEditing
                        ? 'Rol actualizado correctamente'
                        : 'Rol creado correctamente');
                    Navigator.pop(context);
                  },
                  onError: (error) {
                    setState(() => _isLoading = false);
                    _showError(error?.graphqlErrors.first.message ??
                        'Error al guardar el rol');
                  },
                ),
                builder: (RunMutation runMutation, QueryResult? result) {
                  return ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              setState(() => _isLoading = true);
                              final variables = {
                                'rol_name': _nameController.text,
                                'rol_description': _descriptionController.text,
                                'rol_state': _isActive,
                              };

                              if (isEditing) {
                                variables['rol_id'] = widget.rol!.id.toString();
                              }

                              runMutation(variables);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(isEditing ? 'Actualizar' : 'Crear'),
                  );
                },
              ),
              if (isEditing) ...[
                const SizedBox(height: 16),
                Mutation(
                  options: MutationOptions(
                    document: gql(PizzaMutations.deleteRol),
                    onCompleted: (dynamic resultData) {
                      _showSuccess('Rol eliminado correctamente');
                      Navigator.pop(context);
                    },
                    onError: (error) {
                      _showError(error?.graphqlErrors.first.message ??
                          'Error al eliminar el rol');
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
                                '¿Está seguro de que desea eliminar este rol?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  runMutation({
                                    'rol_id': widget.rol!.id.toString(),
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