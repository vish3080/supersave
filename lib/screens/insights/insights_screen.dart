import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../providers/finance_provider.dart';
import '../../widgets/common_widgets.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final fp = context.watch<FinanceProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Insights')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        children: [
          // Savings Rate Card
          _SavingsRateCard(fp: fp, isDark: isDark),
          const SizedBox(height: 16),

          // Spending by category bar chart
          if (fp.categorySpending.isNotEmpty) ...[
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionTitle('Top Spending Categories'),
                  const SizedBox(height: 4),
                  ...fp.categorySpending.take(5).map(
                        (s) => _CategoryBar(spend: s, total: fp.totalExpenses),
                      ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Income vs Expenses comparison
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionTitle('Income vs Expenses'),
                const SizedBox(height: 12),
                _IncomeExpenseBar(fp: fp),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Monthly breakdown
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionTitle('This Month at a Glance'),
                const SizedBox(height: 8),
                _StatRow(
                  label: 'Total Income',
                  value: formatCurrency(fp.totalIncome),
                  color: AppColors.income,
                  isDark: isDark,
                ),
                _StatRow(
                  label: 'Total Expenses',
                  value: formatCurrency(fp.totalExpenses),
                  color: AppColors.expense,
                  isDark: isDark,
                ),
                _StatRow(
                  label: 'Net Saved',
                  value: formatCurrency(fp.savings),
                  color: fp.savings >= 0 ? AppColors.income : AppColors.expense,
                  isDark: isDark,
                ),
                _StatRow(
                  label: 'Savings Rate',
                  value: formatPercent(fp.savingsRate),
                  color: fp.savingsRate >= 0.2
                      ? AppColors.income
                      : fp.savingsRate >= 0.1
                          ? AppColors.warning
                          : AppColors.expense,
                  isDark: isDark,
                ),
                _StatRow(
                  label: 'Avg Daily Spend',
                  value: formatCurrency(
                      fp.totalExpenses / DateTime.now().day.clamp(1, 31)),
                  color: AppColors.primary,
                  isDark: isDark,
                  isLast: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Smart tips
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionTitle('Smart Tips'),
                const SizedBox(height: 8),
                ..._buildTips(fp, isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTips(FinanceProvider fp, bool isDark) {
    final tips = <_Tip>[];

    if (fp.savingsRate < 0.1 && fp.totalIncome > 0) {
      tips.add(_Tip(
        icon: Icons.trending_down_rounded,
        color: AppColors.expense,
        title: 'Boost your savings rate',
        body:
            'You\'re saving ${formatPercent(fp.savingsRate)} this month. Aim for 20% to build wealth faster.',
      ));
    }
    if (fp.savingsRate >= 0.2) {
      tips.add(_Tip(
        icon: Icons.emoji_events_rounded,
        color: AppColors.income,
        title: 'Great savings rate!',
        body:
            'You\'re saving ${formatPercent(fp.savingsRate)} — that\'s above the 20% target. Keep it up!',
      ));
    }
    if (fp.categories.any((c) => fp.isOverBudget(c))) {
      tips.add(_Tip(
        icon: Icons.warning_amber_rounded,
        color: AppColors.warning,
        title: 'Over budget in some categories',
        body:
            'You\'ve exceeded your budget in at least one category. Review your spending to get back on track.',
      ));
    }
    if (fp.totalIncome == 0) {
      tips.add(_Tip(
        icon: Icons.add_circle_outline_rounded,
        color: AppColors.primary,
        title: 'Add your income',
        body:
            'Tap the + button on the Dashboard to log your income for this month.',
      ));
    }

    if (tips.isEmpty) {
      tips.add(_Tip(
        icon: Icons.auto_awesome_rounded,
        color: AppColors.primary,
        title: 'Looking good!',
        body:
            'Add more transactions and set budgets to get personalized insights.',
      ));
    }

    return tips.map((t) => _TipCard(tip: t, isDark: isDark)).toList();
  }
}

// ── Savings Rate Hero ─────────────────────────────────────────────────────────
class _SavingsRateCard extends StatelessWidget {
  final FinanceProvider fp;
  final bool isDark;
  const _SavingsRateCard({required this.fp, required this.isDark});

  LinearGradient get _gradient {
    if (fp.savingsRate >= 0.2) return AppColors.gradientIncome;
    if (fp.savingsRate >= 0.1) {
      return const LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)]);
    }
    return AppColors.gradientExpense;
  }

  String get _label {
    if (fp.savingsRate >= 0.3) return '🚀 Excellent';
    if (fp.savingsRate >= 0.2) return '✅ On Track';
    if (fp.savingsRate >= 0.1) return '⚡ Almost There';
    return '⚠️ Needs Attention';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: _gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _gradient.colors.first.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Savings Rate',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            formatPercent(fp.savingsRate),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 52,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -2,
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _MiniStat(label: 'Income', value: formatCurrency(fp.totalIncome)),
              Container(
                  width: 1,
                  height: 32,
                  color: Colors.white.withValues(alpha: 0.3)),
              _MiniStat(
                  label: 'Expenses', value: formatCurrency(fp.totalExpenses)),
              Container(
                  width: 1,
                  height: 32,
                  color: Colors.white.withValues(alpha: 0.3)),
              _MiniStat(label: 'Saved', value: formatCurrency(fp.savings)),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label, value;
  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(value,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Colors.white)),
          Text(label,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 11, color: Colors.white.withValues(alpha: 0.75))),
        ],
      );
}

