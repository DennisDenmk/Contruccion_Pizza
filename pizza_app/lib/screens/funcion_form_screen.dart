import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql/mutations.dart';
import '../models/funcion.dart';

class FuncionFormScreen extends StatefulWidget {
  final Funcion? funcion;

  const FuncionFormScreen({Key? key, this.funcion}) : super(key: key);

  @override
  _FuncionFormScreenState createState() => _FuncionFormScreenState();
}

class _FuncionFormScreenState extends State<FuncionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.funcion != null) {
      _nameController.text = widget.funcion!.name;
      _descriptionController.text = widget.funcion!.description;
      _isActive = widget.funcion!.state;
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
    final isEditing = widget.funcion != null;
    final title = isEditing ? 'Editar Función' : 'Nueva Función';

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
                      ? PizzaMutations.updateFuncion
                      : PizzaMutations.createFuncion),
                  onCompleted: (dynamic resultData) {
                    setState(() => _isLoading = false);
                    _showSuccess(isEditing
                        ? 'Función actualizada correctamente'
                        : 'Función creada correctamente');
                    Navigator.pop(context);
                  },
                  onError: (error) {
                    setState(() => _isLoading = false);
                    _showError(error?.graphqlErrors.first.message ??
                        'Error al guardar la función');
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
                                'fun_name': _nameController.text,
                                'fun_description': _descriptionController.text,
                                'fun_state': _isActive,
                              };

                              if (isEditing) {
                                variables['fun_id'] = widget.funcion!.id.toString();
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
                    document: gql(PizzaMutations.deleteFuncion),
                    onCompleted: (dynamic resultData) {
                      _showSuccess('Función eliminada correctamente');
                      Navigator.pop(context);
                    },
                    onError: (error) {
                      _showError(error?.graphqlErrors.first.message ??
                          'Error al eliminar la función');
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
                                '¿Está seguro de que desea eliminar esta función?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  runMutation({
                                    'fun_id': widget.funcion!.id.toString(),
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