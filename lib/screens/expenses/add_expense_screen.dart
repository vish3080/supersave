import 'package:flutter/material.dart' hide Category;
import 'package:provider/provider.dart';
import '../../providers/finance_provider.dart';
import '../../models/models.dart';
import '../../widgets/common_widgets.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  String? _selectedCategoryId;
  DateTime _date = DateTime.now();
  bool _isRecurring = false;
  RecurringInterval _interval = RecurringInterval.monthly;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  bool get _isValid =>
      double.tryParse(_amountCtrl.text) != null && _selectedCategoryId != null;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save(FinanceProvider fp) async {
    final amount = double.tryParse(_amountCtrl.text);
    if (amount == null || _selectedCategoryId == null) return;
    await fp.addExpense(
      categoryId: _selectedCategoryId!,
      amount: amount,
      note: _noteCtrl.text.trim(),
      date: _date,
      isRecurring: _isRecurring,
      recurringInterval: _isRecurring ? _interval : null,
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final fp = context.watch<FinanceProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Expense'),
        actions: [
          TextButton(
            onPressed: _isValid ? () => _save(fp) : null,
            child: const Text('Save'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Amount
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _amountCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  prefixText: '\$ ',
                  hintText: '0.00',
                  border: InputBorder.none,
                  filled: false,
                ),
                onChanged: (_) => setState(() {}),
                autofocus: true,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Category picker
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Category',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 10),
                  fp.categories.isEmpty
                      ? const Text('No categories found.',
                          style: TextStyle(color: Colors.grey))
                      : Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: fp.categories
                              .map<Widget>((cat) => CategoryChip(
                                    category: cat,
                                    isSelected:
                                        _selectedCategoryId == cat.id,
                                    onTap: () => setState(
                                        () => _selectedCategoryId = cat.id),
                                  ))
                              .toList(),
                        ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Details
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  TextField(
                    controller: _noteCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Note (optional)',
                      border: InputBorder.none,
                      filled: false,
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Date'),
                    trailing: Text(
                      '${_date.day}/${_date.month}/${_date.year}',
                      style: const TextStyle(color: Colors.blue),
                    ),
                    onTap: _pickDate,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Recurring
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Recurring'),
                    subtitle: const Text('Mark as a subscription or regular bill'),
                    value: _isRecurring,
                    onChanged: (v) => setState(() => _isRecurring = v),
                  ),
                  if (_isRecurring) ...[
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: SegmentedButton<RecurringInterval>(
                        segments: RecurringInterval.values
                            .map((i) => ButtonSegment(
                                  value: i,
                                  label: Text(i.label),
                                ))
                            .toList(),
                        selected: {_interval},
                        onSelectionChanged: (s) =>
                            setState(() => _interval = s.first),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
