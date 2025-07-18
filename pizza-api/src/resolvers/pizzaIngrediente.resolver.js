const { PizzaIngrediente } = require('../models');

module.exports = {
  Query: {
    pizzaIngredientes: (_, __, context) => {
      if (!context.user) throw new Error('No autenticado');
      return PizzaIngrediente.findAll();
    },
    pizzaIngrediente: (_, { piz_id, ing_id }, context) => {
      if (!context.user) throw new Error('No autenticado');
      return PizzaIngrediente.findOne({ where: { piz_id, ing_id } });
    },
  },
  Mutation: {
    crearPizzaIngrediente: (_, { input }, context) => {
      if (!context.user) throw new Error('No autenticado');
      return PizzaIngrediente.create(input);
    },
    actualizarPizzaIngrediente: async (_, { piz_id, ing_id, input }, context) => {
      if (!context.user) throw new Error('No autenticado');
      await PizzaIngrediente.update(input, { where: { piz_id, ing_id } });
      return PizzaIngrediente.findOne({ where: { piz_id, ing_id } });
    },
    eliminarPizzaIngrediente: async (_, { piz_id, ing_id }, context) => {
      if (!context.user) throw new Error('No autenticado');
      const pi = await PizzaIngrediente.findOne({ where: { piz_id, ing_id } });
      await pi.destroy();
      return true;
    },
  },
};
