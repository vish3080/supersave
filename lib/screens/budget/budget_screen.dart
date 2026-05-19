import 'package:flutter/material.dart' hide Category;
import 'package:provider/provider.dart';
import '../../providers/finance_provider.dart';
import '../../models/models.dart';
import '../../widgets/common_widgets.dart';
import '../../core/constants.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final fp = context.watch<FinanceProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Budget')),
      body: fp.categories.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: fp.categories.length,
              separatorBuilder: (_, __) => const SizedBox(height: 0),
              itemBuilder: (context, i) {
                final cat = fp.categories[i];
                return _CategoryBudgetCard(cat: cat, fp: fp);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddCategorySheet(context, fp),
        icon: const Icon(Icons.add),
        label: const Text('Add Category'),
      ),
    );
  }

  void _showAddCategorySheet(BuildContext context, FinanceProvider fp) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _AddCategorySheet(fp: fp),
    );
  }
}

// ── Category Budget Card ──────────────────────────────────────────────────────
class _CategoryBudgetCard extends StatelessWidget {
  final Category cat;
  final FinanceProvider fp;

  const _CategoryBudgetCard({required this.cat, required this.fp});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showEditBudgetSheet(context),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Row(
                children: [
                  categoryIconWidget(cat),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(cat.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 15)),
                        Text(
                          cat.budgetLimit != null
                              ? '${formatCurrency(fp.budgetUsed(cat))} of ${formatCurrency(cat.budgetLimit!)} used'
                              : 'Tap to set budget limit',
                          style: TextStyle(
                            fontSize: 12,
                            color: fp.isOverBudget(cat)
                                ? Colors.red
                                : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (fp.isOverBudget(cat))
                    const Icon(Icons.warning_amber_rounded,
                        color: Colors.red, size: 20),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.grey),
                    iconSize: 20,
                    onPressed: () => _confirmDelete(context),
                  ),
                ],
              ),
              if (cat.budgetLimit != null) ...[
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: fp.budgetProgress(cat),
                    minHeight: 7,
                    backgroundColor: cat.color.withOpacity(0.15),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      fp.isOverBudget(cat)
                          ? Colors.red
                          : fp.budgetProgress(cat) > 0.8
                              ? Colors.orange
                              : cat.color,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showEditBudgetSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _EditBudgetSheet(cat: cat, fp: fp),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete "${cat.name}"?'),
        content: const Text(
            'This will also remove all expenses in this category.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              fp.deleteCategory(cat);
              Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ── Edit Budget Sheet ─────────────────────────────────────────────────────────
class _EditBudgetSheet extends StatefulWidget {
  final Category cat;
  final FinanceProvider fp;
  const _EditBudgetSheet({required this.cat, required this.fp});

  @override
  State<_EditBudgetSheet> createState() => _EditBudgetSheetState();
}

class _EditBudgetSheetState extends State<_EditBudgetSheet> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
      text: widget.cat.budgetLimit != null
          ? widget.cat.budgetLimit!.toStringAsFixed(2)
          : '',
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
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
          Row(
            children: [
              categoryIconWidget(widget.cat),
              const SizedBox(width: 10),
              Text(widget.cat.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _ctrl,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Monthly Budget Limit',
              prefixText: '\$ ',
            ),
            autofocus: true,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    await widget.fp.setCategoryBudget(widget.cat, null);
                    if (context.mounted) Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Remove Limit'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () async {
                    final limit = double.tryParse(_ctrl.text);
                    if (limit != null && limit > 0) {
                      await widget.fp.setCategoryBudget(widget.cat, limit);
                      if (context.mounted) Navigator.pop(context);
                    }
                  },
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Add Category Sheet ────────────────────────────────────────────────────────
class _AddCategorySheet extends StatefulWidget {
  final FinanceProvider fp;
  const _AddCategorySheet({required this.fp});

  @override
  State<_AddCategorySheet> createState() => _AddCategorySheetState();
}

class _AddCategorySheetState extends State<_AddCategorySheet> {
  final _nameCtrl = TextEditingController();
  final _budgetCtrl = TextEditingController();
  String _selectedIconKey = 'Card';
  Color _selectedColor = paletteColors.first;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _budgetCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('New Category',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Name'),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            const Text('Icon', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categoryIcons.map((m) {
                final key = m['label'] as String;
                final icon = m['icon'] as IconData;
                final isSelected = key == _selectedIconKey;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIconKey = key),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? _selectedColor.withOpacity(0.2)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected
                          ? Border.all(color: _selectedColor, width: 2)
                          : null,
                    ),
                    child: Icon(icon,
                        color: isSelected ? _selectedColor : Colors.grey),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            const Text('Color', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: paletteColors.map((c) {
                final isSelected = _selectedColor == c;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = c),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: Colors.white, width: 3)
                          : null,
                      boxShadow: isSelected
                          ? [BoxShadow(color: c.withOpacity(0.5), blurRadius: 6)]
                          : null,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _budgetCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Budget Limit (optional)',
                prefixText: '\$ ',
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _nameCtrl.text.trim().isEmpty
                    ? null
                    : () async {
                        await widget.fp.addCategory(
                          name: _nameCtrl.text.trim(),
                          iconKey: _selectedIconKey,
                          colorHex: colorToHex(_selectedColor),
                          budgetLimit: double.tryParse(_budgetCtrl.text),
                        );
                        if (context.mounted) Navigator.pop(context);
                      },
                child: const Text('Add Category'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
