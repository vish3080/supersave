import 'package:flutter/material.dart' hide Category;
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../providers/finance_provider.dart';
import '../../models/models.dart';
import '../../widgets/common_widgets.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final fp = context.watch<FinanceProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Add Income',
            onPressed: () => _showAddIncomeSheet(context, fp),
          ),
        ],
      ),
      body: fp.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => fp.reload(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _MonthNavigator(fp: fp),
                  const SizedBox(height: 12),
                  _SummarySection(fp: fp),
                  const SizedBox(height: 12),
                  if (fp.categorySpending.isNotEmpty) ...[
                    _SpendingChart(fp: fp),
                    const SizedBox(height: 12),
                  ],
                  if (fp.categories.any((c) => c.budgetLimit != null)) ...[
                    _BudgetCard(fp: fp),
                    const SizedBox(height: 12),
                  ],
                  if (fp.savingsGoals.any((g) => !g.isCompleted)) ...[
                    _SavingsSnapshot(fp: fp),
                  ],
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  void _showAddIncomeSheet(BuildContext context, FinanceProvider fp) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _AddIncomeSheet(fp: fp),
    );
  }
}

// ── Month Navigator ───────────────────────────────────────────────────────────
class _MonthNavigator extends StatelessWidget {
  final FinanceProvider fp;
  const _MonthNavigator({required this.fp});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: fp.previousMonth,
            ),
            Expanded(
              child: Text(
                formatMonthYear(fp.selectedMonthDate),
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: fp.nextMonth,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Summary Section ───────────────────────────────────────────────────────────
class _SummarySection extends StatelessWidget {
  final FinanceProvider fp;
  const _SummarySection({required this.fp});

  @override
  Widget build(BuildContext context) {
    final savings = fp.savings;
    final rate = fp.savingsRate;
    final rateColor = rate >= 0.2
        ? Colors.green
        : rate >= 0.1
            ? Colors.orange
            : Colors.red;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: SummaryCard(
                title: 'Income',
                value: formatCurrency(fp.totalIncome),
                icon: Icons.arrow_downward_rounded,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SummaryCard(
                title: 'Expenses',
                value: formatCurrency(fp.totalExpenses),
                icon: Icons.arrow_upward_rounded,
                color: Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.savings_rounded, color: Colors.blue),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Saved this month',
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text(
                      formatCurrency(savings),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: savings >= 0 ? null : Colors.red,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Savings Rate',
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text(
                      formatPercent(rate),
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: rateColor),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Spending Pie Chart ────────────────────────────────────────────────────────
class _SpendingChart extends StatefulWidget {
  final FinanceProvider fp;
  const _SpendingChart({required this.fp});

  @override
  State<_SpendingChart> createState() => _SpendingChartState();
}

class _SpendingChartState extends State<_SpendingChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final spending = widget.fp.categorySpending;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Spending Breakdown',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (event, response) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            response == null ||
                            response.touchedSection == null) {
                          _touchedIndex = -1;
                          return;
                        }
                        _touchedIndex =
                            response.touchedSection!.touchedSectionIndex;
                      });
                    },
                  ),
                  sections: spending.asMap().entries.map((entry) {
                    final i = entry.key;
                    final s = entry.value;
                    final isTouched = i == _touchedIndex;
                    return PieChartSectionData(
                      value: s.total,
                      color: s.category.color,
                      radius: isTouched ? 90 : 75,
                      title: isTouched ? formatCurrency(s.total) : '',
                      titleStyle: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    );
                  }).toList(),
                  centerSpaceRadius: 48,
                  sectionsSpace: 2,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Legend
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: spending.map((s) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: s.category.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(s.category.name,
                        style: const TextStyle(fontSize: 12)),
                    const SizedBox(width: 4),
                    Text(formatPercent(s.percentage),
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Budget Card ───────────────────────────────────────────────────────────────
class _BudgetCard extends StatelessWidget {
  final FinanceProvider fp;
  const _BudgetCard({required this.fp});

  @override
  Widget build(BuildContext context) {
    final withBudget = fp.categories.where((c) => c.budgetLimit != null).toList();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Budget Status',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            ...withBudget.map((cat) => BudgetProgressRow(
                  category: cat,
                  used: fp.budgetUsed(cat),
                  limit: cat.budgetLimit,
                  progress: fp.budgetProgress(cat),
                  isOver: fp.isOverBudget(cat),
                )),
          ],
        ),
      ),
    );
  }
}

// ── Savings Snapshot ──────────────────────────────────────────────────────────
class _SavingsSnapshot extends StatelessWidget {
  final FinanceProvider fp;
  const _SavingsSnapshot({required this.fp});

  @override
  Widget build(BuildContext context) {
    final active = fp.savingsGoals.where((g) => !g.isCompleted).take(3).toList();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Savings Goals',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            ...active.map((goal) => _GoalRow(goal: goal)),
          ],
        ),
      ),
    );
  }
}

class _GoalRow extends StatelessWidget {
  final SavingsGoal goal;
  const _GoalRow({required this.goal});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(goal.name,
                    style: const TextStyle(fontWeight: FontWeight.w500)),
              ),
              Text(formatPercent(goal.progress),
                  style: const TextStyle(
                      color: Colors.blue, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: goal.progress,
              minHeight: 6,
              backgroundColor: Colors.blue.withOpacity(0.15),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text('${formatCurrency(goal.currentAmount)} saved',
                  style:
                      const TextStyle(fontSize: 11, color: Colors.grey)),
              const Spacer(),
              Text('${formatCurrency(goal.remaining)} to go',
                  style:
                      const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Add Income Sheet ──────────────────────────────────────────────────────────
class _AddIncomeSheet extends StatefulWidget {
  final FinanceProvider fp;
  const _AddIncomeSheet({required this.fp});

  @override
  State<_AddIncomeSheet> createState() => _AddIncomeSheetState();
}

class _AddIncomeSheetState extends State<_AddIncomeSheet> {
  final _amountCtrl = TextEditingController();
  String _source = 'Salary';
  final _sources = ['Salary', 'Freelance', 'Business', 'Investment', 'Gift', 'Other'];

  @override
  void dispose() {
    _amountCtrl.dispose();
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
          Text('Add Income',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(
            controller: _amountCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Amount',
              prefixText: '\$ ',
            ),
            autofocus: true,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _source,
            decoration: const InputDecoration(labelText: 'Source'),
            items: _sources
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: (v) => setState(() => _source = v!),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () async {
                final amount = double.tryParse(_amountCtrl.text);
                if (amount == null || amount <= 0) return;
                await widget.fp.addIncome(amount, _source);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ),
        ],
      ),
    );
  }
}

