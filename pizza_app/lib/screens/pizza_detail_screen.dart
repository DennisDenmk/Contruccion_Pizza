import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql/queries.dart';
import '../graphql/mutations.dart';
import '../models/pizza.dart';
import '../models/ingredient.dart';

class PizzaDetailScreen extends StatelessWidget {
  final int pizzaId;

  const PizzaDetailScreen({Key? key, required this.pizzaId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles de Pizza'),
      ),
      body: Query(
        options: QueryOptions(
          document: gql(PizzaQueries.pizzaById),
          variables: {'id': pizzaId.toString()},
        ),
        builder: (QueryResult result, {fetchMore, refetch}) {
          if (result.hasException) {
            return Center(
              child: Text(
                'Error: ${result.exception.toString()}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (result.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final pizzaData = result.data?['pizza'];
          if (pizzaData == null) {
            return const Center(child: Text('Pizza no encontrada'));
          }

          final pizza = Pizza.fromJson(pizzaData);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pizza.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('Origen: ${pizza.origin}'),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Text('Estado: '),
                            Icon(
                              pizza.state ? Icons.check_circle : Icons.cancel,
                              color: pizza.state ? Colors.green : Colors.red,
                            ),
                            Text(
                              pizza.state ? ' Activo' : ' Inactivo',
                              style: TextStyle(
                                color: pizza.state ? Colors.green : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Ingredientes',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildIngredientsList(context, pizzaId, refetch),
              ],
            ),
          );
        },
      ),
      floatingActionButton: Builder(
        builder: (context) {
          return FloatingActionButton(
            onPressed: () {
              _showAddIngredientDialog(context);
            },
            child: const Icon(Icons.add),
          );
        },
      ),
    );
  }

  Widget _buildIngredientsList(BuildContext context, int pizzaId, Function? refetch) {
    // Si refetch es nulo, usamos una función vacía para evitar errores
    refetch ??= () {};

    return Query(
      options: QueryOptions(
        document: gql(PizzaQueries.pizzaIngredientsByPizzaId),
        variables: {'piz_id': pizzaId},
      ),
      builder: (QueryResult result, {fetchMore, refetch = null}) {
        if (result.hasException) {
          return Center(
            child: Text(
              'Error: ${result.exception.toString()}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        if (result.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final pizzaIngredientes = result.data?['pizzaIngredientes'] as List<dynamic>? ?? [];
        final ingredientes = result.data?['ingredientes'] as List<dynamic>? ?? [];

        if (pizzaIngredientes.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Esta pizza no tiene ingredientes'),
            ),
          );
        }

        final pizzaIngredientesMap = {
          for (var pi in pizzaIngredientes) pi['ing_id'].toString(): pi['piz_ing_quantified']
        };

        final ingredientesDePizza = ingredientes.where((ing) =>
            pizzaIngredientesMap.containsKey(ing['ing_id'].toString())).toList();

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: ingredientesDePizza.length,
          itemBuilder: (context, index) {
            final item = ingredientesDePizza[index];
            final ingId = item['ing_id'].toString();
            final cantidad = pizzaIngredientesMap[ingId] ?? 'N/A';
            
            return Card(
              child: ListTile(
                title: Text(item['ing_name']),
                subtitle: Text('Cantidad: $cantidad'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    _removeIngredient(
                      context,
                      pizzaId,
                      int.parse(ingId),
                      refetch,
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAddIngredientDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddIngredientDialog(pizzaId: pizzaId),
    );
  }

  void _removeIngredient(
      BuildContext context, int pizzaId, int ingredientId, Function? refetch) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Está seguro de que desea eliminar este ingrediente de la pizza?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          Mutation(
            options: MutationOptions(
              document: gql(PizzaMutations.removeIngredientFromPizza),
              onCompleted: (dynamic resultData) {
                Navigator.pop(context);
                if (refetch != null) refetch();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ingrediente eliminado correctamente'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              onError: (error) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(error?.graphqlErrors.first.message ??
                        'Error al eliminar el ingrediente'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
            ),
            builder: (RunMutation runMutation, QueryResult? result) {
              return TextButton(
                onPressed: () {
                  runMutation({
                    'piz_id': pizzaId.toString(),
                    'ing_id': ingredientId.toString(),
                  });
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Eliminar'),
              );
            },
          ),
        ],
      ),
    );
  }
}

class AddIngredientDialog extends StatefulWidget {
  final int pizzaId;

  const AddIngredientDialog({Key? key, required this.pizzaId}) : super(key: key);

  @override
  _AddIngredientDialogState createState() => _AddIngredientDialogState();
}

class _AddIngredientDialogState extends State<AddIngredientDialog> {
  int? _selectedIngredientId;
  final _quantityController = TextEditingController(text: '1.0');

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Agregar Ingrediente'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Query(
            options: QueryOptions(
              document: gql(PizzaQueries.ingredients),
            ),
            builder: (QueryResult result, {fetchMore, refetch}) {
              if (result.hasException) {
                return Text(
                  'Error: ${result.exception.toString()}',
                  style: const TextStyle(color: Colors.red),
                );
              }

              if (result.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              final ingredients = (result.data?['ingredientes'] as List<dynamic>?)
                  ?.map((ing) => Ingredient.fromJson(ing))
                  .where((ing) => ing.state)
                  .toList() ?? [];

              if (ingredients.isEmpty) {
                return const Text('No hay ingredientes disponibles');
              }

              return DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'Ingrediente',
                  border: OutlineInputBorder(),
                ),
                value: _selectedIngredientId,
                items: ingredients.map((ingredient) {
                  return DropdownMenuItem<int>(
                    value: ingredient.id,
                    child: Text(ingredient.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedIngredientId = value;
                  });
                },
              );
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _quantityController,
            decoration: const InputDecoration(
              labelText: 'Cantidad',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        Mutation(
          options: MutationOptions(
            document: gql(PizzaMutations.assignIngredientToPizza),
            onCompleted: (dynamic resultData) {
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Ingrediente agregado correctamente'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            onError: (error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(error?.graphqlErrors.first.message ??
                      'Error al agregar el ingrediente'),
                  backgroundColor: Colors.red,
                ),
              );
            },
          ),
          builder: (RunMutation runMutation, QueryResult? result) {
            return TextButton(
              onPressed: () {
                if (_selectedIngredientId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Por favor seleccione un ingrediente'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                double? quantity = double.tryParse(_quantityController.text);
                if (quantity == null || quantity <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Por favor ingrese una cantidad válida'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                runMutation({
                  'piz_id': widget.pizzaId.toString(),
                  'ing_id': _selectedIngredientId.toString(),
                  'piz_ing_quantified': quantity,
                });
              },
              child: const Text('Agregar'),
            );
          },
        ),
      ],
    );
  }
}