import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql/queries.dart';

class PermissionProvider extends ChangeNotifier {
  final Set<int> _userFunctionIds = {};
  bool _isLoading = true;
  
  bool get isLoading => _isLoading;
  
  Set<int> get userFunctionIds => _userFunctionIds;
  
  // Constantes para las funciones (usando IDs)
  static const int PIZZAS = 1;
  static const int INGREDIENTES = 2;
  static const int USUARIOS = 3;
  static const int ROLES = 4;
  static const int FUNCIONES = 5;
  
  // Verificar si el usuario tiene una función específica por ID
  bool hasFunction(int functionId) {
    print('DEBUG: Verificando función $functionId en $_userFunctionIds');
    return _userFunctionIds.contains(functionId);
  }
  
  // Cargar las funciones del usuario actual
  Future<Set<int>> loadUserFunctions(GraphQLClient client, int userId) async {
    _isLoading = true;
    notifyListeners();
    
    print('DEBUG: Cargando funciones para el usuario ID: $userId');
    
    try {
      // Forzar un pequeño retraso para asegurar que la consulta se ejecute correctamente
      await Future.delayed(const Duration(milliseconds: 100));
      
      final QueryResult result = await client.query(
        QueryOptions(
          document: gql(PizzaQueries.userRoleFunctions),
          variables: {'userId': userId.toString()},
          fetchPolicy: FetchPolicy.noCache, // Siempre obtener datos frescos
        ),
      );
      
      print('DEBUG: Resultado de la consulta: ${result.data}');
      
      if (result.hasException) {
        print('Error al cargar funciones: ${result.exception.toString()}');
        _isLoading = false;
        notifyListeners();
        return {};
      }
      
      _userFunctionIds.clear();
      
      print('DEBUG: Datos recibidos: ${result.data}');
      final roles = result.data?['usuarioRoles'] as List<dynamic>?;
      print('DEBUG: Roles obtenidos: $roles');
      
      if (roles != null && roles.isNotEmpty) {
        print('DEBUG: Procesando ${roles.length} roles');
        for (var rol in roles) {
          print('DEBUG: Rol: ${rol['rol_name']}, Funciones: ${rol['funciones']}');
          if (rol['funciones'] != null) {
            final funciones = rol['funciones'] as List<dynamic>;
            
            for (var funcion in funciones) {
              final funId = funcion['fun_id'] is int ? 
                funcion['fun_id'] : 
                int.parse(funcion['fun_id'].toString());
              
              print('DEBUG: Agregando función ID: $funId');
              _userFunctionIds.add(funId);
            }
          }
        }
      }
      
      print('DEBUG: Funciones cargadas: $_userFunctionIds');
      _isLoading = false;
      notifyListeners();
      return _userFunctionIds;
    } catch (e) {
      print('Error al cargar funciones: $e');
      _isLoading = false;
      notifyListeners();
      return {};
    }
  }
  
  // Para pruebas o desarrollo
  void setMockFunctions(List<int> functionIds) {
    _userFunctionIds.clear();
    _userFunctionIds.addAll(functionIds);
    _isLoading = false;
    print('DEBUG: Funciones establecidas manualmente: $_userFunctionIds');
    notifyListeners();
  }
}