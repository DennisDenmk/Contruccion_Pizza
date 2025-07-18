const Sequelize = require('sequelize');
const sequelize = require('../db');

const Usuario = require('./Usuario')(sequelize);
const Rol = require('./Rol')(sequelize);
const Funcion = require('./Funcion')(sequelize);
const UsuarioRol = require('./UsuarioRol')(sequelize);
const RolFuncion = require('./RolFuncion')(sequelize);
const Ingrediente = require('./Ingrediente')(sequelize);
const Pizza = require('./Pizza')(sequelize);
const PizzaIngrediente = require('./PizzaIngrediente')(sequelize);

// Relaciones

// Usuarios - Roles (muchos a muchos)
Usuario.belongsToMany(Rol, { through: UsuarioRol, foreignKey: 'usu_id', otherKey: 'rol_id' });
Rol.belongsToMany(Usuario, { through: UsuarioRol, foreignKey: 'rol_id', otherKey: 'usu_id' });

// Roles - Funciones (muchos a muchos)
Rol.belongsToMany(Funcion, { through: RolFuncion, foreignKey: 'rol_id', otherKey: 'fun_id' });
Funcion.belongsToMany(Rol, { through: RolFuncion, foreignKey: 'fun_id', otherKey: 'rol_id' });

// Pizzas - Ingredientes (muchos a muchos)
Pizza.belongsToMany(Ingrediente, { through: PizzaIngrediente, foreignKey: 'piz_id', otherKey: 'ing_id' });
Ingrediente.belongsToMany(Pizza, { through: PizzaIngrediente, foreignKey: 'ing_id', otherKey: 'piz_id' });

module.exports = {
  sequelize,
  Sequelize,
  Usuario,
  Rol,
  Funcion,
  UsuarioRol,
  RolFuncion,
  Ingrediente,
  Pizza,
  PizzaIngrediente,
};
