import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql/queries.dart';
import '../models/funcion.dart';
import 'funcion_form_screen.dart';

class FuncionListScreen extends StatelessWidget {
  const FuncionListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Funciones'),
      ),
      body: Query(
        options: QueryOptions(
          document: gql(PizzaQueries.funciones),
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

          final funciones = (result.data?['funciones'] as List<dynamic>?)
              ?.map((funcion) => Funcion.fromJson(funcion))
              .toList() ?? [];

          if (funciones.isEmpty) {
            return const Center(child: Text('No hay funciones disponibles'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              await refetch!();
            },
            child: ListView.builder(
              itemCount: funciones.length,
              itemBuilder: (context, index) {
                final funcion = funciones[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(funcion.name),
                    subtitle: Text(funcion.description),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          funcion.state ? Icons.check_circle : Icons.cancel,
                          color: funcion.state ? Colors.green : Colors.red,
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FuncionFormScreen(funcion: funcion),
                              ),
                            ).then((_) => refetch!());
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FuncionFormScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}