import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../providers/bills_provider.dart';
import '../../widgets/common_widgets.dart';

class BillsScreen extends StatelessWidget {
  const BillsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bp = context.watch<BillsProvider>();

    return Scaffold(
      body: bp.isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                _BillsHeroBar(bp: bp),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: 20),
                      _TotalSummaryCard(bp: bp),
                      const SizedBox(height: 16),
                      _CalendarStrip(bp: bp),
                      const SizedBox(height: 16),
                      if (bp.bills.isEmpty)
                        _EmptyBills()
                      else ...[
                        if (bp.overdueBills.isNotEmpty) ...[
                          _SectionHeader(
                            title: 'Overdue',
                            color: AppColors.expense,
                            icon: Icons.warning_amber_rounded,
                          ),
                          const SizedBox(height: 8),
                          ...bp.overdueBills
                              .map((b) => Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: _BillTile(
                                      bill: b,
                                      bp: bp,
                                      highlight: _BillHighlight.overdue,
                                    ),
                                  ))
                              .toList(),
                          const SizedBox(height: 8),
                        ],
                        _SectionHeader(
                          title: 'Upcoming Bills',
                          color: AppColors.primary,
                          icon: Icons.receipt_long_rounded,
                        ),
                        const SizedBox(height: 8),
                        ...bp.upcomingBills.where((b) => !b.isOverdue).map((b) {
                          final h = b.isDueSoon
                              ? _BillHighlight.soon
                              : _BillHighlight.none;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _BillTile(
                              bill: b,
                              bp: bp,
                              highlight: h,
                            ),
                          );
                        }).toList(),
                      ],
                    ]),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSheet(context, bp),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddSheet(BuildContext context, BillsProvider bp) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddBillSheet(bp: bp),
    );
  }
}

enum _BillHighlight { none, soon, overdue }

// ── Hero Bar ──────────────────────────────────────────────────────────────────
class _BillsHeroBar extends StatelessWidget {
  final BillsProvider bp;
  const _BillsHeroBar({required this.bp});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: const Color(0xFFF59E0B),
      title: Text(
        'Bill Reminders',
        style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700, color: Colors.white, fontSize: 18),
      ),
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -40,
                right: -20,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.07),
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
                        'Monthly Bills',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.75),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatCurrency(bp.totalMonthlyBills),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (bp.overdueBills.isNotEmpty)
                            _HeroBadge(
                              label: '${bp.overdueBills.length} overdue',
                              color: AppColors.expenseLight,
                              bgColor: AppColors.expense.withValues(alpha: 0.2),
                            ),
                          if (bp.overdueBills.isNotEmpty)
                            const SizedBox(width: 8),
                          _HeroBadge(
                            label: '${bp.bills.length} total bills',
                            color: Colors.white,
                            bgColor: Colors.white.withValues(alpha: 0.2),
                          ),
                        ],
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

