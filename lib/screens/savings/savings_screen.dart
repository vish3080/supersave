import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/finance_provider.dart';
import '../../models/models.dart';
import '../../widgets/common_widgets.dart';

class SavingsScreen extends StatelessWidget {
  const SavingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final fp = context.watch<FinanceProvider>();
    final active = fp.savingsGoals.where((g) => !g.isCompleted).toList();
    final completed = fp.savingsGoals.where((g) => g.isCompleted).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Savings Goals')),
      body: fp.savingsGoals.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.savings_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('No savings goals yet',
                      style: TextStyle(color: Colors.grey, fontSize: 16)),
                  SizedBox(height: 4),
                  Text('Tap + to create your first goal.',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (active.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 8),
                    child: Text('Active',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.grey)),
                  ),
                  ...active.map((g) => _GoalCard(goal: g, fp: fp)),
                ],
                if (completed.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 8),
                    child: Text('Completed',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.grey)),
                  ),
                  ...completed.map((g) => _CompletedGoalCard(goal: g, fp: fp)),
                ],
                const SizedBox(height: 80),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddGoalSheet(context, fp),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddGoalSheet(BuildContext context, FinanceProvider fp) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _AddGoalSheet(fp: fp),
    );
  }
}

// ── Goal Card ─────────────────────────────────────────────────────────────────
class _GoalCard extends StatefulWidget {
  final SavingsGoal goal;
  final FinanceProvider fp;
  const _GoalCard({required this.goal, required this.fp});

  @override
  State<_GoalCard> createState() => _GoalCardState();
}

class _GoalCardState extends State<_GoalCard> {
  bool _showDeposit = false;
  final _depositCtrl = TextEditingController();

  @override
  void dispose() {
    _depositCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final goal = widget.goal;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(goal.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      if (goal.deadline != null)
                        Text(
                          'Due: ${goal.deadline!.day}/${goal.deadline!.month}/${goal.deadline!.year}',
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                    ],
                  ),
                ),
                Text(
                  formatPercent(goal.progress),
                  style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.grey),
                  onPressed: () => widget.fp.deleteSavingsGoal(goal),
                  iconSize: 20,
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: goal.progress,
                minHeight: 10,
                backgroundColor: Colors.blue.withOpacity(0.15),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Text('${formatCurrency(goal.currentAmount)} saved',
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const Spacer(),
                Text('${formatCurrency(goal.remaining)} to go',
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 10),
            if (_showDeposit)
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _depositCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        hintText: 'Amount',
                        prefixText: '\$ ',
                        isDense: true,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      ),
                      autofocus: true,
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () async {
                      final amount = double.tryParse(_depositCtrl.text);
                      if (amount != null && amount > 0) {
                        await widget.fp.depositToGoal(goal, amount);
                        _depositCtrl.clear();
                        setState(() => _showDeposit = false);
                      }
                    },
                    child: const Text('Add'),
                  ),
                  TextButton(
                    onPressed: () => setState(() {
                      _showDeposit = false;
                      _depositCtrl.clear();
                    }),
                    child: const Text('Cancel'),
                  ),
                ],
              )
            else
              OutlinedButton.icon(
                onPressed: () => setState(() => _showDeposit = true),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Money'),
              ),
          ],
        ),
      ),
    );
  }
}

class _CompletedGoalCard extends StatelessWidget {
  final SavingsGoal goal;
  final FinanceProvider fp;
  const _CompletedGoalCard({required this.goal, required this.fp});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.green,
          child: Icon(Icons.check, color: Colors.white),
        ),
        title: Text(goal.name,
            style: const TextStyle(decoration: TextDecoration.lineThrough)),
        subtitle: Text('Goal reached: ${formatCurrency(goal.targetAmount)}'),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.grey),
          onPressed: () => fp.deleteSavingsGoal(goal),
        ),
      ),
    );
  }
}

// ── Add Goal Sheet ────────────────────────────────────────────────────────────
class _AddGoalSheet extends StatefulWidget {
  final FinanceProvider fp;
  const _AddGoalSheet({required this.fp});

  @override
  State<_AddGoalSheet> createState() => _AddGoalSheetState();
}

class _AddGoalSheetState extends State<_AddGoalSheet> {
  final _nameCtrl = TextEditingController();
  final _targetCtrl = TextEditingController();
  bool _hasDeadline = false;
  DateTime _deadline = DateTime.now().add(const Duration(days: 180));

  @override
  void dispose() {
    _nameCtrl.dispose();
    _targetCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('New Savings Goal',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(
                labelText: 'Goal Name',
                hintText: 'e.g. Emergency Fund, Vacation'),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _targetCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Target Amount',
              prefixText: '\$ ',
            ),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Set a deadline'),
            value: _hasDeadline,
            onChanged: (v) => setState(() => _hasDeadline = v),
          ),
          if (_hasDeadline)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Target Date'),
              trailing: Text(
                '${_deadline.day}/${_deadline.month}/${_deadline.year}',
                style: const TextStyle(color: Colors.blue),
              ),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _deadline,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 3650)),
                );
                if (picked != null) setState(() => _deadline = picked);
              },
            ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _nameCtrl.text.trim().isEmpty ||
                      double.tryParse(_targetCtrl.text) == null
                  ? null
                  : () async {
                      await widget.fp.addSavingsGoal(
                        name: _nameCtrl.text.trim(),
                        targetAmount: double.parse(_targetCtrl.text),
                        deadline: _hasDeadline ? _deadline : null,
                      );
                      if (context.mounted) Navigator.pop(context);
                    },
              child: const Text('Create Goal'),
            ),
          ),
        ],
      ),
    );
  }
}
