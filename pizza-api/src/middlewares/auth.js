const jwt = require('jsonwebtoken');
const { Usuario } = require('../models');

const authenticateUser = async (req, res, next) => {
  const authHeader = req.headers.authorization || '';
  
  if (authHeader.startsWith('Bearer ')) {
    const token = authHeader.substring(7);
    
    try {
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      
      // Get user from database to ensure they still exist and are active
      const user = await Usuario.findOne({ 
        where: { 
          usu_id: decoded.id,
          usu_state: true 
        },
        attributes: ['usu_id', 'usu_name', 'usu_state']
      });
      
      if (user) {
        req.user = {
          id: user.usu_id,
          nombre: user.usu_name
        };
      }
    } catch (err) {
      console.warn('Token inválido:', err.message);
    }
  }

  next();
};

module.exports = { authenticateUser };
