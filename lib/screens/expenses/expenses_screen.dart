import 'package:flutter/material.dart' hide Category;
import 'package:provider/provider.dart';
import '../../providers/finance_provider.dart';
import '../../models/models.dart';
import '../../widgets/common_widgets.dart';
import 'add_expense_screen.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final fp = context.watch<FinanceProvider>();
    final filtered = fp.expenses
        .where((e) =>
            _search.isEmpty ||
            e.note.toLowerCase().contains(_search.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: SearchBar(
              hintText: 'Search expenses…',
              leading: const Icon(Icons.search),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),
        ),
      ),
      body: fp.expenses.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.receipt_long_outlined,
                      size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('No expenses yet',
                      style: TextStyle(color: Colors.grey, fontSize: 16)),
                  SizedBox(height: 4),
                  Text('Tap + to add your first expense.',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
              itemBuilder: (context, i) {
                final expense = filtered[i];
                return Dismissible(
                  key: Key(expense.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: Colors.red,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (_) async {
                    return await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Delete Expense'),
                        content: const Text('Are you sure?'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Cancel')),
                          FilledButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Delete')),
                        ],
                      ),
                    );
                  },
                  onDismissed: (_) => fp.deleteExpense(expense),
                  child: _ExpenseTile(expense: expense, fp: fp),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _ExpenseTile extends StatelessWidget {
  final Expense expense;
  final FinanceProvider fp;

  const _ExpenseTile({required this.expense, required this.fp});

  @override
  Widget build(BuildContext context) {
    final cat = fp.categories.firstWhere(
      (c) => c.id == expense.categoryId,
      orElse: () => Category(
        id: '',
        userId: '',
        name: 'Unknown',
        colorHex: 'B0B0B0',
        iconKey: 'More',
        createdAt: DateTime.now(),
      ),
    );

    return ListTile(
      leading: categoryIconWidget(cat),
      title: Text(
        expense.note.isEmpty ? cat.name : expense.note,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Row(
        children: [
          Text(cat.name,
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
          if (expense.isRecurring) ...[
            const SizedBox(width: 6),
            const Icon(Icons.repeat, size: 12, color: Colors.blue),
            const SizedBox(width: 2),
            Text(expense.recurringInterval?.label ?? 'Recurring',
                style: const TextStyle(fontSize: 11, color: Colors.blue)),
          ],
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(formatCurrency(expense.amount),
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          Text(
            '${expense.date.day}/${expense.date.month}/${expense.date.year}',
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
