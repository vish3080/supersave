import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../providers/wealth_provider.dart';
import '../../widgets/common_widgets.dart';

class NetWorthScreen extends StatelessWidget {
  const NetWorthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wp = context.watch<WealthProvider>();

    return Scaffold(
      body: wp.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                CustomScrollView(
                  slivers: [
                    _NetWorthHeroBar(wp: wp),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          const SizedBox(height: 20),
                          _AssetsSection(wp: wp),
                          const SizedBox(height: 16),
                          _DebtsSection(wp: wp),
                        ]),
                      ),
                    ),
                  ],
                ),
              ],
            ),
      floatingActionButton: _NetWorthFab(wp: wp),
    );
  }
}

// ── Hero Sliver App Bar ───────────────────────────────────────────────────────
class _NetWorthHeroBar extends StatelessWidget {
  final WealthProvider wp;
  const _NetWorthHeroBar({required this.wp});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: _NetWorthHeroCard(wp: wp),
      ),
      title: Text(
        'Net Worth',
        style: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w700,
          color: Colors.white,
          fontSize: 18,
        ),
      ),
    );
  }
}

class _NetWorthHeroCard extends StatelessWidget {
  final WealthProvider wp;
  const _NetWorthHeroCard({required this.wp});

  @override
  Widget build(BuildContext context) {
    final nw = wp.netWorth;
    final isPositive = nw >= 0;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -60,
            right: -40,
            child: _Orb(size: 200, color: Colors.white.withValues(alpha: 0.07)),
          ),
          Positioned(
            bottom: 40,
            left: -50,
            child: _Orb(size: 160, color: Colors.white.withValues(alpha: 0.05)),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 36),
                  Text(
                    'Total Net Worth',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.75),
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    formatCurrency(nw.abs()),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 42,
                      fontWeight: FontWeight.w800,
                      color: isPositive ? Colors.white : AppColors.expenseLight,
                      letterSpacing: -1,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isPositive
                          ? AppColors.income.withValues(alpha: 0.25)
                          : AppColors.expense.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isPositive
                            ? AppColors.incomeLight.withValues(alpha: 0.5)
                            : AppColors.expenseLight.withValues(alpha: 0.5),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      isPositive ? 'Positive Net Worth' : 'Negative Net Worth',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isPositive
                            ? AppColors.incomeLight
                            : AppColors.expenseLight,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.25),
                                    width: 1),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Assets',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      color:
                                          Colors.white.withValues(alpha: 0.7),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    formatCurrency(wp.totalAssets),
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.incomeLight,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.25),
                                    width: 1),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Debts',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      color:
                                          Colors.white.withValues(alpha: 0.7),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    formatCurrency(wp.totalDebts),
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.expenseLight,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
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

// ── Assets Section ────────────────────────────────────────────────────────────
class _AssetsSection extends StatelessWidget {
  final WealthProvider wp;
  const _AssetsSection({required this.wp});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle('Assets (${wp.assets.length})'),
        if (wp.assets.isEmpty)
          _EmptyState(
            icon: Icons.account_balance_wallet_outlined,
            label: 'No assets yet',
            subtitle: 'Add your first asset to track your wealth',
          )
        else
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: wp.assets.asMap().entries.map((entry) {
                final i = entry.key;
                final asset = entry.value;
                return _AssetTile(
                  asset: asset,
                  wp: wp,
                  showDivider: i < wp.assets.length - 1,
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}

class _AssetTile extends StatelessWidget {
  final Asset asset;
  final WealthProvider wp;
  final bool showDivider;
  const _AssetTile(
      {required this.asset, required this.wp, required this.showDivider});

  IconData _iconForType(String type) {
    switch (type.toLowerCase()) {
      case 'bank account':
        return Icons.account_balance_rounded;
      case 'investment':
        return Icons.trending_up_rounded;
      case 'property':
        return Icons.home_rounded;
      case 'vehicle':
        return Icons.directions_car_rounded;
      case 'crypto':
        return Icons.currency_bitcoin_rounded;
      default:
        return Icons.savings_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('asset-${asset.id}'),
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
      onDismissed: (_) => wp.deleteAsset(asset),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: AppColors.gradientIncome,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.income.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(_iconForType(asset.type),
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        asset.name,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        asset.type,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  formatCurrency(asset.value),
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: AppColors.income,
                  ),
                ),
              ],
            ),
          ),
          if (showDivider)
            Divider(
              height: 1,
              indent: 72,
              endIndent: 16,
              color: Colors.grey.withValues(alpha: 0.15),
            ),
        ],
      ),
    );
  }
}

