const { DataTypes } = require('sequelize');

module.exports = (sequelize) => {
  const UsuarioRol = sequelize.define('UsuarioRol', {
    usu_id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
    },
    rol_id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
    },
  }, {
    tableName: 'usuario_roles',
    timestamps: false,
  });

  return UsuarioRol;
};
