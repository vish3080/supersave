import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../providers/wealth_provider.dart';
import '../../widgets/common_widgets.dart';

class DebtScreen extends StatefulWidget {
  const DebtScreen({super.key});

  @override
  State<DebtScreen> createState() => _DebtScreenState();
}

class _DebtScreenState extends State<DebtScreen>
    with SingleTickerProviderStateMixin {
  bool _isAvalanche = true;
  double _extraPayment = 0;
  late AnimationController _toggleCtrl;
  late Animation<double> _toggleAnim;

  @override
  void initState() {
    super.initState();
    _toggleCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _toggleAnim = CurvedAnimation(parent: _toggleCtrl, curve: Curves.easeInOut);
    _toggleCtrl.forward();
  }

  @override
  void dispose() {
    _toggleCtrl.dispose();
    super.dispose();
  }

  void _switchMethod(bool toAvalanche) {
    if (_isAvalanche == toAvalanche) return;
    _toggleCtrl.reverse().then((_) {
      setState(() => _isAvalanche = toAvalanche);
      _toggleCtrl.forward();
    });
  }

  List<Debt> _sortedDebts(WealthProvider wp) {
    final list = List<Debt>.from(wp.debts);
    if (_isAvalanche) {
      list.sort((a, b) => b.interestRate.compareTo(a.interestRate));
    } else {
      list.sort((a, b) => a.balance.compareTo(b.balance));
    }
    return list;
  }

  double _totalInterestForDebt(Debt debt) {
    final months =
        debt.balance <= 0 ? 0 : _monthsWithExtra(debt, _extraPayment) ?? 0;
    final totalPaid = (debt.minimumPayment + _extraPayment) * months;
    return (totalPaid - debt.balance).clamp(0, double.infinity);
  }

  int? _monthsWithExtra(Debt debt, double extra) {
    if (debt.balance <= 0) return 0;
    final monthlyRate = debt.interestRate / 100 / 12;
    final payment = debt.minimumPayment + extra;
    if (monthlyRate == 0) return (debt.balance / payment).ceil();
    final monthlyInterest = debt.balance * monthlyRate;
    if (payment <= monthlyInterest) return null;
    double balance = debt.balance;
    int months = 0;
    while (balance > 0 && months < 1200) {
      balance = balance * (1 + monthlyRate) - payment;
      months++;
    }
    return months;
  }

  String _debtFreeDate(WealthProvider wp) {
    final sorted = _sortedDebts(wp);
    int maxMonths = 0;
    for (final d in sorted) {
      final m = _monthsWithExtra(d, _extraPayment) ?? 999;
      if (m > maxMonths) maxMonths = m;
    }
    if (maxMonths >= 999) return 'Never (payment too low)';
    final date = DateTime.now().add(Duration(days: maxMonths * 30));
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  double _totalInterestSaved(WealthProvider wp) {
    double withExtra = 0;
    double withoutExtra = 0;
    for (final d in wp.debts) {
      withExtra += _totalInterestForDebt(d);
      final mBase = _monthsWithExtra(d, 0) ?? 0;
      final baseTotal = d.minimumPayment * mBase;
      withoutExtra += (baseTotal - d.balance).clamp(0, double.infinity);
    }
    return (withoutExtra - withExtra).clamp(0, double.infinity);
  }

  @override
  Widget build(BuildContext context) {
    final wp = context.watch<WealthProvider>();

    return Scaffold(
      body: wp.isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                _DebtHeroBar(
                  totalDebt: wp.totalDebts,
                  debtCount: wp.debts.length,
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: 20),
                      if (wp.debts.isEmpty)
                        _EmptyDebts()
                      else ...[
                        _MethodToggle(
                          isAvalanche: _isAvalanche,
                          onSwitch: _switchMethod,
                        ),
                        const SizedBox(height: 16),
                        _ExtraPaymentSlider(
                          value: _extraPayment,
                          onChanged: (v) => setState(() => _extraPayment = v),
                        ),
                        const SizedBox(height: 16),
                        _SummaryCard(
                          debtFreeDate: _debtFreeDate(wp),
                          interestSaved: _totalInterestSaved(wp),
                          extraPayment: _extraPayment,
                        ),
                        const SizedBox(height: 16),
                        SectionTitle('Payoff Plan'),
                        FadeTransition(
                          opacity: _toggleAnim,
                          child: Column(
                            children: _sortedDebts(wp)
                                .asMap()
                                .entries
                                .map((e) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 12),
                                      child: _DebtPayoffCard(
                                        debt: e.value,
                                        rank: e.key + 1,
                                        months: _monthsWithExtra(
                                            e.value, _extraPayment),
                                        totalInterest:
                                            _totalInterestForDebt(e.value),
                                        isAvalanche: _isAvalanche,
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                      ],
                    ]),
                  ),
                ),
              ],
            ),
    );
  }
}

