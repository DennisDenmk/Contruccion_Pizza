import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../providers/auth_provider.dart';
import '../providers/permission_provider.dart';
import '../widgets/animated_pizza_background.dart';
import '../widgets/pizza_loading.dart';
import 'home_screen.dart';
import '../graphql/queries.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPizzaBackground(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pizza App - Login'),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.local_pizza,
                          size: 80,
                          color: Color(0xFFD32F2F),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Bienvenido a Pizza App',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _usernameController,
                          decoration: const InputDecoration(
                            labelText: 'Usuario',
                            prefixIcon: Icon(Icons.person),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingrese su nombre de usuario';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          decoration: const InputDecoration(
                            labelText: 'Contraseña',
                            prefixIcon: Icon(Icons.lock),
                            border: OutlineInputBorder(),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingrese su contraseña';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        Mutation(
                          options: MutationOptions(
                            document: gql(AuthQueries.login),
                            onCompleted: (dynamic resultData) async {
                              if (resultData != null && resultData['login'] != null) {
                                final token = resultData['login'];
                                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                                // Extraer el ID del usuario del token (JWT)
                                final jwt = token.split('.');
                                if (jwt.length == 3) {
                                  try {
                                    final payload = utf8.decode(base64Url.decode(
                                      base64Url.normalize(jwt[1])
                                    ));
                                    final payloadMap = json.decode(payload);
                                    final userId = payloadMap['id'];
                                    print('DEBUG: ID extraído del token: $userId');
                                    await authProvider.setToken(token, userId: userId);
                                    
                                    // Navegar a la pantalla principal después de iniciar sesión
                                    if (mounted) {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(builder: (context) => const HomeScreen()),
                                      );
                                    }
                                  } catch (e) {
                                    print('Error al decodificar token: $e');
                                    await authProvider.setToken(token, userId: 1);
                                    if (mounted) {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(builder: (context) => const HomeScreen()),
                                      );
                                    }
                                  }
                                } else {
                                  await authProvider.setToken(token, userId: 1);
                                  if (mounted) {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(builder: (context) => const HomeScreen()),
                                    );
                                  }
                                }
                                
                                // Cargar las funciones del usuario
                                final permissionProvider = Provider.of<PermissionProvider>(context, listen: false);
                                
                                // Cargar las funciones del usuario desde el backend
                                if (mounted) {
                                  final client = GraphQLProvider.of(context).value;
                                  await permissionProvider.loadUserFunctions(client, authProvider.userId!);
                                }
                              }
                              if (mounted) {
                                setState(() => _isLoading = false);
                              }
                            },
                            onError: (error) {
                              if (mounted) {
                                _showError(error?.graphqlErrors.first.message ?? 'Error de autenticación');
                                setState(() => _isLoading = false);
                              }
                            },
                          ),
                          builder: (RunMutation runMutation, QueryResult? result) {
                            return ElevatedButton(
                              onPressed: _isLoading
                                  ? null
                                  : () {
                                      if (_formKey.currentState!.validate()) {
                                        setState(() => _isLoading = true);
                                        runMutation({
                                          'nombre': _usernameController.text,
                                          'contrasenia': _passwordController.text,
                                        });
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 50),
                              ),
                              child: _isLoading
                                  ? const PizzaLoading(size: 30, color: Colors.white)
                                  : const Text('Iniciar Sesión'),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}