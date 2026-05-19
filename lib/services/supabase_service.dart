import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

final _db = Supabase.instance.client;

// ── Auth ─────────────────────────────────────────────────────────────────────
class AuthService {
  static final shared = AuthService._();
  AuthService._();

  Future<void> signUp(String email, String password) async {
    await _db.auth.signUp(email: email, password: password);
  }

  Future<void> signIn(String email, String password) async {
    await _db.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() async => _db.auth.signOut();

  Stream<AuthState> get authStateChanges => _db.auth.onAuthStateChange;

  String? get currentUserId => _db.auth.currentUser?.id;
}

// ── Finance ───────────────────────────────────────────────────────────────────
class FinanceService {
  static final shared = FinanceService._();
  FinanceService._();

  // Income
  Future<List<IncomeEntry>> fetchIncome(
      String userId, int month, int year) async {
    final data = await _db
        .from('income_entries')
        .select()
        .eq('user_id', userId)
        .eq('month', month)
        .eq('year', year);
    return (data as List).map((e) => IncomeEntry.fromJson(e)).toList();
  }

  Future<void> upsertIncome(IncomeEntry entry) async {
    await _db.from('income_entries').upsert(entry.toJson());
  }

  Future<void> deleteIncome(String id) async {
    await _db.from('income_entries').delete().eq('id', id);
  }

  // Categories
  Future<List<Category>> fetchCategories(String userId) async {
    final data = await _db
        .from('categories')
        .select()
        .eq('user_id', userId)
        .order('name');
    return (data as List).map((e) => Category.fromJson(e)).toList();
  }

  Future<void> insertCategory(Category cat) async {
    await _db.from('categories').insert(cat.toJson());
  }

  Future<void> updateCategory(Category cat) async {
    await _db.from('categories').update(cat.toJson()).eq('id', cat.id);
  }

  Future<void> deleteCategory(String id) async {
    await _db.from('categories').delete().eq('id', id);
  }

  // Expenses
  Future<List<Expense>> fetchExpenses(
      String userId, int month, int year) async {
    final startDate = '$year-${month.toString().padLeft(2, '0')}-01';
    final endMonth = month == 12 ? 1 : month + 1;
    final endYear = month == 12 ? year + 1 : year;
    final endDate = '$endYear-${endMonth.toString().padLeft(2, '0')}-01';

    final data = await _db
        .from('expenses')
        .select()
        .eq('user_id', userId)
        .gte('date', startDate)
        .lt('date', endDate)
        .order('date', ascending: false);
    return (data as List).map((e) => Expense.fromJson(e)).toList();
  }

  Future<void> insertExpense(Expense expense) async {
    await _db.from('expenses').insert(expense.toJson());
  }

  Future<void> deleteExpense(String id) async {
    await _db.from('expenses').delete().eq('id', id);
  }

  // Savings Goals
  Future<List<SavingsGoal>> fetchSavingsGoals(String userId) async {
    final data = await _db
        .from('savings_goals')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return (data as List).map((e) => SavingsGoal.fromJson(e)).toList();
  }

  Future<void> insertSavingsGoal(SavingsGoal goal) async {
    await _db.from('savings_goals').insert(goal.toJson());
  }

  Future<void> updateSavingsGoal(SavingsGoal goal) async {
    await _db.from('savings_goals').update(goal.toJson()).eq('id', goal.id);
  }

  Future<void> deleteSavingsGoal(String id) async {
    await _db.from('savings_goals').delete().eq('id', id);
  }
}
