import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/constants.dart';
import '../models/models.dart';

// ── Formatters ────────────────────────────────────────────────────────────────
final _currencyFmt = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
final _percentFmt = NumberFormat.percentPattern()..maximumFractionDigits = 1;

String formatCurrency(double v) => _currencyFmt.format(v);
String formatPercent(double v) => _percentFmt.format(v);
String formatMonthYear(DateTime d) => DateFormat.yMMMM().format(d);

// ── Summary Card ─────────────────────────────────────────────────────────────
class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 18),
                const SizedBox(width: 6),
                Text(title,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.grey[600])),
              ],
            ),
            const SizedBox(height: 8),
            Text(value,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

// ── Category Icon ─────────────────────────────────────────────────────────────
IconData categoryIconData(String iconKey) {
  final match = categoryIcons.firstWhere(
    (m) => m['label'] == iconKey,
    orElse: () => categoryIcons.last,
  );
  return match['icon'] as IconData;
}

Widget categoryIconWidget(Category cat, {double size = 20}) {
  return Container(
    width: size + 16,
    height: size + 16,
    decoration: BoxDecoration(
      color: cat.color.withValues(alpha: 0.15),
      shape: BoxShape.circle,
    ),
    child: Icon(categoryIconData(cat.iconKey), color: cat.color, size: size),
  );
}

// ── Category Chip ─────────────────────────────────────────────────────────────
class CategoryChip extends StatelessWidget {
  final Category category;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? category.color
              : category.color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(categoryIconData(category.iconKey),
                color: isSelected ? Colors.white : category.color, size: 14),
            const SizedBox(width: 6),
            Text(
              category.name,
              style: TextStyle(
                color: isSelected ? Colors.white : category.color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Budget Progress Row ───────────────────────────────────────────────────────
class BudgetProgressRow extends StatelessWidget {
  final Category category;
  final double used;
  final double? limit;
  final double progress;
  final bool isOver;

  const BudgetProgressRow({
    super.key,
    required this.category,
    required this.used,
    this.limit,
    required this.progress,
    required this.isOver,
  });

  Color get barColor {
    if (isOver) return Colors.red;
    if (progress > 0.8) return Colors.orange;
    return category.color;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          Row(
            children: [
              categoryIconWidget(category, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(category.name,
                    style: const TextStyle(fontWeight: FontWeight.w500)),
              ),
              if (isOver)
                const Padding(
                  padding: EdgeInsets.only(right: 4),
                  child: Icon(Icons.warning_amber_rounded,
                      color: Colors.red, size: 16),
                ),
              Text(
                limit != null
                    ? '${formatCurrency(used)} / ${formatCurrency(limit!)}'
                    : formatCurrency(used),
                style: TextStyle(
                  fontSize: 12,
                  color: isOver ? Colors.red : Colors.grey[600],
                ),
              ),
            ],
          ),
          if (limit != null) ...[
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: barColor.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation<Color>(barColor),
                minHeight: 6,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
