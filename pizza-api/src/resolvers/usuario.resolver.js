const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { Usuario, Rol, UsuarioRol } = require('../models');
const JWT_SECRET = process.env.JWT_SECRET;

module.exports = {
  Query: {
    usuarios: (_, __, context) => {
      if (!context.user) throw new Error('No autenticado');
      return Usuario.findAll();
    },
    usuario: (_, { id }, context) => {
      if (!context.user) throw new Error('No autenticado');
      return Usuario.findByPk(id);
    },
    usuarioRoles: async (_, { userId }, context) => {
      if (!context.user) throw new Error('No autenticado');
      
      // Obtener los IDs de roles del usuario
      const usuarioRoles = await UsuarioRol.findAll({
        where: { usu_id: userId }
      });
      
      const rolIds = usuarioRoles.map(ur => ur.rol_id);
      
      // Obtener los roles completos
      return Rol.findAll({
        where: { rol_id: rolIds }
      });
    },
  },
  Mutation: {
    crearUsuario: (_, { input }, context) => {
      if (!context.user) throw new Error('No autenticado');
      return Usuario.create(input);
    },
    actualizarUsuario: async (_, { id, input }, context) => {
      if (!context.user) throw new Error('No autenticado');
      await Usuario.update(input, { where: { usu_id: id } });
      return Usuario.findByPk(id);
    },
    eliminarUsuario: async (_, { id }, context) => {
      if (!context.user) throw new Error('No autenticado');
      const usuario = await Usuario.findByPk(id);
      await usuario.destroy();
      return true;
    },
    login: async (_, { nombre, contrasenia }) => {
      const user = await Usuario.findOne({ where: { usu_name: nombre, usu_state: true } });
      if (!user) throw new Error('Usuario no encontrado o inactivo');

      const valid = await bcrypt.compare(contrasenia, user.usu_pass);
      if (!valid) throw new Error('Contraseña incorrecta');

      return jwt.sign({ id: user.usu_id, nombre: user.usu_name }, JWT_SECRET, { expiresIn: '4h' });
    },
    register: async (_, { input }) => {
      const hashedPassword = await bcrypt.hash(input.contrasenia, 10);
      const newUser = await Usuario.create({ 
        usu_name: input.nombre, 
        usu_pass: hashedPassword, 
        usu_state: input.estado || true 
      });
      return newUser;
    },
    asignarRolAUsuario: async (_, { usu_id, rol_id }, context) => {
      if (!context.user) throw new Error('No autenticado');
      try {
        await UsuarioRol.create({ usu_id, rol_id });
        return true;
      } catch (error) {
        console.error('Error al asignar rol a usuario:', error);
        return false;
      }
    },
    eliminarRolDeUsuario: async (_, { usu_id, rol_id }, context) => {
      if (!context.user) throw new Error('No autenticado');
      try {
        const result = await UsuarioRol.destroy({ 
          where: { usu_id, rol_id } 
        });
        return result > 0;
      } catch (error) {
        console.error('Error al eliminar rol de usuario:', error);
        return false;
      }
    },
  },
};