// ── Debts Section ─────────────────────────────────────────────────────────────
class _DebtsSection extends StatelessWidget {
  final WealthProvider wp;
  const _DebtsSection({required this.wp});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle('Debts (${wp.debts.length})'),
        if (wp.debts.isEmpty)
          _EmptyState(
            icon: Icons.credit_card_off_outlined,
            label: 'No debts tracked',
            subtitle: 'Add debts to calculate your true net worth',
          )
        else
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: wp.debts.asMap().entries.map((entry) {
                final i = entry.key;
                final debt = entry.value;
                return _DebtTile(
                  debt: debt,
                  wp: wp,
                  showDivider: i < wp.debts.length - 1,
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}

class _DebtTile extends StatelessWidget {
  final Debt debt;
  final WealthProvider wp;
  final bool showDivider;
  const _DebtTile(
      {required this.debt, required this.wp, required this.showDivider});

  IconData _iconForType(String type) {
    switch (type.toLowerCase()) {
      case 'credit card':
        return Icons.credit_card_rounded;
      case 'student loan':
        return Icons.school_rounded;
      case 'mortgage':
        return Icons.home_work_rounded;
      case 'auto loan':
        return Icons.directions_car_rounded;
      case 'personal loan':
        return Icons.person_rounded;
      default:
        return Icons.receipt_long_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('debt-${debt.id}'),
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
      onDismissed: (_) => wp.deleteDebt(debt),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: AppColors.gradientExpense,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.expense.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(_iconForType(debt.type),
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        debt.name,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        debt.type,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
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
          ),
          if (showDivider)
            Divider(
              height: 1,
              indent: 72,
              endIndent: 16,
              color: Colors.grey.withValues(alpha: 0.15),
            ),
        ],
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  const _EmptyState(
      {required this.icon, required this.label, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppCard(
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: AppColors.gradientPrimary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: isDark ? Colors.white : const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

// ── FAB with Speed Dial ───────────────────────────────────────────────────────
class _NetWorthFab extends StatefulWidget {
  final WealthProvider wp;
  const _NetWorthFab({required this.wp});

  @override
  State<_NetWorthFab> createState() => _NetWorthFabState();
}

class _NetWorthFabState extends State<_NetWorthFab>
    with SingleTickerProviderStateMixin {
  bool _open = false;
  late AnimationController _ctrl;
  late Animation<double> _rotAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 250));
    _rotAnim = Tween<double>(begin: 0, end: 0.375)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _open = !_open);
    if (_open) {
      _ctrl.forward();
    } else {
      _ctrl.reverse();
    }
  }

  void _showAddAsset() {
    _toggle();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddAssetSheet(wp: widget.wp),
    );
  }

  void _showAddDebt() {
    _toggle();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddDebtSheet(wp: widget.wp),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        FadeTransition(
          opacity: _fadeAnim,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _FabOption(
                label: 'Add Asset',
                icon: Icons.trending_up_rounded,
                color: AppColors.income,
                onTap: _showAddAsset,
              ),
              const SizedBox(height: 8),
              _FabOption(
                label: 'Add Debt',
                icon: Icons.credit_card_rounded,
                color: AppColors.expense,
                onTap: _showAddDebt,
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
        FloatingActionButton(
          onPressed: _toggle,
          backgroundColor: AppColors.primary,
          child: RotationTransition(
            turns: _rotAnim,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class _FabOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _FabOption(
      {required this.label,
      required this.icon,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.cardDark
                  : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1), blurRadius: 8),
              ],
            ),
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4)),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
        ],
      ),
    );
  }
}

// ── Add Asset Sheet ───────────────────────────────────────────────────────────
class _AddAssetSheet extends StatefulWidget {
  final WealthProvider wp;
  const _AddAssetSheet({required this.wp});

  @override
  State<_AddAssetSheet> createState() => _AddAssetSheetState();
}