class _HeroBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color bgColor;
  const _HeroBadge(
      {required this.label, required this.color, required this.bgColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

// ── Total Summary Card ────────────────────────────────────────────────────────
class _TotalSummaryCard extends StatelessWidget {
  final BillsProvider bp;
  const _TotalSummaryCard({required this.bp});

  @override
  Widget build(BuildContext context) {
    final autopayCount = bp.bills.where((b) => b.isAutopay).length;
    return AppCard(
      child: Row(
        children: [
          Expanded(
            child: _InfoItem(
              icon: Icons.receipt_long_rounded,
              iconColor: AppColors.warning,
              label: 'Total / Month',
              value: formatCurrency(bp.totalMonthlyBills),
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey.withValues(alpha: 0.2),
          ),
          Expanded(
            child: _InfoItem(
              icon: Icons.autorenew_rounded,
              iconColor: AppColors.income,
              label: 'Auto-pay',
              value: '$autopayCount of ${bp.bills.length}',
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey.withValues(alpha: 0.2),
          ),
          Expanded(
            child: _InfoItem(
              icon: Icons.warning_amber_rounded,
              iconColor: AppColors.expense,
              label: 'Overdue',
              value: '${bp.overdueBills.length}',
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  const _InfoItem(
      {required this.icon,
      required this.iconColor,
      required this.label,
      required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 22),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: 15,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.grey),
        ),
      ],
    );
  }
}

// ── Calendar Strip ────────────────────────────────────────────────────────────
class _CalendarStrip extends StatelessWidget {
  final BillsProvider bp;
  const _CalendarStrip({required this.bp});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final billDays = {for (final b in bp.bills) b.dueDay: b};

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle('${_monthName(now.month)} ${now.year} — Bill Calendar'),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              childAspectRatio: 1,
            ),
            itemCount: daysInMonth,
            itemBuilder: (context, index) {
              final day = index + 1;
              final hasBill = billDays.containsKey(day);
              final bill = billDays[day];
              final isToday = day == now.day;
              final isPast = day < now.day;

              Color bgColor = Colors.transparent;
              Color textColor = Theme.of(context).brightness == Brightness.dark
                  ? Colors.white70
                  : Colors.black54;

              if (isToday) {
                bgColor = AppColors.primary;
                textColor = Colors.white;
              } else if (hasBill && isPast) {
                bgColor = AppColors.expense.withValues(alpha: 0.15);
                textColor = AppColors.expense;
              } else if (hasBill) {
                final daysUntil = day - now.day;
                if (daysUntil <= 7) {
                  bgColor = AppColors.warning.withValues(alpha: 0.15);
                  textColor = AppColors.warning;
                } else {
                  bgColor = AppColors.primary.withValues(alpha: 0.1);
                  textColor = AppColors.primary;
                }
              }

              return Container(
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isToday
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : [],
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Text(
                        '$day',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: hasBill || isToday
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: textColor,
                        ),
                      ),
                    ),
                    if (hasBill)
                      Positioned(
                        top: 2,
                        right: 2,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: isPast
                                ? AppColors.expense
                                : (day - now.day <= 7
                                    ? AppColors.warning
                                    : AppColors.primary),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _LegendDot(color: AppColors.expense, label: 'Overdue'),
              const SizedBox(width: 12),
              _LegendDot(color: AppColors.warning, label: 'Due soon'),
              const SizedBox(width: 12),
              _LegendDot(color: AppColors.primary, label: 'Upcoming'),
            ],
          ),
        ],
      ),
    );
  }

  String _monthName(int m) {
    const names = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return names[m];
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.grey),
        ),
      ],
    );
  }
}

// ── Section Header ────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final Color color;
  final IconData icon;
  const _SectionHeader(
      {required this.title, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}

// ── Bill Tile ─────────────────────────────────────────────────────────────────
class _BillTile extends StatelessWidget {
  final Bill bill;
  final BillsProvider bp;
  final _BillHighlight highlight;
  const _BillTile(
      {required this.bill, required this.bp, required this.highlight});

  Color get _borderColor {
    switch (highlight) {
      case _BillHighlight.overdue:
        return AppColors.expense;
      case _BillHighlight.soon:
        return AppColors.warning;
      case _BillHighlight.none:
        return Colors.transparent;
    }
  }

  Color get _accentColor {
    switch (highlight) {
      case _BillHighlight.overdue:
        return AppColors.expense;
      case _BillHighlight.soon:
        return AppColors.warning;
      case _BillHighlight.none:
        return AppColors.primary;
    }
  }

  String get _dueLabel {
    switch (highlight) {
      case _BillHighlight.overdue:
        return 'Overdue';
      case _BillHighlight.soon:
        return 'Due in ${bill.daysUntilDue} day${bill.daysUntilDue != 1 ? 's' : ''}';
      case _BillHighlight.none:
        return 'Day ${bill.dueDay}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dismissible(
      key: Key('bill-${bill.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.expense.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete_rounded,
            color: AppColors.expense, size: 24),
      ),
      onDismissed: (_) => bp.deleteBill(bill),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: highlight != _BillHighlight.none
                ? _borderColor.withValues(alpha: 0.4)
                : (isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : const Color(0xFFEEEEFF)),
            width: highlight != _BillHighlight.none ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: highlight != _BillHighlight.none
                  ? _borderColor.withValues(alpha: 0.1)
                  : (isDark
                      ? Colors.transparent
                      : const Color(0xFF6C63FF).withValues(alpha: 0.06)),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _accentColor,
                    _accentColor.withValues(alpha: 0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: _accentColor.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '${bill.dueDay}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bill.name,
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: _accentColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _dueLabel,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: _accentColor,
                          ),
                        ),
                      ),
                      if (bill.isAutopay) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.income.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.autorenew_rounded,
                                  size: 9, color: AppColors.income),
                              const SizedBox(width: 3),
                              Text(
                                'Auto-pay',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.income,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Text(
              formatCurrency(bill.amount),
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: _accentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────
class _EmptyBills extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.warning.withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(Icons.receipt_long_outlined,
                color: Colors.white, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            'No Bills Yet',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Add your recurring bills to get reminders and track what\'s due this month.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 13, color: Colors.grey, height: 1.5),
          ),
        ],
      ),
    );
  }
}

