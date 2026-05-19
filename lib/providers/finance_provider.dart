import 'package:flutter/foundation.dart' hide Category;
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../services/supabase_service.dart';
import '../core/constants.dart';

const _uuid = Uuid();

class FinanceProvider extends ChangeNotifier {
  List<IncomeEntry> _income = [];
  List<Category> _categories = [];
  List<Expense> _expenses = [];
  List<SavingsGoal> _savingsGoals = [];
  bool _isLoading = false;
  String? _errorMessage;

  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  String? _userId;

  // Getters
  List<IncomeEntry> get income => _income;
  List<Category> get categories => _categories;
  List<Expense> get expenses => _expenses;
  List<SavingsGoal> get savingsGoals => _savingsGoals;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get selectedMonth => _selectedMonth;
  int get selectedYear => _selectedYear;

  DateTime get selectedMonthDate => DateTime(_selectedYear, _selectedMonth);

  double get totalIncome =>
      _income.fold(0, (sum, e) => sum + e.amount);

  double get totalExpenses =>
      _expenses.fold(0, (sum, e) => sum + e.amount);

  double get savings => totalIncome - totalExpenses;

  double get savingsRate =>
      totalIncome > 0 ? savings / totalIncome : 0;

  List<CategorySpend> get categorySpending {
    if (totalExpenses == 0) return [];
    final result = <CategorySpend>[];
    for (final cat in _categories) {
      final total = _expenses
          .where((e) => e.categoryId == cat.id)
          .fold(0.0, (sum, e) => sum + e.amount);
      if (total > 0) {
        result.add(CategorySpend(
          category: cat,
          total: total,
          percentage: total / totalExpenses,
        ));
      }
    }
    result.sort((a, b) => b.total.compareTo(a.total));
    return result;
  }

  double budgetUsed(Category cat) =>
      _expenses.where((e) => e.categoryId == cat.id).fold(0, (s, e) => s + e.amount);

  double budgetProgress(Category cat) {
    if (cat.budgetLimit == null || cat.budgetLimit! <= 0) return 0;
    return (budgetUsed(cat) / cat.budgetLimit!).clamp(0.0, 1.0);
  }

  bool isOverBudget(Category cat) =>
      cat.budgetLimit != null && budgetUsed(cat) > cat.budgetLimit!;

  Future<void> reload() async {
    if (_userId == null) return;
    await loadAll(_userId!);
  }

