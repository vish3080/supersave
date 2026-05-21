import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../core/constants.dart';
import '../core/theme.dart';
import '../models/models.dart';

// ── Formatters ────────────────────────────────────────────────────────────────
final _currencyFmt = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
final _percentFmt = NumberFormat.percentPattern()..maximumFractionDigits = 1;

String formatCurrency(double v) => _currencyFmt.format(v);
String formatPercent(double v) => _percentFmt.format(v);
String formatMonthYear(DateTime d) => DateFormat.yMMMM().format(d);

// ── Gradient Summary Card ─────────────────────────────────────────────────────
class GradientSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final LinearGradient gradient;

  const GradientSummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── App Card (replaces plain Card) ───────────────────────────────────────────
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? color;

  const AppCard({super.key, required this.child, this.padding, this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color ?? (isDark ? AppColors.cardDark : Colors.white),
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: const Color(0xFF6C63FF).withValues(alpha: 0.06),
                  blurRadius: 24,
                  offset: const Offset(0, 4),
                ),
              ],
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : const Color(0xFFEEEEFF),
          width: 1,
        ),
      ),
      child: child,
    );
  }
}

// ── Section title ─────────────────────────────────────────────────────────────
class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : const Color(0xFF1A1A2E),
        ),
      ),
    );
  }
}

// ── Category icon ─────────────────────────────────────────────────────────────
IconData categoryIconData(String iconKey) {
  final match = categoryIcons.firstWhere(
    (m) => m['label'] == iconKey,
    orElse: () => categoryIcons.last,
  );
  return match['icon'] as IconData;
}

Widget categoryIconWidget(Category cat, {double size = 20}) {
  return Container(
    width: size + 18,
    height: size + 18,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          cat.color.withValues(alpha: 0.2),
          cat.color.withValues(alpha: 0.08),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
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
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    category.color,
                    category.color.withValues(alpha: 0.75)
                  ],
                )
              : null,
          color: isSelected ? null : category.color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : category.color.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: category.color.withValues(alpha: 0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              categoryIconData(category.iconKey),
              color: isSelected ? Colors.white : category.color,
              size: 14,
            ),
            const SizedBox(width: 6),
            Text(
              category.name,
              style: GoogleFonts.plusJakartaSans(
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

// ── Animated Budget Progress Bar ──────────────────────────────────────────────
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

  Color get _barColor {
    if (isOver) return AppColors.expense;
    if (progress > 0.8) return AppColors.warning;
    return category.color;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              categoryIconWidget(category, size: 16),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  category.name,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              if (isOver)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Icon(Icons.warning_amber_rounded,
                      color: AppColors.expense, size: 16),
                ),
              Text(
                limit != null
                    ? '${formatCurrency(used)} / ${formatCurrency(limit!)}'
                    : formatCurrency(used),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isOver ? AppColors.expense : Colors.grey,
                ),
              ),
            ],
          ),
          if (limit != null) ...[
            const SizedBox(height: 8),
            Stack(
              children: [
                // Background track
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: _barColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                // Filled bar
                FractionallySizedBox(
                  widthFactor: progress.clamp(0.0, 1.0),
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        _barColor,
                        _barColor.withValues(alpha: 0.7),
                      ]),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: _barColor.withValues(alpha: 0.4),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ── Summary Card (legacy, kept for compatibility) ─────────────────────────────
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
    return GradientSummaryCard(
      title: title,
      value: value,
      icon: icon,
      gradient: LinearGradient(
        colors: [color, color.withValues(alpha: 0.75)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );
  }
}
