const { gql } = require('apollo-server-express');

module.exports = gql`
  input IngredienteInput {
    ing_name: String!
    ing_calories: Float!
    ing_state: Boolean!
  }

  type Ingrediente {
    ing_id: ID!
    ing_name: String!
    ing_calories: Float!
    ing_state: Boolean!
  }

  type Query {
    ingredientes: [Ingrediente]
    ingrediente(id: ID!): Ingrediente
  }

  type Mutation {
    crearIngrediente(input: IngredienteInput!): Ingrediente
    actualizarIngrediente(id: ID!, input: IngredienteInput!): Ingrediente
    eliminarIngrediente(id: ID!): Boolean
  }
`;
