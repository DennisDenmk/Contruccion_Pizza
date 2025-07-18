const { DataTypes } = require('sequelize');

module.exports = (sequelize) => {
  const Rol = sequelize.define('Rol', {
    rol_id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    rol_name: {
      type: DataTypes.TEXT,
      allowNull: false,
    },
    rol_description: {
      type: DataTypes.TEXT,
      allowNull: false,
    },
    rol_state: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
    },
  }, {
    tableName: 'roles',
    timestamps: false,
  });

  return Rol;
};
