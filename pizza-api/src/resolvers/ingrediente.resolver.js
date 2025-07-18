const { Ingrediente } = require('../models');

module.exports = {
  Query: {
    ingredientes: (_, __, context) => {
      if (!context.user) throw new Error('No autenticado');
      return Ingrediente.findAll();
    },
    ingrediente: (_, { id }, context) => {
      if (!context.user) throw new Error('No autenticado');
      return Ingrediente.findByPk(id);
    },
  },
  Mutation: {
    crearIngrediente: (_, { input }, context) => {
      if (!context.user) throw new Error('No autenticado');
      return Ingrediente.create(input);
    },
    actualizarIngrediente: async (_, { id, input }, context) => {
      if (!context.user) throw new Error('No autenticado');
      await Ingrediente.update(input, { where: { ing_id: id } });
      return Ingrediente.findByPk(id);
    },
    eliminarIngrediente: async (_, { id }, context) => {
      if (!context.user) throw new Error('No autenticado');
      const ingrediente = await Ingrediente.findByPk(id);
      await ingrediente.destroy();
      return true;
    },
  },
};
