const { DataTypes } = require('sequelize');

module.exports = (sequelize) => {
  const Pizza = sequelize.define('Pizza', {
    piz_id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    piz_name: {
      type: DataTypes.TEXT,
      allowNull: false,
    },
    piz_origin: {
      type: DataTypes.TEXT,
      allowNull: false,
    },
    piz_state: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
    },
  }, {
    tableName: 'pizza',
    timestamps: false,
  });

  return Pizza;
};
