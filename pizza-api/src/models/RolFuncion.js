const { DataTypes } = require('sequelize');

module.exports = (sequelize) => {
  const RolFuncion = sequelize.define('RolFuncion', {
    rol_id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
    },
    fun_id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
    },
  }, {
    tableName: 'rol_funciones',
    timestamps: false,
  });

  return RolFuncion;
};
