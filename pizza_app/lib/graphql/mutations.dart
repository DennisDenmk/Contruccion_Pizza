class PizzaMutations {
  // Pizza Mutations
  static String get createPizza => '''
    mutation CreatePizza(\$piz_name: String!, \$piz_origin: String!, \$piz_state: Boolean!) {
      crearPizza(input: {piz_name: \$piz_name, piz_origin: \$piz_origin, piz_state: \$piz_state}) {
        piz_id
        piz_name
        piz_origin
        piz_state
      }
    }
  ''';

  static String get updatePizza => '''
    mutation UpdatePizza(\$piz_id: ID!, \$piz_name: String!, \$piz_origin: String!, \$piz_state: Boolean!) {
      actualizarPizza(id: \$piz_id, input: {piz_name: \$piz_name, piz_origin: \$piz_origin, piz_state: \$piz_state}) {
        piz_id
        piz_name
        piz_origin
        piz_state
      }
    }
  ''';

  static String get deletePizza => '''
    mutation DeletePizza(\$piz_id: ID!) {
      eliminarPizza(id: \$piz_id)
    }
  ''';

  static String get createPizzaWithIngredients => '''
    mutation CreatePizzaWithIngredients(\$piz_name: String!, \$piz_origin: String!, \$piz_state: Boolean!, \$ingredients: [PizzaIngredientInput!]!) {
      createPizzaWithIngredients(piz_name: \$piz_name, piz_origin: \$piz_origin, piz_state: \$piz_state, ingredients: \$ingredients) {
        piz_id
        piz_name
        piz_origin
        piz_state
      }
    }
  ''';

  static String get updatePizzaWithIngredients => '''
    mutation UpdatePizzaWithIngredients(\$piz_id: ID!, \$piz_name: String!, \$piz_origin: String!, \$piz_state: Boolean!, \$ingredients: [PizzaIngredientInput!]!) {
      updatePizzaWithIngredients(piz_id: \$piz_id, piz_name: \$piz_name, piz_origin: \$piz_origin, piz_state: \$piz_state, ingredients: \$ingredients) {
        piz_id
        piz_name
        piz_origin
        piz_state
      }
    }
  ''';

  static String get deletePizzaWithRelations => '''
    mutation DeletePizzaWithRelations(\$piz_id: ID!) {
      deletePizzaWithRelations(piz_id: \$piz_id)
    }
  ''';

  // Ingredient Mutations
  static String get createIngredient => '''
    mutation CreateIngredient(\$ing_name: String!, \$ing_calories: Float!, \$ing_state: Boolean!) {
      crearIngrediente(input: {ing_name: \$ing_name, ing_calories: \$ing_calories, ing_state: \$ing_state}) {
        ing_id
        ing_name
        ing_calories
        ing_state
      }
    }
  ''';

  static String get updateIngredient => '''
    mutation UpdateIngredient(\$ing_id: ID!, \$ing_name: String!, \$ing_calories: Float!, \$ing_state: Boolean!) {
      actualizarIngrediente(id: \$ing_id, input: {ing_name: \$ing_name, ing_calories: \$ing_calories, ing_state: \$ing_state}) {
        ing_id
        ing_name
        ing_calories
        ing_state
      }
    }
  ''';

  static String get deleteIngredient => '''
    mutation DeleteIngredient(\$ing_id: ID!) {
      eliminarIngrediente(id: \$ing_id)
    }
  ''';

  static String get assignIngredientToPizza => '''
    mutation AssignIngredientToPizza(\$piz_id: ID!, \$ing_id: ID!, \$piz_ing_quantified: Float!) {
      assignIngredientToPizza(piz_id: \$piz_id, ing_id: \$ing_id, piz_ing_quantified: \$piz_ing_quantified)
    }
  ''';

  static String get removeIngredientFromPizza => '''
    mutation RemoveIngredientFromPizza(\$piz_id: ID!, \$ing_id: ID!) {
      removeIngredientFromPizza(piz_id: \$piz_id, ing_id: \$ing_id)
    }
  ''';

  // Rol Mutations
  static String get createRol => '''
    mutation CreateRol(\$rol_name: String!, \$rol_description: String!, \$rol_state: Boolean!) {
      crearRol(input: {rol_name: \$rol_name, rol_description: \$rol_description, rol_state: \$rol_state}) {
        rol_id
        rol_name
        rol_description
        rol_state
      }
    }
  ''';

  static String get assignFuncionToRol => '''
    mutation AssignFuncionToRol(\$rol_id: ID!, \$fun_id: ID!) {
      asignarFuncionARol(rol_id: \$rol_id, fun_id: \$fun_id)
    }
  ''';

  static String get removeFuncionFromRol => '''
    mutation RemoveFuncionFromRol(\$rol_id: ID!, \$fun_id: ID!) {
      eliminarFuncionDeRol(rol_id: \$rol_id, fun_id: \$fun_id)
    }
  ''';

  static String get updateRol => '''
    mutation UpdateRol(\$rol_id: ID!, \$rol_name: String!, \$rol_description: String!, \$rol_state: Boolean!) {
      actualizarRol(id: \$rol_id, input: {rol_name: \$rol_name, rol_description: \$rol_description, rol_state: \$rol_state}) {
        rol_id
        rol_name
        rol_description
        rol_state
      }
    }
  ''';

  static String get deleteRol => '''
    mutation DeleteRol(\$rol_id: ID!) {
      eliminarRol(id: \$rol_id)
    }
  ''';

  // Funcion Mutations
  static String get createFuncion => '''
    mutation CreateFuncion(\$fun_name: String!, \$fun_description: String!, \$fun_state: Boolean!) {
      crearFuncion(input: {fun_name: \$fun_name, fun_description: \$fun_description, fun_state: \$fun_state}) {
        fun_id
        fun_name
        fun_description
        fun_state
      }
    }
  ''';

  static String get updateFuncion => '''
    mutation UpdateFuncion(\$fun_id: ID!, \$fun_name: String!, \$fun_description: String!, \$fun_state: Boolean!) {
      actualizarFuncion(id: \$fun_id, input: {fun_name: \$fun_name, fun_description: \$fun_description, fun_state: \$fun_state}) {
        fun_id
        fun_name
        fun_description
        fun_state
      }
    }
  ''';

  static String get deleteFuncion => '''
    mutation DeleteFuncion(\$fun_id: ID!) {
      eliminarFuncion(id: \$fun_id)
    }
  ''';

  // Usuario Mutations
  static String get createUsuario => '''
    mutation CreateUsuario(\$nombre: String!, \$contrasenia: String!, \$estado: Boolean) {
      register(input: {nombre: \$nombre, contrasenia: \$contrasenia, estado: \$estado}) {
        usu_id
        usu_name
        usu_state
      }
    }
  ''';

  static String get assignRolToUsuario => '''
    mutation AssignRolToUsuario(\$usu_id: ID!, \$rol_id: ID!) {
      asignarRolAUsuario(usu_id: \$usu_id, rol_id: \$rol_id)
    }
  ''';

  static String get removeRolFromUsuario => '''
    mutation RemoveRolFromUsuario(\$usu_id: ID!, \$rol_id: ID!) {
      eliminarRolDeUsuario(usu_id: \$usu_id, rol_id: \$rol_id)
    }
  ''';

  static String get updateUsuario => '''
    mutation UpdateUsuario(\$usu_id: ID!, \$nombre: String!, \$contrasenia: String, \$estado: Boolean) {
      actualizarUsuario(id: \$usu_id, input: {nombre: \$nombre, contrasenia: \$contrasenia, estado: \$estado}) {
        usu_id
        usu_name
        usu_state
      }
    }
  ''';

  static String get deleteUsuario => '''
    mutation DeleteUsuario(\$usu_id: ID!) {
      eliminarUsuario(id: \$usu_id)
    }
  ''';
}