// ── Add Bill Sheet ────────────────────────────────────────────────────────────
class _AddBillSheet extends StatefulWidget {
  final BillsProvider bp;
  const _AddBillSheet({required this.bp});

  @override
  State<_AddBillSheet> createState() => _AddBillSheetState();
}

class _AddBillSheetState extends State<_AddBillSheet> {
  final _nameCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  int _dueDay = 1;
  bool _isAutopay = false;
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.fromLTRB(
            24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ShaderMask(
                shaderCallback: (b) => const LinearGradient(
                  colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                ).createShader(b),
                child: Text(
                  'Add Bill',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _nameCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Bill Name',
                  hintText: 'e.g. Electricity, Rent',
                  prefixIcon: Icon(Icons.receipt_long_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _amountCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: '\$ ',
                  prefixIcon: Icon(Icons.attach_money_rounded),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Due Day: $_dueDay${_ordinal(_dueDay)} of each month',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: AppColors.warning,
                ),
              ),
              const SizedBox(height: 8),
              SliderTheme(
                data: SliderThemeData(
                  trackHeight: 6,
                  thumbShape:
                      const RoundSliderThumbShape(enabledThumbRadius: 10),
                  overlayShape:
                      const RoundSliderOverlayShape(overlayRadius: 20),
                  activeTrackColor: AppColors.warning,
                  inactiveTrackColor: AppColors.warning.withValues(alpha: 0.2),
                  thumbColor: AppColors.warning,
                  overlayColor: AppColors.warning.withValues(alpha: 0.12),
                ),
                child: Slider(
                  value: _dueDay.toDouble(),
                  min: 1,
                  max: 31,
                  divisions: 30,
                  onChanged: (v) => setState(() => _dueDay = v.round()),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('1st',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 11, color: Colors.grey)),
                  Text('31st',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 11, color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : const Color(0xFFE0E0FF),
                    width: 1.5,
                  ),
                ),
                child: SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                  title: Text(
                    'Auto-pay',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Text(
                    'This bill pays automatically',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 12, color: Colors.grey),
                  ),
                  value: _isAutopay,
                  activeColor: AppColors.income,
                  onChanged: (v) => setState(() => _isAutopay = v),
                ),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: _loading
                    ? null
                    : () async {
                        final name = _nameCtrl.text.trim();
                        final amount = double.tryParse(_amountCtrl.text);
                        if (name.isEmpty || amount == null || amount <= 0)
                          return;
                        setState(() => _loading = true);
                        await widget.bp.addBill(
                          name: name,
                          amount: amount,
                          dueDay: _dueDay,
                          isAutopay: _isAutopay,
                        );
                        if (context.mounted) Navigator.pop(context);
                      },
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.warning.withValues(alpha: 0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: _loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.5, color: Colors.white),
                          )
                        : Text(
                            'Add Bill',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _ordinal(int n) {
    if (n >= 11 && n <= 13) return 'th';
    switch (n % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }
}
