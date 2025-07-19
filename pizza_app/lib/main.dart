import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/permission_provider.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initHiveForFlutter();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PermissionProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    // Usar localhost para Windows en lugar de 10.0.2.2 (que es para emuladores Android)
    final HttpLink httpLink = HttpLink('http://localhost:4000/graphql');
    
    final AuthLink authLink = AuthLink(
      getToken: () => authProvider.token != null ? 'Bearer ${authProvider.token}' : null,
    );
    
    final Link link = authLink.concat(httpLink);
    
    ValueNotifier<GraphQLClient> client = ValueNotifier(
      GraphQLClient(
        link: link,
        cache: GraphQLCache(store: HiveStore()),
      ),
    );

    return GraphQLProvider(
      client: client,
      child: MaterialApp(
        title: 'Pizza App',
        theme: AppTheme.lightTheme,
        home: authProvider.isAuthenticated ? const HomeScreen() : const LoginScreen(),
      ),
    );
  }
}