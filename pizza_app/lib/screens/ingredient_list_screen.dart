import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql/queries.dart';
import '../models/ingredient.dart';
import 'ingredient_form_screen.dart';

class IngredientListScreen extends StatelessWidget {
  const IngredientListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ingredientes'),
      ),
      body: Query(
        options: QueryOptions(
          document: gql(PizzaQueries.ingredients),
          fetchPolicy: FetchPolicy.noCache,
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

          final ingredients = (result.data?['ingredientes'] as List<dynamic>?)
              ?.map((ingredient) => Ingredient.fromJson(ingredient))
              .toList() ?? [];

          if (ingredients.isEmpty) {
            return const Center(child: Text('No hay ingredientes disponibles'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              await refetch!();
            },
            child: Stack(
              children: [
                ListView.builder(
                  itemCount: ingredients.length,
                  itemBuilder: (context, index) {
                    final ingredient = ingredients[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(ingredient.name),
                        subtitle: Text('Calorías: ${ingredient.calories}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              ingredient.state ? Icons.check_circle : Icons.cancel,
                              color: ingredient.state ? Colors.green : Colors.red,
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => IngredientFormScreen(ingredient: ingredient),
                                  ),
                                ).then((value) {
                                  if (value == true) refetch!();
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: FloatingActionButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const IngredientFormScreen()),
                      ).then((value) {
                        if (value == true) refetch!();
                      });
                    },
                    child: const Icon(Icons.add),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}