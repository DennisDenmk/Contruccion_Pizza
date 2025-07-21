import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql/mutations.dart';
import '../models/pizza.dart';
import '../models/ingredient.dart';

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
  List<Map<String, dynamic>> _ingredients = [];

  @override
  void initState() {
    super.initState();
    if (widget.pizza != null) {
      _nameController.text = widget.pizza!.name;
      _originController.text = widget.pizza!.origin;
      _isActive = widget.pizza!.state;
      _loadIngredients();
    }
  }

  void _loadIngredients() async {
    if (widget.pizza != null) {
      final result = await GraphQLProvider.of(context).value.query(QueryOptions(
        document: gql('''
          query PizzaIngredients(\$id: Int!) {
            pizzaIngredientes(piz_id: \$id) {
              ing_id
              piz_ing_quantified
            }
          }
        '''),
        variables: {'id': widget.pizza!.id},
      ));
      if (!result.hasException) {
        setState(() {
          _ingredients = (result.data?['pizzaIngredientes'] as List<dynamic>?)
              ?.map((e) => {'ing_id': e['ing_id'], 'quantity': e['piz_ing_quantified']})
              .toList() ?? [];
        });
      }
    }
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

  void _addIngredient(int? ingredientId, double quantity) {
    if (ingredientId != null && quantity > 0) {
      setState(() {
        _ingredients.removeWhere((ing) => ing['ing_id'] == ingredientId);
        _ingredients.add({'ing_id': ingredientId, 'quantity': quantity});
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _originController.dispose();
    super.dispose();
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
          child: SingleChildScrollView(
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
                const Text(
                  'Ingredientes',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildIngredientSelector(),
                const SizedBox(height: 16),
                _buildIngredientList(),
                const SizedBox(height: 24),
                Mutation(
                  options: MutationOptions(
                    document: gql(isEditing
                        ? PizzaMutations.updatePizzaWithIngredients
                        : PizzaMutations.createPizzaWithIngredients),
                    onCompleted: (dynamic resultData) {
                      setState(() => _isLoading = false);
                      _showSuccess(isEditing
                          ? 'Pizza actualizada correctamente'
                          : 'Pizza creada correctamente');
                      Navigator.pop(context, true);
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
                                  'ingredients': _ingredients
                                      .map((ing) => {
                                            'ing_id': ing['ing_id'],
                                            'piz_ing_quantified': ing['quantity'],
                                          })
                                      .toList(),
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
                      document: gql(PizzaMutations.deletePizzaWithRelations),
                      onCompleted: (dynamic resultData) {
                        _showSuccess('Pizza eliminada correctamente');
                        Navigator.pop(context);
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
                                  '¿Está seguro de que desea eliminar esta pizza y sus relaciones?'),
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
      ),
    );
  }

  Widget _buildIngredientSelector() {
    return Query(
      options: QueryOptions(
        document: gql('''
          query {
            ingredientes {
              ing_id
              ing_name
              ing_state
            }
          }
        '''),
      ),
      builder: (QueryResult result, {fetchMore, refetch}) {
        if (result.hasException) {
          return Text('Error: ${result.exception.toString()}',
              style: const TextStyle(color: Colors.red));
        }
        if (result.isLoading) {
          return const CircularProgressIndicator();
        }
        final ingredients = (result.data?['ingredientes'] as List<dynamic>?)
            ?.where((ing) => ing['ing_state'] == true)
            .toList() ?? [];
        int? selectedIngredientId;
        final _quantityController = TextEditingController(text: '1.0');

        return Column(
          children: [
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(
                labelText: 'Seleccione Ingrediente',
                border: OutlineInputBorder(),
              ),
              value: selectedIngredientId,
              items: ingredients.map((ing) {
              return DropdownMenuItem<int>(
              value: ing['ing_id'] is int ? ing['ing_id'] : int.tryParse(ing['ing_id'].toString()),
              child: Text(ing['ing_name']),
              );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedIngredientId = value;
                });
              },
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _quantityController,
              decoration: const InputDecoration(
                labelText: 'Cantidad',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingrese una cantidad';
                }
                if (double.tryParse(value) == null || double.parse(value) <= 0) {
                  return 'Cantidad inválida';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                if (selectedIngredientId != null) {
                  final quantity = double.tryParse(_quantityController.text) ?? 0.0;
                  if (quantity > 0) {
                    _addIngredient(selectedIngredientId, quantity);
                    _quantityController.clear();
                  } else {
                    _showError('La cantidad debe ser mayor a 0');
                  }
                } else {
                  _showError('Por favor seleccione un ingrediente');
                }
              },
              child: const Text('Agregar Ingrediente'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildIngredientList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _ingredients.length,
      itemBuilder: (context, index) {
        final ing = _ingredients[index];
        return ListTile(
          title: Text('Ingrediente ID: ${ing['ing_id']}'),
          subtitle: Text('Cantidad: ${ing['quantity']}'),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              setState(() {
                _ingredients.removeAt(index);
              });
            },
          ),
        );
      },
    );
  }
}