// ── Hero App Bar ──────────────────────────────────────────────────────────────
class _DebtHeroBar extends StatelessWidget {
  final double totalDebt;
  final int debtCount;
  const _DebtHeroBar({required this.totalDebt, required this.debtCount});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: const Color(0xFFEF4444),
      title: Text(
        'Debt Payoff Planner',
        style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700, color: Colors.white, fontSize: 18),
      ),
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -40,
                right: -30,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                ),
              ),
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Debt',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.75),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatCurrency(totalDebt),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 38,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -1,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$debtCount debt${debtCount != 1 ? 's' : ''} tracked',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Method Toggle ─────────────────────────────────────────────────────────────
class _MethodToggle extends StatelessWidget {
  final bool isAvalanche;
  final void Function(bool) onSwitch;
  const _MethodToggle({required this.isAvalanche, required this.onSwitch});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payoff Method',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: isDark ? Colors.white : const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : const Color(0xFFF1F3FF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => onSwitch(true),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        gradient:
                            isAvalanche ? AppColors.gradientExpense : null,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: isAvalanche
                            ? [
                                BoxShadow(
                                  color:
                                      AppColors.expense.withValues(alpha: 0.35),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                )
                              ]
                            : [],
                      ),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.local_fire_department_rounded,
                              size: 16,
                              color: isAvalanche ? Colors.white : Colors.grey,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Avalanche',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isAvalanche ? Colors.white : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => onSwitch(false),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        gradient:
                            !isAvalanche ? AppColors.gradientSavings : null,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: !isAvalanche
                            ? [
                                BoxShadow(
                                  color:
                                      AppColors.savings.withValues(alpha: 0.35),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                )
                              ]
                            : [],
                      ),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.ac_unit_rounded,
                              size: 16,
                              color: !isAvalanche ? Colors.white : Colors.grey,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Snowball',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color:
                                    !isAvalanche ? Colors.white : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Container(
              key: ValueKey(isAvalanche),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (isAvalanche ? AppColors.expense : AppColors.savings)
                    .withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: (isAvalanche ? AppColors.expense : AppColors.savings)
                      .withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    isAvalanche
                        ? Icons.local_fire_department_rounded
                        : Icons.ac_unit_rounded,
                    size: 18,
                    color: isAvalanche ? AppColors.expense : AppColors.savings,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isAvalanche
                          ? 'Avalanche: Pay highest-interest debt first. Saves the most money on interest over time.'
                          : 'Snowball: Pay smallest balance first. Builds momentum with quick wins.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: isDark ? Colors.white70 : Colors.black54,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Extra Payment Slider ──────────────────────────────────────────────────────
class _ExtraPaymentSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;
  const _ExtraPaymentSlider({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Extra Monthly Payment',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  gradient: AppColors.gradientPrimary,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  '+ ${formatCurrency(value)}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.primary.withValues(alpha: 0.15),
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withValues(alpha: 0.12),
            ),
            child: Slider(
              value: value,
              min: 0,
              max: 500,
              divisions: 50,
              onChanged: onChanged,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('\$0',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 11, color: Colors.grey)),
              Text('\$500',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 11, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Summary Card ──────────────────────────────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  final String debtFreeDate;
  final double interestSaved;
  final double extraPayment;
  const _SummaryCard(
      {required this.debtFreeDate,
      required this.interestSaved,
      required this.extraPayment});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF9B6DFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.emoji_events_rounded,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                'Payoff Summary',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _SummaryItem(
                  label: 'Debt-Free Date',
                  value: debtFreeDate,
                  icon: Icons.calendar_today_rounded,
                ),
              ),
              Container(
                  width: 1,
                  height: 40,
                  color: Colors.white.withValues(alpha: 0.2)),
              Expanded(
                child: _SummaryItem(
                  label: 'Interest Saved',
                  value: formatCurrency(interestSaved),
                  icon: Icons.savings_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _SummaryItem(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 18),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Debt Payoff Card ──────────────────────────────────────────────────────────
class _DebtPayoffCard extends StatelessWidget {
  final Debt debt;
  final int rank;
  final int? months;
  final double totalInterest;
  final bool isAvalanche;
  const _DebtPayoffCard({
    required this.debt,
    required this.rank,
    required this.months,
    required this.totalInterest,
    required this.isAvalanche,
  });

  double get _progress {
    if (debt.balance <= 0) return 1.0;
    return 0.0;
  }

  String get _timeLabel {
    if (months == null) return '∞ months';
    if (months == 0) return 'Paid off!';
    if (months! < 12) return '$months months';
    final yrs = months! ~/ 12;
    final rem = months! % 12;
    return rem == 0 ? '$yrs yr${yrs > 1 ? 's' : ''}' : '$yrs yr $rem mo';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final barColor = isAvalanche ? AppColors.expense : AppColors.savings;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  gradient: isAvalanche
                      ? AppColors.gradientExpense
                      : AppColors.gradientSavings,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$rank',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      debt.name,
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                      ),
                    ),
                    Text(
                      debt.type,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formatCurrency(debt.balance),
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: AppColors.expense,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${debt.interestRate.toStringAsFixed(1)}% APR',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.warning,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Progress bar (0% always unless paid off — shown for illustration)
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: barColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              FractionallySizedBox(
                widthFactor: _progress,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [barColor, barColor.withValues(alpha: 0.7)]),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: barColor.withValues(alpha: 0.4),
                        blurRadius: 6,
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _StatChip(
                icon: Icons.schedule_rounded,
                label: _timeLabel,
                color: barColor,
              ),
              const SizedBox(width: 8),
              _StatChip(
                icon: Icons.attach_money_rounded,
                label: '${formatCurrency(totalInterest)} interest',
                color: AppColors.warning,
              ),
              const SizedBox(width: 8),
              _StatChip(
                icon: Icons.payment_rounded,
                label: '${formatCurrency(debt.minimumPayment)}/mo min',
                color: Colors.grey,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _StatChip(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────
class _EmptyDebts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppCard(
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: AppColors.gradientIncome,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.income.withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(Icons.check_circle_outline_rounded,
                color: Colors.white, size: 36),
          ),
          const SizedBox(height: 16),
          Text(
            'Debt-Free!',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w800,
              fontSize: 20,
              color: AppColors.income,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "You have no debts tracked. Add debts from the Net Worth screen to see your payoff plan.",
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 13, color: Colors.grey, height: 1.5),
          ),
        ],
      ),
    );
  }
}
