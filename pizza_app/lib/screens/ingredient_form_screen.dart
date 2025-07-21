import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql/mutations.dart';
import '../models/ingredient.dart';

class IngredientFormScreen extends StatefulWidget {
  final Ingredient? ingredient;

  const IngredientFormScreen({Key? key, this.ingredient}) : super(key: key);

  @override
  _IngredientFormScreenState createState() => _IngredientFormScreenState();
}

class _IngredientFormScreenState extends State<IngredientFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _caloriesController = TextEditingController();
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.ingredient != null) {
      _nameController.text = widget.ingredient!.name;
      _caloriesController.text = widget.ingredient!.calories.toString();
      _isActive = widget.ingredient!.state;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
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
    final isEditing = widget.ingredient != null;
    final title = isEditing ? 'Editar Ingrediente' : 'Nuevo Ingrediente';

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
                controller: _caloriesController,
                decoration: const InputDecoration(
                  labelText: 'Calorías',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese las calorías';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Por favor ingrese un número válido';
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
                      ? PizzaMutations.updateIngredient
                      : PizzaMutations.createIngredient),
                  onCompleted: (dynamic resultData) {
                    setState(() => _isLoading = false);
                    _showSuccess(isEditing
                        ? 'Ingrediente actualizado correctamente'
                        : 'Ingrediente creado correctamente');
                    Navigator.pop(context);
                  },
                  onError: (error) {
                    setState(() => _isLoading = false);
                    _showError(error?.graphqlErrors.first.message ??
                        'Error al guardar el ingrediente');
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
                                'ing_name': _nameController.text,
                                'ing_calories': double.parse(_caloriesController.text),
                                'ing_state': _isActive,
                              };

                              if (isEditing) {
                                variables['ing_id'] = widget.ingredient!.id.toString();
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
                    document: gql(PizzaMutations.deleteIngredient),
                    onCompleted: (dynamic resultData) {
                      _showSuccess('Ingrediente eliminado correctamente');
                      Navigator.pop(context);
                    },
                    onError: (error) {
                      _showError(error?.graphqlErrors.first.message ??
                          'Error al eliminar el ingrediente');
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
                                '¿Está seguro de que desea eliminar este ingrediente?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  runMutation({
                                    'ing_id': widget.ingredient!.id.toString(),
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