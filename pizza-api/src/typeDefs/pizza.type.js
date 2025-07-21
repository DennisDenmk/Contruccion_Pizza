const { gql } = require('apollo-server-express');

module.exports = gql`
  input PizzaInput {
    piz_name: String!
    piz_origin: String!
    piz_state: Boolean!
  }

  type Pizza {
    piz_id: ID!
    piz_name: String!
    piz_origin: String!
    piz_state: Boolean!
  }

  type Query {
    pizzas: [Pizza]
    pizza(id: ID!): Pizza
  }

  type Mutation {
    crearPizza(input: PizzaInput!): Pizza
    actualizarPizza(id: ID!, input: PizzaInput!): Pizza
    eliminarPizza(id: ID!): Boolean
  }
`;
