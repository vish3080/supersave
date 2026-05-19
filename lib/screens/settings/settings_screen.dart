import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/finance_provider.dart';
import '../../widgets/common_widgets.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final fp = context.watch<FinanceProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const SizedBox(height: 12),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(Icons.person,
                  color: Theme.of(context).colorScheme.primary),
            ),
            title: const Text('Account'),
            subtitle: Text(
              'ID: ${(auth.userId ?? '—').substring(0, 8)}…',
              style: const TextStyle(fontSize: 12),
            ),
          ),
          const Divider(),
          _StatTile(
              icon: Icons.tag,
              label: 'Categories',
              value: '${fp.categories.length}'),
          _StatTile(
              icon: Icons.receipt_long,
              label: 'Expenses this month',
              value: '${fp.expenses.length}'),
          _StatTile(
              icon: Icons.savings,
              label: 'Savings Goals',
              value: '${fp.savingsGoals.length}'),
          _StatTile(
              icon: Icons.account_balance_wallet,
              label: 'Total saved this month',
              value: formatCurrency(fp.savings)),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Version'),
            trailing: const Text('1.0.0', style: TextStyle(color: Colors.grey)),
          ),
          ListTile(
            leading: const Icon(Icons.cloud_outlined),
            title: const Text('Backend'),
            trailing:
                const Text('Supabase', style: TextStyle(color: Colors.grey)),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Sign Out', style: TextStyle(color: Colors.red)),
            onTap: () => showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Sign Out?'),
                content: const Text('You will need to sign in again.'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel')),
                  FilledButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      auth.signOut();
                    },
                    style: FilledButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('Sign Out'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatTile(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(label),
      trailing: Text(value,
          style:
              const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
    );
  }
}
