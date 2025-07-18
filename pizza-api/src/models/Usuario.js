const { DataTypes } = require('sequelize');

module.exports = (sequelize) => {
  const Usuario = sequelize.define('Usuario', {
    usu_id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    usu_name: {
      type: DataTypes.TEXT,
      allowNull: false,
    },
    usu_pass: {
      type: DataTypes.TEXT,
      allowNull: false,
    },
    usu_state: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
    },
  }, {
    tableName: 'usuarios',
    timestamps: false,
  });

  return Usuario;
};
