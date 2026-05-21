import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';

const _uuid = Uuid();

class WealthProvider extends ChangeNotifier {
  List<Asset> _assets = [];
  List<Debt> _debts = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _userId;

  // ── Getters ───────────────────────────────────────────────────────────────
  List<Asset> get assets => _assets;
  List<Debt> get debts => _debts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  double get totalAssets => _assets.fold(0, (sum, a) => sum + a.value);

  double get totalDebts => _debts.fold(0, (sum, d) => sum + d.balance);

  double get netWorth => totalAssets - totalDebts;

  /// Debts sorted by interest rate descending (avalanche payoff method).
  List<Debt> get debtsByPriority {
    final sorted = List<Debt>.from(_debts);
    sorted.sort((a, b) => b.interestRate.compareTo(a.interestRate));
    return sorted;
  }

  /// Estimates months to pay off [debt] given an optional [extraPayment] on
  /// top of the minimum payment.
  ///
  /// Returns `0` if the debt is already paid off, and `null` if the payment
  /// amount does not exceed the monthly interest (i.e. debt cannot be paid
  /// off under the given conditions).
  int? monthsToPayoff(Debt debt, {double extraPayment = 0}) {
    if (debt.balance <= 0) return 0;

    final double monthlyRate = debt.interestRate / 100 / 12;
    final double payment = debt.minimumPayment + extraPayment;

    if (monthlyRate == 0) {
      // Zero-interest — simple division.
      return (debt.balance / payment).ceil();
    }

    final double monthlyInterest = debt.balance * monthlyRate;
    if (payment <= monthlyInterest) {
      // Payment does not cover accruing interest — cannot pay off.
      return null;
    }

    // Standard amortisation formula:
    //   n = -ln(1 - r * B / P) / ln(1 + r)
    final double n = -math.log(1 - monthlyRate * debt.balance / payment) /
        math.log(1 + monthlyRate);
    return n.ceil();
  }

  // ── Load ──────────────────────────────────────────────────────────────────
  Future<void> loadAll(String userId) async {
    _userId = userId;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    await Future.wait([
      _loadAssets(),
      _loadDebts(),
    ]);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadAssets() async {
    try {
      final rows = await Supabase.instance.client
          .from('assets')
          .select()
          .eq('user_id', _userId!);
      _assets = (rows as List).map((r) => Asset.fromJson(r)).toList();
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  Future<void> _loadDebts() async {
    try {
      final rows = await Supabase.instance.client
          .from('debts')
          .select()
          .eq('user_id', _userId!);
      _debts = (rows as List).map((r) => Debt.fromJson(r)).toList();
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  // ── Asset CRUD ────────────────────────────────────────────────────────────
  Future<void> addAsset({
    required String name,
    required String type,
    required double value,
  }) async {
    if (_userId == null) return;
    final asset = Asset(
      id: _uuid.v4(),
      userId: _userId!,
      name: name,
      type: type,
      value: value,
      createdAt: DateTime.now(),
    );
    try {
      await Supabase.instance.client.from('assets').insert(asset.toJson());
      await _loadAssets();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteAsset(Asset asset) async {
    try {
      await Supabase.instance.client.from('assets').delete().eq('id', asset.id);
      await _loadAssets();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // ── Debt CRUD ─────────────────────────────────────────────────────────────
  Future<void> addDebt({
    required String name,
    required String type,
    required double balance,
    required double interestRate,
    required double minimumPayment,
    int? dueDay,
  }) async {
    if (_userId == null) return;
    final debt = Debt(
      id: _uuid.v4(),
      userId: _userId!,
      name: name,
      type: type,
      balance: balance,
      interestRate: interestRate,
      minimumPayment: minimumPayment,
      dueDay: dueDay,
      createdAt: DateTime.now(),
    );
    try {
      await Supabase.instance.client.from('debts').insert(debt.toJson());
      await _loadDebts();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateDebt(Debt debt, {double? balance}) async {
    final updated = debt.copyWith(balance: balance ?? debt.balance);
    try {
      await Supabase.instance.client
          .from('debts')
          .update(updated.toJson())
          .eq('id', debt.id);
      await _loadDebts();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteDebt(Debt debt) async {
    try {
      await Supabase.instance.client.from('debts').delete().eq('id', debt.id);
      await _loadDebts();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}