  // ── Load all ──────────────────────────────────────────────────────────────
  Future<void> loadAll(String userId) async {
    _userId = userId;
    _isLoading = true;
    notifyListeners();
    await Future.wait([
      _loadIncome(),
      _loadCategories(),
    ]);
    await Future.wait([
      _loadExpenses(),
      _loadSavingsGoals(),
    ]);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _refreshMonth() async {
    if (_userId == null) return;
    await Future.wait([_loadIncome(), _loadExpenses()]);
    notifyListeners();
  }

  Future<void> _loadIncome() async {
    try {
      _income = await FinanceService.shared
          .fetchIncome(_userId!, _selectedMonth, _selectedYear);
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  Future<void> _loadCategories() async {
    try {
      _categories = await FinanceService.shared.fetchCategories(_userId!);
      if (_categories.isEmpty) await _seedDefaultCategories();
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  Future<void> _loadExpenses() async {
    try {
      _expenses = await FinanceService.shared
          .fetchExpenses(_userId!, _selectedMonth, _selectedYear);
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  Future<void> _loadSavingsGoals() async {
    try {
      _savingsGoals = await FinanceService.shared.fetchSavingsGoals(_userId!);
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  // ── Month navigation ──────────────────────────────────────────────────────
  Future<void> previousMonth() async {
    if (_selectedMonth == 1) {
      _selectedMonth = 12;
      _selectedYear--;
    } else {
      _selectedMonth--;
    }
    notifyListeners();
    await _refreshMonth();
  }

  Future<void> nextMonth() async {
    if (_selectedMonth == 12) {
      _selectedMonth = 1;
      _selectedYear++;
    } else {
      _selectedMonth++;
    }
    notifyListeners();
    await _refreshMonth();
  }

  // ── Income CRUD ───────────────────────────────────────────────────────────
  Future<void> addIncome(double amount, String source) async {
    if (_userId == null) return;
    final entry = IncomeEntry(
      id: _uuid.v4(),
      userId: _userId!,
      amount: amount,
      month: _selectedMonth,
      year: _selectedYear,
      source: source,
      createdAt: DateTime.now(),
    );
    try {
      await FinanceService.shared.upsertIncome(entry);
      await _loadIncome();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteIncome(IncomeEntry entry) async {
    try {
      await FinanceService.shared.deleteIncome(entry.id);
      await _loadIncome();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // ── Expense CRUD ──────────────────────────────────────────────────────────
  Future<void> addExpense({
    required String categoryId,
    required double amount,
    required String note,
    required DateTime date,
    required bool isRecurring,
    RecurringInterval? recurringInterval,
  }) async {
    if (_userId == null) return;
    final expense = Expense(
      id: _uuid.v4(),
      userId: _userId!,
      categoryId: categoryId,
      amount: amount,
      note: note,
      date: date,
      isRecurring: isRecurring,
      recurringInterval: recurringInterval,
      createdAt: DateTime.now(),
    );
    try {
      await FinanceService.shared.insertExpense(expense);
      await _loadExpenses();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteExpense(Expense expense) async {
    try {
      await FinanceService.shared.deleteExpense(expense.id);
      await _loadExpenses();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // ── Category CRUD ─────────────────────────────────────────────────────────
  Future<void> addCategory({
    required String name,
    required String iconKey,
    required String colorHex,
    double? budgetLimit,
  }) async {
    if (_userId == null) return;
    final cat = Category(
      id: _uuid.v4(),
      userId: _userId!,
      name: name,
      colorHex: colorHex,
      iconKey: iconKey,
      budgetLimit: budgetLimit,
      createdAt: DateTime.now(),
    );
    try {
      await FinanceService.shared.insertCategory(cat);
      await _loadCategories();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> setCategoryBudget(Category cat, double? limit) async {
    final updated = cat.copyWith(budgetLimit: limit);
    try {
      await FinanceService.shared.updateCategory(updated);
      await _loadCategories();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteCategory(Category cat) async {
    try {
      await FinanceService.shared.deleteCategory(cat.id);
      await _loadCategories();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // ── Savings CRUD ──────────────────────────────────────────────────────────
  Future<void> addSavingsGoal({
    required String name,
    required double targetAmount,
    DateTime? deadline,
  }) async {
    if (_userId == null) return;
    final goal = SavingsGoal(
      id: _uuid.v4(),
      userId: _userId!,
      name: name,
      targetAmount: targetAmount,
      currentAmount: 0,
      deadline: deadline,
      isCompleted: false,
      createdAt: DateTime.now(),
    );
    try {
      await FinanceService.shared.insertSavingsGoal(goal);
      await _loadSavingsGoals();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> depositToGoal(SavingsGoal goal, double amount) async {
    final newAmount = (goal.currentAmount + amount).clamp(0, goal.targetAmount);
    final updated = goal.copyWith(
      currentAmount: newAmount.toDouble(),
      isCompleted: newAmount >= goal.targetAmount,
    );
    try {
      await FinanceService.shared.updateSavingsGoal(updated);
      await _loadSavingsGoals();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteSavingsGoal(SavingsGoal goal) async {
    try {
      await FinanceService.shared.deleteSavingsGoal(goal.id);
      await _loadSavingsGoals();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // ── Seed defaults ─────────────────────────────────────────────────────────
  Future<void> _seedDefaultCategories() async {
    if (_userId == null) return;
    for (final preset in defaultCategories) {
      final cat = Category(
        id: _uuid.v4(),
        userId: _userId!,
        name: preset.name,
        colorHex: preset.colorHex,
        iconKey: preset.icon,
        createdAt: DateTime.now(),
      );
      await FinanceService.shared.insertCategory(cat);
    }
    _categories = await FinanceService.shared.fetchCategories(_userId!);
  }
}
