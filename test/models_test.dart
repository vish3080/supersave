import 'package:flutter_test/flutter_test.dart';
import 'package:supersave/models/models.dart';

void main() {
  group('SavingsGoal', () {
    test('progress is 0 when nothing saved', () {
      final goal = SavingsGoal(
        id: '1',
        userId: 'u1',
        name: 'Vacation',
        targetAmount: 1000,
        currentAmount: 0,
        isCompleted: false,
        createdAt: DateTime(2026, 1, 1),
      );
      expect(goal.progress, 0.0);
      expect(goal.remaining, 1000.0);
    });

    test('progress is 1.0 when fully saved', () {
      final goal = SavingsGoal(
        id: '2',
        userId: 'u1',
        name: 'Car',
        targetAmount: 500,
        currentAmount: 500,
        isCompleted: true,
        createdAt: DateTime(2026, 1, 1),
      );
      expect(goal.progress, 1.0);
      expect(goal.remaining, 0.0);
    });

    test('progress clamps to 1.0 if over-saved', () {
      final goal = SavingsGoal(
        id: '3',
        userId: 'u1',
        name: 'Emergency',
        targetAmount: 200,
        currentAmount: 250,
        isCompleted: true,
        createdAt: DateTime(2026, 1, 1),
      );
      expect(goal.progress, 1.0);
    });
  });

  group('colorToHex', () {
    test('round-trips a hex color', () {
      const hex = '5B8DEF';
      final result = colorToHex(colorFromHex(hex));
      expect(result.toUpperCase(), hex);
    });
  });

  group('IncomeEntry JSON', () {
    test('serializes and deserializes correctly', () {
      final entry = IncomeEntry(
        id: 'abc',
        userId: 'u1',
        amount: 3000.0,
        month: 5,
        year: 2026,
        source: 'Salary',
        createdAt: DateTime(2026, 5, 1),
      );
      final json = entry.toJson();
      final restored = IncomeEntry.fromJson(json);
      expect(restored.amount, 3000.0);
      expect(restored.source, 'Salary');
      expect(restored.month, 5);
    });
  });
}
