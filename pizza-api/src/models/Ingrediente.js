const { DataTypes } = require('sequelize');

module.exports = (sequelize) => {
  const Ingrediente = sequelize.define('Ingrediente', {
    ing_id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    ing_name: {
      type: DataTypes.TEXT,
      allowNull: false,
    },
    ing_calories: {
      type: DataTypes.DOUBLE,
      allowNull: false,
    },
    ing_state: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
    },
  }, {
    tableName: 'Ingredients',
    timestamps: false,
  });

  return Ingrediente;
};
