const { DataTypes } = require('sequelize');

module.exports = (sequelize) => {
  const PizzaIngrediente = sequelize.define('PizzaIngrediente', {
    piz_id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
    },
    ing_id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
    },
    piz_ing_quantified: {
      type: DataTypes.DOUBLE,
      allowNull: false,
    },
  }, {
    tableName: 'pizza_ingredients',
    timestamps: false,
  });

  return PizzaIngrediente;
};
