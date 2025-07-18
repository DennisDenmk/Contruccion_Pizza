import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../providers/auth_provider.dart';
import '../providers/permission_provider.dart';

import 'pizza_list_screen.dart';
import 'ingredient_list_screen.dart';
import 'rol_list_screen.dart';
import 'funcion_list_screen.dart';
import 'usuario_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _initialized = false;
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) return;
    _initialized = true;

    _loadUserFunctions();
  }

  Future<void> _loadUserFunctions() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final permissionProvider = Provider.of<PermissionProvider>(context, listen: false);
    final client = GraphQLProvider.of(context).value;

    if (authProvider.userId != null) {
      await permissionProvider.loadUserFunctions(client, authProvider.userId!);
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final permissionProvider = Provider.of<PermissionProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pizza App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authProvider.logout();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: permissionProvider.userFunctionIds.isEmpty
                  ? const Center(
                      child: Text(
                        'No tienes permisos asignados. Contacta al administrador.',
                        style: TextStyle(fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 20),
                          if (permissionProvider.hasFunction(PermissionProvider.PIZZAS))
                            _buildMenuCard(
                              'Gestión de Pizzas',
                              Icons.local_pizza,
                              Colors.red.shade700,
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const PizzaListScreen()),
                              ),
                            ),
                          if (permissionProvider.hasFunction(PermissionProvider.INGREDIENTES))
                            _buildMenuCard(
                              'Gestión de Ingredientes',
                              Icons.restaurant,
                              Colors.green.shade700,
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const IngredientListScreen()),
                              ),
                            ),
                          if (permissionProvider.hasFunction(PermissionProvider.USUARIOS))
                            _buildMenuCard(
                              'Gestión de Usuarios',
                              Icons.people,
                              Colors.blue.shade700,
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const UsuarioListScreen()),
                              ),
                            ),
                          if (permissionProvider.hasFunction(PermissionProvider.ROLES))
                            _buildMenuCard(
                              'Gestión de Roles',
                              Icons.admin_panel_settings,
                              Colors.purple.shade700,
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const RolListScreen()),
                              ),
                            ),
                          if (permissionProvider.hasFunction(PermissionProvider.FUNCIONES))
                            _buildMenuCard(
                              'Gestión de Funciones',
                              Icons.functions,
                              Colors.orange.shade700,
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const FuncionListScreen()),
                              ),
                            ),
                        ].expand((widget) => [widget, const SizedBox(height: 16)]).toList(),
                      ),
                    ),
            ),
    );
  }

  Widget _buildMenuCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Icon(icon, size: 60, color: color),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
