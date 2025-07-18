require('dotenv').config();
const express = require('express');
const { ApolloServer } = require('apollo-server-express');
const cors = require('cors');

const sequelize = require('./db');
const typeDefs = require('./typeDefs');
const resolvers = require('./resolvers');
const { authenticateUser } = require('./middlewares/auth');

const app = express();

app.use(cors());
app.use(authenticateUser); // JWT auth middleware

async function startServer() {
  try {
    const server = new ApolloServer({
      typeDefs,
      resolvers,
      context: ({ req }) => ({
        user: req.user || null,
      }),
      formatError: (error) => {
        console.log(error);
        return {
          message: error.message,
          path: error.path,
        };
      },
    });

    await server.start();

    // Este middleware debe ir después de que Apollo está listo
    server.applyMiddleware({ app });

    await sequelize.sync();

    const port = process.env.PORT || 4000;
    app.listen(port, () => {
      console.log(`Servidor corriendo en http://localhost:${port}${server.graphqlPath}`);
    });
  } catch (error) {
    console.error('Error al iniciar el servidor:', error);
  }
}

startServer();