// ── Category Bar ──────────────────────────────────────────────────────────────
class _CategoryBar extends StatelessWidget {
  final CategorySpend spend;
  final double total;
  const _CategoryBar({required this.spend, required this.total});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          Row(
            children: [
              categoryIconWidget(spend.category, size: 14),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  spend.category.name,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                  ),
                ),
              ),
              Text(
                formatCurrency(spend.total),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: spend.category.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Stack(
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: spend.category.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              FractionallySizedBox(
                widthFactor: spend.percentage.clamp(0.0, 1.0),
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      spend.category.color,
                      spend.category.color.withValues(alpha: 0.6),
                    ]),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Income vs Expense bar ─────────────────────────────────────────────────────
class _IncomeExpenseBar extends StatelessWidget {
  final FinanceProvider fp;
  const _IncomeExpenseBar({required this.fp});

  @override
  Widget build(BuildContext context) {
    final max =
        [fp.totalIncome, fp.totalExpenses].reduce((a, b) => a > b ? a : b);
    if (max == 0) {
      return Center(
        child: Text('No data yet',
            style: GoogleFonts.plusJakartaSans(color: Colors.grey)),
      );
    }
    return Column(
      children: [
        _HBar(
          label: 'Income',
          value: fp.totalIncome,
          max: max,
          gradient: AppColors.gradientIncome,
        ),
        const SizedBox(height: 10),
        _HBar(
          label: 'Expenses',
          value: fp.totalExpenses,
          max: max,
          gradient: AppColors.gradientExpense,
        ),
      ],
    );
  }
}

class _HBar extends StatelessWidget {
  final String label;
  final double value, max;
  final LinearGradient gradient;
  const _HBar(
      {required this.label,
      required this.value,
      required this.max,
      required this.gradient});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        SizedBox(
          width: 70,
          child: Text(label,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500)),
        ),
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 12,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : const Color(0xFFF1F3FF),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              FractionallySizedBox(
                widthFactor: (value / max).clamp(0.0, 1.0),
                child: Container(
                  height: 12,
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: gradient.colors.first.withValues(alpha: 0.35),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Text(formatCurrency(value),
            style: GoogleFonts.plusJakartaSans(
                fontSize: 12, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

// ── Stat Row ──────────────────────────────────────────────────────────────────
class _StatRow extends StatelessWidget {
  final String label, value;
  final Color color;
  final bool isDark;
  final bool isLast;
  const _StatRow(
      {required this.label,
      required this.value,
      required this.color,
      required this.isDark,
      this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(label,
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: isDark ? Colors.white70 : Colors.grey.shade700)),
              ),
              Text(value,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 14, fontWeight: FontWeight.w700, color: color)),
            ],
          ),
        ),
        if (!isLast)
          Divider(
              height: 1,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : const Color(0xFFEEEEFF)),
      ],
    );
  }
}

// ── Tip ───────────────────────────────────────────────────────────────────────
class _Tip {
  final IconData icon;
  final Color color;
  final String title, body;
  const _Tip(
      {required this.icon,
      required this.color,
      required this.title,
      required this.body});
}

class _TipCard extends StatelessWidget {
  final _Tip tip;
  final bool isDark;
  const _TipCard({required this.tip, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: tip.color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: tip.color.withValues(alpha: 0.2), width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: tip.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(tip.icon, color: tip.color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tip.title,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color:
                              isDark ? Colors.white : const Color(0xFF1A1A2E))),
                  const SizedBox(height: 3),
                  Text(tip.body,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 12, color: Colors.grey, height: 1.4)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
