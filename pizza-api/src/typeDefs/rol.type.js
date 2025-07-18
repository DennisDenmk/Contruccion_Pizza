const { gql } = require('apollo-server-express');

module.exports = gql`
  input RolInput {
    rol_name: String!
    rol_description: String!
    rol_state: Boolean!
  }

  type Rol {
    rol_id: ID!
    rol_name: String!
    rol_description: String!
    rol_state: Boolean!
    funciones: [Funcion]
  }

  type Query {
    roles: [Rol]
    rol(id: ID!): Rol
  }

  type Mutation {
    crearRol(input: RolInput!): Rol
    actualizarRol(id: ID!, input: RolInput!): Rol
    eliminarRol(id: ID!): Boolean
    asignarFuncionARol(rol_id: ID!, fun_id: ID!): Boolean
    eliminarFuncionDeRol(rol_id: ID!, fun_id: ID!): Boolean
  }
`;
