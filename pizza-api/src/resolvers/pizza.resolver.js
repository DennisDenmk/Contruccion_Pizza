const { Pizza } = require('../models');

module.exports = {
  Query: {
    pizzas: (_, __, context) => {
      if (!context.user) throw new Error('No autenticado');
      return Pizza.findAll();
    },
    pizza: (_, { id }, context) => {
      if (!context.user) throw new Error('No autenticado');
      return Pizza.findByPk(id);
    },
  },
  Mutation: {
    crearPizza: (_, { input }, context) => {
      if (!context.user) throw new Error('No autenticado');
      return Pizza.create(input);
    },
    actualizarPizza: async (_, { id, input }, context) => {
      if (!context.user) throw new Error('No autenticado');
      await Pizza.update(input, { where: { piz_id: id } });
      return Pizza.findByPk(id);
    },
    eliminarPizza: async (_, { id }, context) => {
      if (!context.user) throw new Error('No autenticado');
      const pizza = await Pizza.findByPk(id);
      await pizza.destroy();
      return true;
    },
  },
};
