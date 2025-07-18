const { gql } = require('apollo-server-express');

module.exports = gql`
  input UsuarioInput {
    nombre: String!
    contrasenia: String!
    estado: Boolean
  }

  type Usuario {
    usu_id: ID!
    usu_name: String!
    usu_state: Boolean
  }

  type Query {
    usuarios: [Usuario]
    usuario(id: ID!): Usuario
    usuarioRoles(userId: ID!): [Rol]
  }

  type Mutation {
    crearUsuario(input: UsuarioInput!): Usuario
    actualizarUsuario(id: ID!, input: UsuarioInput!): Usuario
    eliminarUsuario(id: ID!): Boolean
    login(nombre: String!, contrasenia: String!): String
    register(input: UsuarioInput!): Usuario
    asignarRolAUsuario(usu_id: ID!, rol_id: ID!): Boolean
    eliminarRolDeUsuario(usu_id: ID!, rol_id: ID!): Boolean
  }
`;
