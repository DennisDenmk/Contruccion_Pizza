const { mergeTypeDefs } = require('@graphql-tools/merge');

const usuarioTypeDefs = require('./usuario.type');
const rolTypeDefs = require('./rol.type');
const funcionTypeDefs = require('./funcion.type');
const pizzaTypeDefs = require('./pizza.type');
const ingredienteTypeDefs = require('./ingrediente.type');
const pizzaIngredienteTypeDefs = require('./pizzaIngrediente.type');

module.exports = mergeTypeDefs([
  usuarioTypeDefs,
  rolTypeDefs,
  funcionTypeDefs,
  pizzaTypeDefs,
  ingredienteTypeDefs,
  pizzaIngredienteTypeDefs,
]);
