const { gql } = require('apollo-server-express');

module.exports = gql`
  input PizzaIngredienteInput {
    piz_id: ID!
    ing_id: ID!
    piz_ing_quantified: Float!
  }

  type PizzaIngrediente {
    piz_id: ID!
    ing_id: ID!
    piz_ing_quantified: Float!
  }

  type Query {
    pizzaIngredientes: [PizzaIngrediente]
    pizzaIngrediente(piz_id: ID!, ing_id: ID!): PizzaIngrediente
  }

  type Mutation {
    crearPizzaIngrediente(input: PizzaIngredienteInput!): PizzaIngrediente
    actualizarPizzaIngrediente(piz_id: ID!, ing_id: ID!, input: PizzaIngredienteInput!): PizzaIngrediente
    eliminarPizzaIngrediente(piz_id: ID!, ing_id: ID!): Boolean
  }
`;
