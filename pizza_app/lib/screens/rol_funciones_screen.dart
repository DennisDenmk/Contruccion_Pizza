import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql/queries.dart';
import '../graphql/mutations.dart';
import '../models/rol.dart';
import '../models/funcion.dart';

class RolFuncionesScreen extends StatelessWidget {
  final Rol rol;

  const RolFuncionesScreen({Key? key, required this.rol}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Funciones del Rol: ${rol.name}'),
      ),
      body: Query(
        options: QueryOptions(
          document: gql(PizzaQueries.rolById),
          variables: {'id': rol.id.toString()},
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

          // Obtener el rol con sus funciones
          final rolData = result.data?['rol'];
          final rolFunciones = rolData?['funciones'] as List<dynamic>? ?? [];
          
          // Obtener todas las funciones disponibles
          final Query funcionesQuery = Query(
            options: QueryOptions(
              document: gql(PizzaQueries.funciones),
              fetchPolicy: FetchPolicy.noCache,
            ),
            builder: (QueryResult funcionesResult, {fetchMore, refetch}) {
              if (funcionesResult.hasException || funcionesResult.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              
              final allFunciones = (funcionesResult.data?['funciones'] as List<dynamic>?)
                ?.map((funcion) => Funcion.fromJson(funcion))
                .where((funcion) => funcion.state) // Solo funciones activas
                .toList() ?? [];
              
              // Crear un conjunto con los IDs de las funciones asignadas al rol
              final asignadas = <int>{};
              for (var funcion in rolFunciones) {
                final funId = funcion['fun_id'] is int ? 
                  funcion['fun_id'] : 
                  int.parse(funcion['fun_id'].toString());
                asignadas.add(funId);
              }
              
              if (allFunciones.isEmpty) {
                return const Center(child: Text('No hay funciones disponibles'));
              }
              
              return ListView.builder(
                itemCount: allFunciones.length,
                itemBuilder: (context, index) {
                  final funcion = allFunciones[index];
                  final bool estaAsignada = asignadas.contains(funcion.id);
                  
                  return _buildFuncionItem(context, funcion, estaAsignada, refetch!);
                },
              );
            },
          );
          
          return funcionesQuery;

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildFuncionItem(BuildContext context, Funcion funcion, bool estaAsignada, Function refetch) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: estaAsignada ? Colors.green.shade50 : Colors.red.shade50,
      child: ListTile(
        title: Text(funcion.name, style: TextStyle(color: estaAsignada ? Colors.green.shade800 : Colors.red.shade800)),
        subtitle: Text(funcion.description),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Botón para asignar o eliminar función del rol
            Mutation(
              options: MutationOptions(
                document: gql(estaAsignada ? 
                  PizzaMutations.removeFuncionFromRol : 
                  PizzaMutations.assignFuncionToRol),
                onCompleted: (dynamic resultData) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(estaAsignada ? 
                        'Función ${funcion.name} eliminada del rol' : 
                        'Función ${funcion.name} asignada al rol'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  refetch();
                },
                onError: (error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(error?.graphqlErrors.first.message ?? 
                          'Error al ${estaAsignada ? "eliminar" : "asignar"} la función'),
                      backgroundColor: Colors.red,
                    ),
                  );
                },
              ),
              builder: (RunMutation runMutation, QueryResult? result) {
                return IconButton(
                  icon: Icon(
                    estaAsignada ? Icons.remove_circle : Icons.add_circle,
                    color: estaAsignada ? Colors.red : Colors.green,
                  ),
                  onPressed: () {
                    runMutation({
                      'rol_id': rol.id.toString(),
                      'fun_id': funcion.id.toString(),
                    });
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}