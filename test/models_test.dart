import 'package:flutter_test/flutter_test.dart';
import 'package:supersave/models/models.dart';

void main() {
  group('SavingsGoal', () {
    final goal = SavingsGoal(
      id: '1',
      userId: 'u1',
      name: 'Vacation',
      targetAmount: 1000,
      currentAmount: 250,
      isCompleted: false,
      createdAt: DateTime(2026, 1, 1),
    );

    test('progress calculates correctly', () {
      expect(goal.progress, 0.25);
    });

    test('remaining calculates correctly', () {
      expect(goal.remaining, 750);
    });

    test('copyWith updates currentAmount', () {
      final updated = goal.copyWith(currentAmount: 1000, isCompleted: true);
      expect(updated.currentAmount, 1000);
      expect(updated.isCompleted, true);
    });
  });

  group('Category', () {
    final cat = Category(
      id: 'c1',
      userId: 'u1',
      name: 'Food',
      colorHex: 'FF6B6B',
      iconKey: 'Food',
      createdAt: DateTime(2026, 1, 1),
    );

    test('color parses from hex', () {
      expect(cat.color.r, isNonZero);
    });

    test('copyWith updates budgetLimit', () {
      final updated = cat.copyWith(budgetLimit: 500);
      expect(updated.budgetLimit, 500);
      expect(updated.name, 'Food');
    });
  });

  group('colorToHex', () {
    test('round-trips a known color', () {
      final cat = Category(
        id: 'c1',
        userId: 'u1',
        name: 'Test',
        colorHex: 'FF6B6B',
        iconKey: 'Other',
        createdAt: DateTime(2026, 1, 1),
      );
      // Parse then re-encode — should be the same hex
      final hex = colorToHex(cat.color);
      expect(hex, 'FF6B6B');
    });
  });
}
