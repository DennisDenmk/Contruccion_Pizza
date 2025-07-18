class PizzaQueries {
  static String get pizzas => '''
    query GetPizzas {
      pizzas {
        piz_id
        piz_name
        piz_origin
        piz_state
      }
    }
  ''';

  static String get pizzaById => '''
    query GetPizza(\$id: ID!) {
      pizza(id: \$id) {
        piz_id
        piz_name
        piz_origin
        piz_state
      }
    }
  ''';

  static String get ingredients => '''
    query GetIngredients {
      ingredientes {
        ing_id
        ing_name
        ing_calories
        ing_state
      }
    }
  ''';

  static String get pizzaIngredients => '''
    query GetPizzaIngredients {
      pizzaIngredientes {
        piz_id
        ing_id
        piz_ing_quantified
      }
    }
  ''';
  
  static String get pizzaIngredientsByPizzaId => '''
    query GetPizzaIngredientsByPizzaId {
      pizzaIngredientes {
        piz_id
        ing_id
        piz_ing_quantified
      }
      ingredientes {
        ing_id
        ing_name
        ing_calories
        ing_state
      }
    }
  ''';
  
  static String get roles => '''
    query GetRoles {
      roles {
        rol_id
        rol_name
        rol_description
        rol_state
      }
    }
  ''';

  static String get rolById => '''
    query GetRol(\$id: ID!) {
      rol(id: \$id) {
        rol_id
        rol_name
        rol_description
        rol_state
        funciones {
          fun_id
          fun_name
          fun_description
          fun_state
        }
      }
    }
  ''';
  
  static String get rolFunciones => '''
    query GetRolFunciones {
      roles {
        rol_id
        rol_name
      }
      funciones {
        fun_id
        fun_name
        fun_description
        fun_state
      }
    }
  ''';

  static String get funciones => '''
    query GetFunciones {
      funciones {
        fun_id
        fun_name
        fun_description
        fun_state
      }
    }
  ''';

  static String get funcionById => '''
    query GetFuncion(\$id: ID!) {
      funcion(id: \$id) {
        fun_id
        fun_name
        fun_description
        fun_state
      }
    }
  ''';

  static String get usuarios => '''
    query GetUsuarios {
      usuarios {
        usu_id
        usu_name
        usu_state
      }
    }
  ''';
  
  static String get userRoleFunctions => '''
    query GetUserRoleFunctions(\$userId: ID!) {
      usuarioRoles(userId: \$userId) {
        rol_id
        rol_name
        funciones {
          fun_id
          fun_name
          fun_description
          fun_state
        }
      }
    }
  ''';

  static String get usuarioById => '''
    query GetUsuario(\$id: ID!) {
      usuario(id: \$id) {
        usu_id
        usu_name
        usu_state
      }
      usuarioRoles(userId: \$id) {
        rol_id
        rol_name
        rol_description
      }
    }
  ''';
}

class AuthQueries {
  static String get login => '''
    mutation Login(\$nombre: String!, \$contrasenia: String!) {
      login(nombre: \$nombre, contrasenia: \$contrasenia)
    }
  ''';
}