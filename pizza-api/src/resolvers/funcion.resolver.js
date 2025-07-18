const { Funcion } = require('../models');

module.exports = {
  Query: {
    funciones: (_, __, context) => {
      if (!context.user) throw new Error('No autenticado');
      return Funcion.findAll();
    },
    funcion: (_, { id }, context) => {
      if (!context.user) throw new Error('No autenticado');
      return Funcion.findByPk(id);
    },
  },
  Mutation: {
    crearFuncion: (_, { input }, context) => {
      if (!context.user) throw new Error('No autenticado');
      return Funcion.create(input);
    },
    actualizarFuncion: async (_, { id, input }, context) => {
      if (!context.user) throw new Error('No autenticado');
      await Funcion.update(input, { where: { fun_id: id } });
      return Funcion.findByPk(id);
    },
    eliminarFuncion: async (_, { id }, context) => {
      if (!context.user) throw new Error('No autenticado');
      const funcion = await Funcion.findByPk(id);
      await funcion.destroy();
      return true;
    },
  },
};
