const { mergeResolvers } = require('@graphql-tools/merge');

const usuarioResolvers = require('./usuario.resolver');
const rolResolvers = require('./rol.resolver');
const funcionResolvers = require('./funcion.resolver');
const pizzaResolvers = require('./pizza.resolver');
const ingredienteResolvers = require('./ingrediente.resolver');
const pizzaIngredienteResolvers = require('./pizzaIngrediente.resolver');

module.exports = mergeResolvers([
  usuarioResolvers,
  rolResolvers,
  funcionResolvers,
  pizzaResolvers,
  ingredienteResolvers,
  pizzaIngredienteResolvers,
]);
