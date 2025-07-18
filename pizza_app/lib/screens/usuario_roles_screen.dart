import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql/queries.dart';
import '../graphql/mutations.dart';
import '../models/usuario.dart';
import '../models/rol.dart';

class UsuarioRolesScreen extends StatelessWidget {
  final Usuario usuario;

  const UsuarioRolesScreen({Key? key, required this.usuario}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Roles del Usuario: ${usuario.name}'),
      ),
      body: Query(
        options: QueryOptions(
          document: gql(PizzaQueries.usuarioById),
          variables: {'id': usuario.id.toString()},
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

          // Obtener el usuario con sus roles
          final usuarioData = result.data?['usuario'];
          final usuarioRoles = result.data?['usuarioRoles'] as List<dynamic>? ?? [];
          
          // Obtener todos los roles disponibles
          final Query rolesQuery = Query(
            options: QueryOptions(
              document: gql(PizzaQueries.roles),
              fetchPolicy: FetchPolicy.noCache,
            ),
            builder: (QueryResult rolesResult, {fetchMore, refetch}) {
              if (rolesResult.hasException || rolesResult.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              
              final allRoles = (rolesResult.data?['roles'] as List<dynamic>?)
                ?.map((rol) => Rol.fromJson(rol))
                .where((rol) => rol.state) // Solo roles activos
                .toList() ?? [];
              
              // Crear un conjunto con los IDs de los roles asignados al usuario
              final asignados = <int>{};
              for (var rol in usuarioRoles) {
                final rolId = rol['rol_id'] is int ? 
                  rol['rol_id'] : 
                  int.parse(rol['rol_id'].toString());
                asignados.add(rolId);
              }
              
              if (allRoles.isEmpty) {
                return const Center(child: Text('No hay roles disponibles'));
              }
              
              return ListView.builder(
                itemCount: allRoles.length,
                itemBuilder: (context, index) {
                  final rol = allRoles[index];
                  final bool estaAsignado = asignados.contains(rol.id);
                  
                  return _buildRolItem(context, rol, estaAsignado, refetch!);
                },
              );
            },
          );
          
          return rolesQuery;
        },
      ),
    );
  }

  Widget _buildRolItem(BuildContext context, Rol rol, bool estaAsignado, Function refetch) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: estaAsignado ? Colors.blue.shade50 : Colors.grey.shade100,
      child: ListTile(
        title: Text(rol.name, style: TextStyle(color: estaAsignado ? Colors.blue.shade800 : Colors.black87)),
        subtitle: Text(rol.description),
        trailing: Mutation(
          options: MutationOptions(
            document: gql(estaAsignado ? 
              PizzaMutations.removeRolFromUsuario : 
              PizzaMutations.assignRolToUsuario),
            onCompleted: (dynamic resultData) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(estaAsignado ? 
                    'Rol ${rol.name} eliminado del usuario' : 
                    'Rol ${rol.name} asignado al usuario'),
                  backgroundColor: Colors.green,
                ),
              );
              refetch();
            },
            onError: (error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(error?.graphqlErrors.first.message ?? 
                      'Error al ${estaAsignado ? "eliminar" : "asignar"} el rol'),
                  backgroundColor: Colors.red,
                ),
              );
            },
          ),
          builder: (RunMutation runMutation, QueryResult? result) {
            return IconButton(
              icon: Icon(
                estaAsignado ? Icons.remove_circle : Icons.add_circle,
                color: estaAsignado ? Colors.red : Colors.green,
              ),
              onPressed: () {
                runMutation({
                  'usu_id': usuario.id.toString(),
                  'rol_id': rol.id.toString(),
                });
              },
            );
          },
        ),
      ),
    );
  }
}