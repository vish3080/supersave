import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';

const _uuid = Uuid();

class SubscriptionProvider extends ChangeNotifier {
  List<Subscription> _subscriptions = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _userId;

  // ── Getters ───────────────────────────────────────────────────────────────
  List<Subscription> get subscriptions => _subscriptions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Only subscriptions that are currently active.
  List<Subscription> get activeSubscriptions =>
      _subscriptions.where((s) => s.isActive).toList();

  /// Combined monthly cost of all active subscriptions.
  ///
  /// Conversion rules:
  ///   - 'monthly'  → amount as-is
  ///   - 'yearly'   → amount ÷ 12
  ///   - 'weekly'   → amount × 4.33 (average weeks per month)
  double get monthlyTotal {
    return activeSubscriptions.fold(0, (sum, s) {
      return sum + _toMonthly(s);
    });
  }

  /// Annualised cost of all active subscriptions (monthlyTotal × 12).
  double get yearlyTotal => monthlyTotal * 12;

  double _toMonthly(Subscription s) {
    switch (s.billingCycle) {
      case 'yearly':
        return s.amount / 12;
      case 'weekly':
        return s.amount * 4.33;
      case 'monthly':
      default:
        return s.amount;
    }
  }

  // ── Load ──────────────────────────────────────────────────────────────────
  Future<void> loadAll(String userId) async {
    _userId = userId;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    await _loadSubscriptions();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadSubscriptions() async {
    try {
      final rows = await Supabase.instance.client
          .from('subscriptions')
          .select()
          .eq('user_id', _userId!);
      _subscriptions =
          (rows as List).map((r) => Subscription.fromJson(r)).toList();
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  // ── CRUD ──────────────────────────────────────────────────────────────────
  Future<void> addSubscription({
    required String name,
    required double amount,
    required String billingCycle,
    String? notes,
  }) async {
    if (_userId == null) return;
    final subscription = Subscription(
      id: _uuid.v4(),
      userId: _userId!,
      name: name,
      amount: amount,
      billingCycle: billingCycle,
      isActive: true,
      nextChargeDate: null,
      notes: notes,
      createdAt: DateTime.now(),
    );
    try {
      await Supabase.instance.client
          .from('subscriptions')
          .insert(subscription.toJson());
      await _loadSubscriptions();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Flips the [isActive] flag of the given subscription and persists it.
  Future<void> toggleActive(Subscription sub) async {
    final updated = sub.copyWith(isActive: !sub.isActive);
    try {
      await Supabase.instance.client
          .from('subscriptions')
          .update(updated.toJson())
          .eq('id', sub.id);
      await _loadSubscriptions();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteSubscription(Subscription sub) async {
    try {
      await Supabase.instance.client
          .from('subscriptions')
          .delete()
          .eq('id', sub.id);
      await _loadSubscriptions();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}
