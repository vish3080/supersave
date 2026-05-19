import 'package:flutter/material.dart';

// ── Helpers ──────────────────────────────────────────────────────────────────
Color colorFromHex(String hex) {
  final code = hex.replaceAll('#', '').padLeft(6, '0');
  return Color(int.parse('FF$code', radix: 16));
}

String colorToHex(Color color) =>
    color.value.toRadixString(16).substring(2).toUpperCase();

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
