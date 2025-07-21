import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql/queries.dart';
import '../models/pizza.dart';
import 'pizza_form_screen.dart';
import 'pizza_detail_screen.dart';

class PizzaListScreen extends StatefulWidget {
  const PizzaListScreen({Key? key}) : super(key: key);

  @override
  _PizzaListScreenState createState() => _PizzaListScreenState();
}

class _PizzaListScreenState extends State<PizzaListScreen> {
  late Function? _refetch;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pizzas'),
      ),
      body: Query(
        options: QueryOptions(
          document: gql(PizzaQueries.pizzas),
          fetchPolicy: FetchPolicy.noCache,
        ),
        builder: (QueryResult result, {fetchMore, refetch}) {
          _refetch = refetch;
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

          final pizzas = (result.data?['pizzas'] as List<dynamic>?)
              ?.map((pizza) => Pizza.fromJson(pizza))
              .toList() ?? [];

          if (pizzas.isEmpty) {
            return const Center(child: Text('No hay pizzas disponibles'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              if (_refetch != null) await _refetch!();
            },
            child: ListView.builder(
              itemCount: pizzas.length,
              itemBuilder: (context, index) {
                final pizza = pizzas[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(pizza.name),
                    subtitle: Text('Origen: ${pizza.origin}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          pizza.state ? Icons.check_circle : Icons.cancel,
                          color: pizza.state ? Colors.green : Colors.red,
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PizzaFormScreen(pizza: pizza),
                              ),
                            ).then((value) {
                              if (value == true && _refetch != null) _refetch!();
                            });
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PizzaDetailScreen(pizzaId: pizza.id),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: Builder(
        builder: (context) {
          return FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PizzaFormScreen()),
              ).then((value) {
                if (value == true && _refetch != null) _refetch!();
              });
            },
            child: const Icon(Icons.add),
          );
        },
      ),
    );
  }
}