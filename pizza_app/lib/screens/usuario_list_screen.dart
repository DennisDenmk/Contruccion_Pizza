import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql/queries.dart';
import '../models/usuario.dart';
import 'usuario_form_screen.dart';
import 'usuario_roles_screen.dart';

class UsuarioListScreen extends StatelessWidget {
  const UsuarioListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Usuarios'),
      ),
      body: Query(
        options: QueryOptions(
          document: gql(PizzaQueries.usuarios),
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

          final usuarios = (result.data?['usuarios'] as List<dynamic>?)
              ?.map((usuario) => Usuario.fromJson(usuario))
              .toList() ?? [];

          if (usuarios.isEmpty) {
            return const Center(child: Text('No hay usuarios disponibles'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              await refetch!();
            },
            child: ListView.builder(
              itemCount: usuarios.length,
              itemBuilder: (context, index) {
                final usuario = usuarios[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.person),
                    ),
                    title: Text(usuario.name),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          usuario.state ?? false ? Icons.check_circle : Icons.cancel,
                          color: usuario.state ?? false ? Colors.green : Colors.red,
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
                                    builder: (context) => UsuarioFormScreen(usuario: usuario),
                                  ),
                                ).then((_) => refetch!());
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.admin_panel_settings),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UsuarioRolesScreen(usuario: usuario),
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
            MaterialPageRoute(builder: (context) => const UsuarioFormScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}