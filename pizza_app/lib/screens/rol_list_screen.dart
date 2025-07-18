import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql/queries.dart';
import '../models/rol.dart';
import 'rol_form_screen.dart';
import 'rol_funciones_screen.dart';

class RolListScreen extends StatelessWidget {
  const RolListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Roles'),
      ),
      body: Query(
        options: QueryOptions(
          document: gql(PizzaQueries.roles),
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

          final roles = (result.data?['roles'] as List<dynamic>?)
              ?.map((rol) => Rol.fromJson(rol))
              .toList() ?? [];

          if (roles.isEmpty) {
            return const Center(child: Text('No hay roles disponibles'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              await refetch!();
            },
            child: ListView.builder(
              itemCount: roles.length,
              itemBuilder: (context, index) {
                final rol = roles[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(rol.name),
                    subtitle: Text(rol.description),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          rol.state ? Icons.check_circle : Icons.cancel,
                          color: rol.state ? Colors.green : Colors.red,
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RolFormScreen(rol: rol),
                                  ),
                                ).then((_) => refetch!());
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.security),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RolFuncionesScreen(rol: rol),
                                  ),
                                ).then((_) => refetch!());
                              },
                            ),
                          ],
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
            MaterialPageRoute(builder: (context) => const RolFormScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}