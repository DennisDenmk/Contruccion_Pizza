const { Pizza, Ingredient, PizzaIngrediente } = require('../models');

module.exports = {
  Query: {
    pizzas: (_, __, context) => {
      if (!context.user) throw new Error('No autenticado');
      return Pizza.findAll({ include: Ingredient });
    },
    pizza: (_, { id }, context) => {
      if (!context.user) throw new Error('No autenticado');
      return Pizza.findByPk(id, { include: Ingredient });
    },
    ingredients: (_, __, context) => {
      if (!context.user) throw new Error('No autenticado');
      return Ingredient.findAll();
    },
  },
  Pizza: {
    ingredients: (pizza) => {
      return PizzaIngrediente.findAll({ where: { piz_id: pizza.piz_id }, include: Ingredient });
    },
  },
  PizzaIngredient: {
    ingredient: (pizzaIngredient) => {
      return Ingredient.findByPk(pizzaIngredient.ing_id);
    },
  },
  Mutation: {
    crearPizza: (_, { input }, context) => {
      if (!context.user) throw new Error('No autenticado');
      return Pizza.create(input);
    },
    actualizarPizza: async (_, { id, input }, context) => {
      if (!context.user) throw new Error('No autenticado');
      await Pizza.update(input, { where: { piz_id: id } });
      return Pizza.findByPk(id);
    },
    eliminarPizza: async (_, { id }, context) => {
      if (!context.user) throw new Error('No autenticado');
      const pizza = await Pizza.findByPk(id);
      await pizza.destroy();
      return true;
    },
    createPizzaWithIngredients: async (_, { piz_name, piz_origin, piz_state, ingredients }, context) => {
      if (!context.user) throw new Error('No autenticado');
      const transaction = await Pizza.sequelize.transaction();
      try {
        const pizza = await Pizza.create(
          { piz_name, piz_origin, piz_state },
          { transaction }
        );
        if (ingredients && ingredients.length > 0) {
          const ingredientRelations = ingredients.map(ing => ({
            piz_id: pizza.piz_id,
            ing_id: ing.ing_id,
            piz_ing_quantified: ing.piz_ing_quantified,
          }));
          await PizzaIngrediente.bulkCreate(ingredientRelations, { transaction });
        }
        await transaction.commit();
        return Pizza.findByPk(pizza.piz_id, { include: Ingredient });
      } catch (error) {
        await transaction.rollback();
        throw new Error('Error al crear la pizza y sus ingredientes');
      }
    },
    updatePizzaWithIngredients: async (_, { piz_id, piz_name, piz_origin, piz_state, ingredients }, context) => {
      if (!context.user) throw new Error('No autenticado');
      const transaction = await Pizza.sequelize.transaction();
      try {
        await Pizza.update(
          { piz_name, piz_origin, piz_state },
          { where: { piz_id }, transaction }
        );
        await PizzaIngrediente.destroy({ where: { piz_id }, transaction });
        if (ingredients && ingredients.length > 0) {
          const ingredientRelations = ingredients.map(ing => ({
            piz_id,
            ing_id: ing.ing_id,
            piz_ing_quantified: ing.piz_ing_quantified,
          }));
          await PizzaIngrediente.bulkCreate(ingredientRelations, { transaction });
        }
        await transaction.commit();
        return Pizza.findByPk(piz_id, { include: Ingredient });
      } catch (error) {
        await transaction.rollback();
        throw new Error('Error al actualizar la pizza y sus ingredientes');
      }
    },
    deletePizzaWithRelations: async (_, { piz_id }, context) => {
      if (!context.user) throw new Error('No autenticado');
      const transaction = await Pizza.sequelize.transaction();
      try {
        await PizzaIngrediente.destroy({ where: { piz_id }, transaction });
        const pizza = await Pizza.findByPk(piz_id, { transaction });
        await pizza.destroy({ transaction });
        await transaction.commit();
        return true;
      } catch (error) {
        await transaction.rollback();
        throw new Error('Error al eliminar la pizza y sus relaciones');
      }
    },
  },
};