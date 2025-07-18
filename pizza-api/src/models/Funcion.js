const { DataTypes } = require('sequelize');

module.exports = (sequelize) => {
  const Funcion = sequelize.define('Funcion', {
    fun_id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    fun_name: {
      type: DataTypes.TEXT,
      allowNull: false,
    },
    fun_description: {
      type: DataTypes.TEXT,
      allowNull: false,
    },
    fun_state: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
    },
  }, {
    tableName: 'funciones',
    timestamps: false,
  });

  return Funcion;
};
