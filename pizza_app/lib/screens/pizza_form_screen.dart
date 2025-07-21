import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql/mutations.dart';
import '../models/pizza.dart';

class PizzaFormScreen extends StatefulWidget {
  final Pizza? pizza;

  const PizzaFormScreen({Key? key, this.pizza}) : super(key: key);

  @override
  _PizzaFormScreenState createState() => _PizzaFormScreenState();
}

class _PizzaFormScreenState extends State<PizzaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _originController = TextEditingController();
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.pizza != null) {
      _nameController.text = widget.pizza!.name;
      _originController.text = widget.pizza!.origin;
      _isActive = widget.pizza!.state;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _originController.dispose();
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
    final isEditing = widget.pizza != null;
    final title = isEditing ? 'Editar Pizza' : 'Nueva Pizza';

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
                controller: _originController,
                decoration: const InputDecoration(
                  labelText: 'Origen',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el origen';
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
                      ? PizzaMutations.updatePizza
                      : PizzaMutations.createPizza),
                  onCompleted: (dynamic resultData) {
                    setState(() => _isLoading = false);
                    _showSuccess(isEditing
                        ? 'Pizza actualizada correctamente'
                        : 'Pizza creada correctamente');
                    Navigator.pop(context, true); // Changed to return true
                  },
                  onError: (error) {
                    setState(() => _isLoading = false);
                    _showError(error?.graphqlErrors.first.message ??
                        'Error al guardar la pizza');
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
                                'piz_name': _nameController.text,
                                'piz_origin': _originController.text,
                                'piz_state': _isActive,
                              };

                              if (isEditing) {
                                variables['piz_id'] = widget.pizza!.id.toString();
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
                    document: gql(PizzaMutations.deletePizza),
                    onCompleted: (dynamic resultData) {
                      _showSuccess('Pizza eliminada correctamente');
                      Navigator.pop(context, true); // Changed to return true
                    },
                    onError: (error) {
                      _showError(error?.graphqlErrors.first.message ??
                          'Error al eliminar la pizza');
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
                                '¿Está seguro de que desea eliminar esta pizza?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  runMutation({
                                    'piz_id': widget.pizza!.id.toString(),
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