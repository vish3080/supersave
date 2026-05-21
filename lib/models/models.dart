import 'package:flutter/material.dart';

// ── Helpers ──────────────────────────────────────────────────────────────────
Color colorFromHex(String hex) {
  final code = hex.replaceAll('#', '').padLeft(6, '0');
  return Color(int.parse('FF$code', radix: 16));
}

String colorToHex(Color color) {
  final r = (color.r * 255).round().toRadixString(16).padLeft(2, '0');
  final g = (color.g * 255).round().toRadixString(16).padLeft(2, '0');
  final b = (color.b * 255).round().toRadixString(16).padLeft(2, '0');
  return '$r$g$b'.toUpperCase();
}

// ── Income Entry ─────────────────────────────────────────────────────────────
class IncomeEntry {
  final String id;
  final String userId;
  final double amount;
  final int month;
  final int year;
  final String source;
  final DateTime createdAt;

  const IncomeEntry({
    required this.id,
    required this.userId,
    required this.amount,
    required this.month,
    required this.year,
    required this.source,
    required this.createdAt,
  });

  factory IncomeEntry.fromJson(Map<String, dynamic> j) => IncomeEntry(
        id: j['id'] as String,
        userId: j['user_id'] as String,
        amount: (j['amount'] as num).toDouble(),
        month: j['month'] as int,
        year: j['year'] as int,
        source: j['source'] as String,
        createdAt: DateTime.parse(j['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'amount': amount,
        'month': month,
        'year': year,
        'source': source,
        'created_at': createdAt.toIso8601String(),
      };
}

// ── Category ─────────────────────────────────────────────────────────────────
class Category {
  final String id;
  final String userId;
  final String name;
  final String colorHex;
  final String iconKey;
  final double? budgetLimit;
  final DateTime createdAt;

  const Category({
    required this.id,
    required this.userId,
    required this.name,
    required this.colorHex,
    required this.iconKey,
    this.budgetLimit,
    required this.createdAt,
  });

  Color get color => colorFromHex(colorHex);

  factory Category.fromJson(Map<String, dynamic> j) => Category(
        id: j['id'] as String,
        userId: j['user_id'] as String,
        name: j['name'] as String,
        colorHex: j['color_hex'] as String,
        iconKey: j['icon_key'] as String,
        budgetLimit: j['budget_limit'] != null
            ? (j['budget_limit'] as num).toDouble()
            : null,
        createdAt: DateTime.parse(j['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'name': name,
        'color_hex': colorHex,
        'icon_key': iconKey,
        'budget_limit': budgetLimit,
        'created_at': createdAt.toIso8601String(),
      };

  Category copyWith({double? budgetLimit}) => Category(
        id: id,
        userId: userId,
        name: name,
        colorHex: colorHex,
        iconKey: iconKey,
        budgetLimit: budgetLimit,
        createdAt: createdAt,
      );
}

// ── Expense ───────────────────────────────────────────────────────────────────
enum RecurringInterval { weekly, monthly, yearly }

extension RecurringIntervalLabel on RecurringInterval {
  String get label {
    switch (this) {
      case RecurringInterval.weekly:
        return 'Weekly';
      case RecurringInterval.monthly:
        return 'Monthly';
      case RecurringInterval.yearly:
        return 'Yearly';
    }
  }

  String get value => name;
}

class Expense {
  final String id;
  final String userId;
  final String categoryId;
  final double amount;
  final String note;
  final DateTime date;
  final bool isRecurring;
  final RecurringInterval? recurringInterval;
  final DateTime createdAt;

  const Expense({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.amount,
    required this.note,
    required this.date,
    required this.isRecurring,
    this.recurringInterval,
    required this.createdAt,
  });

  factory Expense.fromJson(Map<String, dynamic> j) => Expense(
        id: j['id'] as String,
        userId: j['user_id'] as String,
        categoryId: j['category_id'] as String,
        amount: (j['amount'] as num).toDouble(),
        note: j['note'] as String? ?? '',
        date: DateTime.parse(j['date'] as String),
        isRecurring: j['is_recurring'] as bool? ?? false,
        recurringInterval: j['recurring_interval'] != null
            ? RecurringInterval.values.firstWhere(
                (e) => e.value == j['recurring_interval'],
                orElse: () => RecurringInterval.monthly,
              )
            : null,
        createdAt: DateTime.parse(j['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'category_id': categoryId,
        'amount': amount,
        'note': note,
        'date':
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
        'is_recurring': isRecurring,
        'recurring_interval': recurringInterval?.value,
        'created_at': createdAt.toIso8601String(),
      };
}

// ── Savings Goal ─────────────────────────────────────────────────────────────
class SavingsGoal {
  final String id;
  final String userId;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime? deadline;
  final bool isCompleted;
  final DateTime createdAt;

  const SavingsGoal({
    required this.id,
    required this.userId,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    this.deadline,
    required this.isCompleted,
    required this.createdAt,
  });

  double get progress =>
      targetAmount > 0 ? (currentAmount / targetAmount).clamp(0.0, 1.0) : 0;
  double get remaining =>
      (targetAmount - currentAmount).clamp(0, double.infinity);

  factory SavingsGoal.fromJson(Map<String, dynamic> j) => SavingsGoal(
        id: j['id'] as String,
        userId: j['user_id'] as String,
        name: j['name'] as String,
        targetAmount: (j['target_amount'] as num).toDouble(),
        currentAmount: (j['current_amount'] as num).toDouble(),
        deadline: j['deadline'] != null
            ? DateTime.parse(j['deadline'] as String)
            : null,
        isCompleted: j['is_completed'] as bool? ?? false,
        createdAt: DateTime.parse(j['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'name': name,
        'target_amount': targetAmount,
        'current_amount': currentAmount,
        'deadline': deadline != null
            ? '${deadline!.year}-${deadline!.month.toString().padLeft(2, '0')}-${deadline!.day.toString().padLeft(2, '0')}'
            : null,
        'is_completed': isCompleted,
        'created_at': createdAt.toIso8601String(),
      };

  SavingsGoal copyWith({double? currentAmount, bool? isCompleted}) =>
      SavingsGoal(
        id: id,
        userId: userId,
        name: name,
        targetAmount: targetAmount,
        currentAmount: currentAmount ?? this.currentAmount,
        deadline: deadline,
        isCompleted: isCompleted ?? this.isCompleted,
        createdAt: createdAt,
      );
}

// ── Asset ─────────────────────────────────────────────────────────────────────
class Asset {
  final String id;
  final String userId;
  final String name;
  final String type; // bank | investment | property | vehicle | crypto | other
  final double value;
  final String? notes;
  final DateTime createdAt;

  const Asset({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.value,
    this.notes,
    required this.createdAt,
  });

  factory Asset.fromJson(Map<String, dynamic> j) => Asset(
        id: j['id'] as String,
        userId: j['user_id'] as String,
        name: j['name'] as String,
        type: j['type'] as String? ?? 'other',
        value: (j['value'] as num).toDouble(),
        notes: j['notes'] as String?,
        createdAt: DateTime.parse(j['created_at'] as String),
      );

  Map<String, dynamic> toInsert() => {
        'user_id': userId,
        'name': name,
        'type': type,
        'value': value,
        'notes': notes,
      };

  Map<String, dynamic> toJson() => toInsert();
}

// ── Debt ──────────────────────────────────────────────────────────────────────
class Debt {
  final String id;
  final String userId;
  final String name;
  final String
      type; // credit_card | student_loan | mortgage | auto_loan | personal_loan | other
  final double balance;
  final double interestRate; // APR %
  final double minimumPayment;
  final int? dueDay;
  final DateTime createdAt;

  const Debt({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.balance,
    required this.interestRate,
    required this.minimumPayment,
    this.dueDay,
    required this.createdAt,
  });

  factory Debt.fromJson(Map<String, dynamic> j) => Debt(
        id: j['id'] as String,
        userId: j['user_id'] as String,
        name: j['name'] as String,
        type: j['type'] as String? ?? 'other',
        balance: (j['balance'] as num).toDouble(),
        interestRate: (j['interest_rate'] as num).toDouble(),
        minimumPayment: (j['minimum_payment'] as num).toDouble(),
        dueDay: j['due_day'] as int?,
        createdAt: DateTime.parse(j['created_at'] as String),
      );

  Map<String, dynamic> toInsert() => {
        'user_id': userId,
        'name': name,
        'type': type,
        'balance': balance,
        'interest_rate': interestRate,
        'minimum_payment': minimumPayment,
        'due_day': dueDay,
      };

  Map<String, dynamic> toJson() => toInsert();

  Debt copyWith({double? balance}) => Debt(
        id: id,
        userId: userId,
        name: name,
        type: type,
        balance: balance ?? this.balance,
        interestRate: interestRate,
        minimumPayment: minimumPayment,
        dueDay: dueDay,
        createdAt: createdAt,
      );
}

// ── Bill ──────────────────────────────────────────────────────────────────────
class Bill {
  final String id;
  final String userId;
  final String name;
  final double amount;
  final int dueDay; // 1-31
  final bool isAutopay;
  final String? notes;
  final DateTime createdAt;

  const Bill({
    required this.id,
    required this.userId,
    required this.name,
    required this.amount,
    required this.dueDay,
    required this.isAutopay,
    this.notes,
    required this.createdAt,
  });

  factory Bill.fromJson(Map<String, dynamic> j) => Bill(
        id: j['id'] as String,
        userId: j['user_id'] as String,
        name: j['name'] as String,
        amount: (j['amount'] as num).toDouble(),
        dueDay: j['due_day'] as int,
        isAutopay: j['is_autopay'] as bool? ?? false,
        notes: j['notes'] as String?,
        createdAt: DateTime.parse(j['created_at'] as String),
      );

  Map<String, dynamic> toInsert() => {
        'user_id': userId,
        'name': name,
        'amount': amount,
        'due_day': dueDay,
        'is_autopay': isAutopay,
        'notes': notes,
      };

  Map<String, dynamic> toJson() => toInsert();

  int get daysUntilDue {
    final now = DateTime.now();
    final thisMonth = DateTime(now.year, now.month, dueDay);
    final nextMonth = DateTime(now.year, now.month + 1, dueDay);
    if (thisMonth.isAfter(now) || thisMonth.day == now.day) {
      return thisMonth.difference(now).inDays;
    }
    return nextMonth.difference(now).inDays;
  }

  bool get isOverdue {
    final now = DateTime.now();
    return dueDay < now.day;
  }

  bool get isDueSoon => daysUntilDue <= 7 && !isOverdue;
}

// ── Subscription ──────────────────────────────────────────────────────────────
class Subscription {
  final String id;
  final String userId;
  final String name;
  final double amount;
  final String billingCycle; // weekly | monthly | yearly
  final bool isActive;
  final DateTime? nextChargeDate;
  final String? notes;
  final DateTime createdAt;

  const Subscription({
    required this.id,
    required this.userId,
    required this.name,
    required this.amount,
    required this.billingCycle,
    required this.isActive,
    this.nextChargeDate,
    this.notes,
    required this.createdAt,
  });

  double get monthlyEquivalent {
    switch (billingCycle) {
      case 'weekly':
        return amount * 4.33;
      case 'yearly':
        return amount / 12;
      default:
        return amount;
    }
  }

  factory Subscription.fromJson(Map<String, dynamic> j) => Subscription(
        id: j['id'] as String,
        userId: j['user_id'] as String,
        name: j['name'] as String,
        amount: (j['amount'] as num).toDouble(),
        billingCycle: j['billing_cycle'] as String? ?? 'monthly',
        isActive: j['is_active'] as bool? ?? true,
        nextChargeDate: j['next_charge_date'] != null
            ? DateTime.parse(j['next_charge_date'] as String)
            : null,
        notes: j['notes'] as String?,
        createdAt: DateTime.parse(j['created_at'] as String),
      );

  Map<String, dynamic> toInsert() => {
        'user_id': userId,
        'name': name,
        'amount': amount,
        'billing_cycle': billingCycle,
        'is_active': isActive,
        'notes': notes,
      };

  Map<String, dynamic> toJson() => toInsert();

  Subscription copyWith({bool? isActive}) => Subscription(
        id: id,
        userId: userId,
        name: name,
        amount: amount,
        billingCycle: billingCycle,
        isActive: isActive ?? this.isActive,
        nextChargeDate: nextChargeDate,
        notes: notes,
        createdAt: createdAt,
      );
}

// ── Linked Account (Plaid) ────────────────────────────────────────────────────
class LinkedAccount {
  final String id;
  final String userId;
  final String institutionName;
  final String accountName;
  final String accountType; // checking | savings | credit | investment
  final String? mask;
  final double? currentBalance;
  final DateTime? lastSyncedAt;

  const LinkedAccount({
    required this.id,
    required this.userId,
    required this.institutionName,
    required this.accountName,
    required this.accountType,
    this.mask,
    this.currentBalance,
    this.lastSyncedAt,
  });

  factory LinkedAccount.fromJson(Map<String, dynamic> j) => LinkedAccount(
        id: j['id'] as String,
        userId: j['user_id'] as String,
        institutionName: j['institution_name'] as String,
        accountName: j['account_name'] as String,
        accountType: j['account_type'] as String? ?? 'checking',
        mask: j['mask'] as String?,
        currentBalance: j['current_balance'] != null
            ? (j['current_balance'] as num).toDouble()
            : null,
        lastSyncedAt: j['last_synced_at'] != null
            ? DateTime.parse(j['last_synced_at'] as String)
            : null,
      );
}

// ── Chat Message ──────────────────────────────────────────────────────────────
class ChatMessage {
  final String role; // 'user' | 'assistant'
  final String content;
  final DateTime timestamp;

  const ChatMessage({
    required this.role,
    required this.content,
    required this.timestamp,
  });

  bool get isUser => role == 'user';
}

// ── Aggregates ────────────────────────────────────────────────────────────────
class CategorySpend {
  final Category category;
  final double total;
  final double percentage;

  const CategorySpend({
    required this.category,
    required this.total,
    required this.percentage,
  });
}
