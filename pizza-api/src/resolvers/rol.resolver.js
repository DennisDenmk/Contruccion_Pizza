const { Rol, Funcion, RolFuncion } = require('../models');

module.exports = {
  Query: {
    roles: (_, __, context) => {
      if (!context.user) throw new Error('No autenticado');
      return Rol.findAll();
    },
    rol: (_, { id }, context) => {
      if (!context.user) throw new Error('No autenticado');
      return Rol.findByPk(id);
    },
  },
  
  Rol: {
    funciones: async (rol) => {
      // Obtener los IDs de funciones del rol
      const rolFunciones = await RolFuncion.findAll({
        where: { rol_id: rol.rol_id }
      });
      
      const funIds = rolFunciones.map(rf => rf.fun_id);
      
      // Obtener las funciones completas
      return Funcion.findAll({
        where: { fun_id: funIds }
      });
    },
  },
  Mutation: {
    crearRol: (_, { input }, context) => {
      if (!context.user) throw new Error('No autenticado');
      return Rol.create(input);
    },
    actualizarRol: async (_, { id, input }, context) => {
      if (!context.user) throw new Error('No autenticado');
      await Rol.update(input, { where: { rol_id: id } });
      return Rol.findByPk(id);
    },
    eliminarRol: async (_, { id }, context) => {
      if (!context.user) throw new Error('No autenticado');
      const rol = await Rol.findByPk(id);
      await rol.destroy();
      return true;
    },
    asignarFuncionARol: async (_, { rol_id, fun_id }, context) => {
      if (!context.user) throw new Error('No autenticado');
      try {
        await RolFuncion.create({ rol_id, fun_id });
        return true;
      } catch (error) {
        console.error('Error al asignar función a rol:', error);
        return false;
      }
    },
    eliminarFuncionDeRol: async (_, { rol_id, fun_id }, context) => {
      if (!context.user) throw new Error('No autenticado');
      try {
        const result = await RolFuncion.destroy({ 
          where: { rol_id, fun_id } 
        });
        return result > 0;
      } catch (error) {
        console.error('Error al eliminar función de rol:', error);
        return false;
      }
    },
  },
};