class _AddAssetSheetState extends State<_AddAssetSheet> {
  final _nameCtrl = TextEditingController();
  final _valueCtrl = TextEditingController();
  String _type = 'Bank Account';
  final _types = [
    'Bank Account',
    'Investment',
    'Property',
    'Vehicle',
    'Crypto',
    'Other'
  ];
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _valueCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _BottomSheet(
      title: 'Add Asset',
      gradientColors: AppColors.gradientIncome.colors,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(
              labelText: 'Asset Name',
              prefixIcon: Icon(Icons.label_outline),
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _type,
            decoration: const InputDecoration(
              labelText: 'Type',
              prefixIcon: Icon(Icons.category_outlined),
            ),
            items: _types
                .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                .toList(),
            onChanged: (v) => setState(() => _type = v!),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _valueCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Current Value',
              prefixText: '\$ ',
              prefixIcon: Icon(Icons.attach_money_rounded),
            ),
          ),
          const SizedBox(height: 24),
          _GradientBtn(
            label: 'Add Asset',
            gradient: AppColors.gradientIncome,
            glowColor: AppColors.income,
            isLoading: _loading,
            onTap: () async {
              final name = _nameCtrl.text.trim();
              final value = double.tryParse(_valueCtrl.text);
              if (name.isEmpty || value == null || value <= 0) return;
              setState(() => _loading = true);
              await widget.wp.addAsset(name: name, type: _type, value: value);
              if (context.mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

// ── Add Debt Sheet ────────────────────────────────────────────────────────────
class _AddDebtSheet extends StatefulWidget {
  final WealthProvider wp;
  const _AddDebtSheet({required this.wp});

  @override
  State<_AddDebtSheet> createState() => _AddDebtSheetState();
}

class _AddDebtSheetState extends State<_AddDebtSheet> {
  final _nameCtrl = TextEditingController();
  final _balanceCtrl = TextEditingController();
  final _rateCtrl = TextEditingController();
  final _minPayCtrl = TextEditingController();
  String _type = 'Credit Card';
  final _types = [
    'Credit Card',
    'Student Loan',
    'Mortgage',
    'Auto Loan',
    'Personal Loan',
    'Other'
  ];
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _balanceCtrl.dispose();
    _rateCtrl.dispose();
    _minPayCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _BottomSheet(
      title: 'Add Debt',
      gradientColors: AppColors.gradientExpense.colors,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(
              labelText: 'Debt Name',
              prefixIcon: Icon(Icons.label_outline),
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _type,
            decoration: const InputDecoration(
              labelText: 'Type',
              prefixIcon: Icon(Icons.category_outlined),
            ),
            items: _types
                .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                .toList(),
            onChanged: (v) => setState(() => _type = v!),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _balanceCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Current Balance',
              prefixText: '\$ ',
              prefixIcon: Icon(Icons.account_balance_rounded),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _rateCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Interest Rate',
                    suffixText: '%',
                    prefixIcon: Icon(Icons.percent_rounded),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _minPayCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Min Payment',
                    prefixText: '\$ ',
                    prefixIcon: Icon(Icons.payment_rounded),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _GradientBtn(
            label: 'Add Debt',
            gradient: AppColors.gradientExpense,
            glowColor: AppColors.expense,
            isLoading: _loading,
            onTap: () async {
              final name = _nameCtrl.text.trim();
              final balance = double.tryParse(_balanceCtrl.text);
              final rate = double.tryParse(_rateCtrl.text);
              final minPay = double.tryParse(_minPayCtrl.text);
              if (name.isEmpty ||
                  balance == null ||
                  rate == null ||
                  minPay == null) return;
              setState(() => _loading = true);
              await widget.wp.addDebt(
                name: name,
                type: _type,
                balance: balance,
                interestRate: rate,
                minimumPayment: minPay,
              );
              if (context.mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

// ── Shared Bottom Sheet Shell ─────────────────────────────────────────────────
class _BottomSheet extends StatelessWidget {
  final String title;
  final List<Color> gradientColors;
  final Widget child;
  const _BottomSheet(
      {required this.title, required this.gradientColors, required this.child});

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
                shaderCallback: (b) =>
                    LinearGradient(colors: gradientColors).createShader(b),
                child: Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

// ── Gradient Button ───────────────────────────────────────────────────────────
class _GradientBtn extends StatelessWidget {
  final String label;
  final LinearGradient gradient;
  final Color glowColor;
  final bool isLoading;
  final VoidCallback onTap;
  const _GradientBtn(
      {required this.label,
      required this.gradient,
      required this.glowColor,
      required this.isLoading,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: glowColor.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5, color: Colors.white),
                )
              : Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}

// ── Decorative Orb ────────────────────────────────────────────────────────────
class _Orb extends StatelessWidget {
  final double size;
  final Color color;
  const _Orb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      );
}
