const { gql } = require('apollo-server-express');

module.exports = gql`
  input FuncionInput {
    fun_name: String!
    fun_description: String!
    fun_state: Boolean!
  }

  type Funcion {
    fun_id: ID!
    fun_name: String!
    fun_description: String!
    fun_state: Boolean!
  }

  type Query {
    funciones: [Funcion]
    funcion(id: ID!): Funcion
  }

  type Mutation {
    crearFuncion(input: FuncionInput!): Funcion
    actualizarFuncion(id: ID!, input: FuncionInput!): Funcion
    eliminarFuncion(id: ID!): Boolean
  }
`;
