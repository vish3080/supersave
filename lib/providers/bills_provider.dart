import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';

const _uuid = Uuid();

class BillsProvider extends ChangeNotifier {
  List<Bill> _bills = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _userId;

  // ── Getters ───────────────────────────────────────────────────────────────
  List<Bill> get bills => _bills;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Sum of all bill amounts.
  double get totalMonthlyBills => _bills.fold(0, (sum, b) => sum + b.amount);

  /// Bills whose due day has already passed this month.
  List<Bill> get overdueBills {
    final today = DateTime.now().day;
    return _bills.where((b) => b.dueDay < today).toList();
  }

  /// All bills sorted by due day relative to today so the soonest-due bills
  /// appear first and bills already past their due day wrap to the end.
  List<Bill> get upcomingBills {
    final today = DateTime.now().day;
    final sorted = List<Bill>.from(_bills);
    sorted.sort((a, b) {
      // Distance from today, wrapping around the month.
      int daysA = (a.dueDay - today + 31) % 31;
      int daysB = (b.dueDay - today + 31) % 31;
      return daysA.compareTo(daysB);
    });
    return sorted;
  }

  // ── Load ──────────────────────────────────────────────────────────────────
  Future<void> loadAll(String userId) async {
    _userId = userId;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    await _loadBills();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadBills() async {
    try {
      final rows = await Supabase.instance.client
          .from('bills')
          .select()
          .eq('user_id', _userId!);
      _bills = (rows as List).map((r) => Bill.fromJson(r)).toList();
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  // ── CRUD ──────────────────────────────────────────────────────────────────
  Future<void> addBill({
    required String name,
    required double amount,
    required int dueDay,
    bool isAutopay = false,
    String? notes,
  }) async {
    if (_userId == null) return;
    final bill = Bill(
      id: _uuid.v4(),
      userId: _userId!,
      name: name,
      amount: amount,
      dueDay: dueDay,
      isAutopay: isAutopay,
      notes: notes,
      createdAt: DateTime.now(),
    );
    try {
      await Supabase.instance.client.from('bills').insert(bill.toJson());
      await _loadBills();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteBill(Bill bill) async {
    try {
      await Supabase.instance.client.from('bills').delete().eq('id', bill.id);
      await _loadBills();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}
