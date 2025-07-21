const { gql } = require('apollo-server-express');

module.exports = gql`
  input PizzaInput {
    piz_name: String!
    piz_origin: String!
    piz_state: Boolean!
  }

  input PizzaIngredientInput {
    ing_id: Int!
    piz_ing_quantified: Float!
  }

  type Pizza {
    piz_id: ID!
    piz_name: String!
    piz_origin: String!
    piz_state: Boolean!
    ingredients: [PizzaIngredient]
  }

  type PizzaIngredient {
    ing_id: Int!
    piz_ing_quantified: Float!
    ingredient: Ingredient
  }

  type Ingredient {
    ing_id: Int!
    ing_name: String!
    ing_state: Boolean!
    ing_calories: Float!
  }

  type Query {
    pizzas: [Pizza]
    pizza(id: ID!): Pizza
    ingredients: [Ingredient]
  }

  type Mutation {
    crearPizza(input: PizzaInput!): Pizza
    actualizarPizza(id: ID!, input: PizzaInput!): Pizza
    eliminarPizza(id: ID!): Boolean
    createPizzaWithIngredients(piz_name: String!, piz_origin: String!, piz_state: Boolean!, ingredients: [PizzaIngredientInput!]!): Pizza!
    updatePizzaWithIngredients(piz_id: ID!, piz_name: String!, piz_origin: String!, piz_state: Boolean!, ingredients: [PizzaIngredientInput!]!): Pizza!
    deletePizzaWithRelations(piz_id: ID!): Boolean!
  }
`;