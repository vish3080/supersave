import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/finance_provider.dart';
import 'providers/wealth_provider.dart';
import 'providers/bills_provider.dart';
import 'providers/subscription_provider.dart';
import 'providers/premium_provider.dart';
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
        ChangeNotifierProvider(create: (_) => WealthProvider()),
        ChangeNotifierProvider(create: (_) => BillsProvider()),
        ChangeNotifierProvider(create: (_) => SubscriptionProvider()),
        ChangeNotifierProvider(create: (_) => PremiumProvider()),
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

    if (!auth.isAuthenticated) {
      return const AuthScreen();
    }

    // Load all data once authenticated
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = auth.userId!;
      context.read<FinanceProvider>().loadAll(uid);
      context.read<WealthProvider>().loadAll(uid);
      context.read<BillsProvider>().loadAll(uid);
      context.read<SubscriptionProvider>().loadAll(uid);
      context.read<PremiumProvider>().checkPremium();
    });

    return const HomeScreen();
  }
}
