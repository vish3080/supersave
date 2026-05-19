import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/finance_provider.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/home/home_screen.dart';

class SuperSaveApp extends StatelessWidget {
  const SuperSaveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => FinanceProvider()),
      ],
      child: MaterialApp(
        title: 'SuperSave',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        home: const _RootRouter(),
      ),
    );
  }
}

class _RootRouter extends StatelessWidget {
  const _RootRouter();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final fp = context.read<FinanceProvider>();

    if (!auth.isAuthenticated) {
      return const AuthScreen();
    }

    // Load finance data once authenticated
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (auth.userId != null) {
        fp.loadAll(auth.userId!);
      }
    });

    return const HomeScreen();
  }
}
