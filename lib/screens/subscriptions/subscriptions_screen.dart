import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../providers/subscription_provider.dart';
import '../../widgets/common_widgets.dart';

class SubscriptionsScreen extends StatelessWidget {
  const SubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<SubscriptionProvider>();

    return Scaffold(
      body: sp.isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                _SubsHeroBar(sp: sp),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: 20),
                      _MonthlyYearlySummary(sp: sp),
                      const SizedBox(height: 16),
                      if (sp.subscriptions.isEmpty)
                        _EmptySubscriptions()
                      else ...[
                        SectionTitle(
                            'All Subscriptions (${sp.subscriptions.length})'),
                        ...sp.subscriptions
                            .map((s) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: _SubscriptionTile(sub: s, sp: sp),
                                ))
                            .toList(),
                      ],
                    ]),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSheet(context, sp),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddSheet(BuildContext context, SubscriptionProvider sp) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddSubscriptionSheet(sp: sp),
    );
  }
}

// ── Hero Bar ──────────────────────────────────────────────────────────────────
class _SubsHeroBar extends StatelessWidget {
  final SubscriptionProvider sp;
  const _SubsHeroBar({required this.sp});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 240,
      pinned: true,
      backgroundColor: AppColors.primary,
      title: Text(
        'Subscriptions',
        style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700, color: Colors.white, fontSize: 18),
      ),
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: _SubsHeroCard(sp: sp),
      ),
    );
  }
}

class _SubsHeroCard extends StatelessWidget {
  final SubscriptionProvider sp;
  const _SubsHeroCard({required this.sp});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.gradientPrimary),
      child: Stack(
        children: [
          Positioned(
            top: -50,
            right: -30,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: -40,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
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
                    'You spend',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.75),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${formatCurrency(sp.monthlyTotal)}/month',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'on ${sp.activeSubscriptions.length} active subscription${sp.activeSubscriptions.length != 1 ? 's' : ''}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
                              width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.calendar_today_rounded,
                                color: Colors.white, size: 14),
                            const SizedBox(width: 8),
                            Text(
                              '${formatCurrency(sp.yearlyTotal)} per year',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
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

// ── Monthly / Yearly Summary ──────────────────────────────────────────────────
class _MonthlyYearlySummary extends StatelessWidget {
  final SubscriptionProvider sp;
  const _MonthlyYearlySummary({required this.sp});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SummaryTile(
            label: 'Monthly',
            value: formatCurrency(sp.monthlyTotal),
            icon: Icons.repeat_rounded,
            gradient: AppColors.gradientPrimary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryTile(
            label: 'Yearly',
            value: formatCurrency(sp.yearlyTotal),
            icon: Icons.calendar_month_rounded,
            gradient: AppColors.gradientSavings,
          ),
        ),
      ],
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final LinearGradient gradient;
  const _SummaryTile(
      {required this.label,
      required this.value,
      required this.icon,
      required this.gradient});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Subscription Tile ─────────────────────────────────────────────────────────
class _SubscriptionTile extends StatelessWidget {
  final Subscription sub;
  final SubscriptionProvider sp;
  const _SubscriptionTile({required this.sub, required this.sp});

  IconData _iconForName(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('netflix') ||
        lower.contains('hulu') ||
        lower.contains('disney') ||
        lower.contains('hbo') ||
        lower.contains('tv') ||
        lower.contains('video')) {
      return Icons.tv_rounded;
    }
    if (lower.contains('spotify') ||
        lower.contains('apple music') ||
        lower.contains('music') ||
        lower.contains('audio') ||
        lower.contains('tidal') ||
        lower.contains('deezer')) {
      return Icons.music_note_rounded;
    }
    if (lower.contains('gym') ||
        lower.contains('fitness') ||
        lower.contains('peloton')) {
      return Icons.fitness_center_rounded;
    }
    if (lower.contains('amazon') || lower.contains('prime')) {
      return Icons.shopping_bag_rounded;
    }
    if (lower.contains('cloud') ||
        lower.contains('dropbox') ||
        lower.contains('icloud') ||
        lower.contains('google one') ||
        lower.contains('storage')) {
      return Icons.cloud_rounded;
    }
    if (lower.contains('news') ||
        lower.contains('medium') ||
        lower.contains('magazine')) {
      return Icons.article_rounded;
    }
    if (lower.contains('game') ||
        lower.contains('xbox') ||
        lower.contains('playstation') ||
        lower.contains('nintendo')) {
      return Icons.sports_esports_rounded;
    }
    if (lower.contains('adobe') ||
        lower.contains('figma') ||
        lower.contains('design')) {
      return Icons.design_services_rounded;
    }
    return Icons.subscriptions_rounded;
  }

  Color _colorForName(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('netflix')) return const Color(0xFFE50914);
    if (lower.contains('spotify')) return const Color(0xFF1DB954);
    if (lower.contains('apple')) return const Color(0xFF555555);
    if (lower.contains('amazon')) return const Color(0xFFFF9900);
    if (lower.contains('disney')) return const Color(0xFF113CCF);
    if (lower.contains('hbo')) return const Color(0xFF8B4CF0);
    if (lower.contains('youtube')) return const Color(0xFFFF0000);
    return AppColors.primary;
  }

  String _cycleLabel(String cycle) {
    switch (cycle) {
      case 'weekly':
        return 'Weekly';
      case 'yearly':
        return 'Yearly';
      default:
        return 'Monthly';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = _colorForName(sub.name);

    return Dismissible(
      key: Key('sub-${sub.id}'),
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
      onDismissed: (_) => sp.deleteSubscription(sub),
      child: AppCard(
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: sub.isActive ? 1.0 : 0.3),
                borderRadius: BorderRadius.circular(14),
                boxShadow: sub.isActive
                    ? [
                        BoxShadow(
                          color: color.withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : [],
              ),
              child:
                  Icon(_iconForName(sub.name), color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sub.name,
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: sub.isActive
                          ? (isDark ? Colors.white : const Color(0xFF1A1A2E))
                          : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _cycleLabel(sub.billingCycle),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      if (!sub.isActive) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Inactive',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatCurrency(sub.amount),
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: sub.isActive ? AppColors.expense : Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () => sp.toggleActive(sub),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 44,
                    height: 24,
                    decoration: BoxDecoration(
                      gradient: sub.isActive ? AppColors.gradientIncome : null,
                      color: sub.isActive
                          ? null
                          : Colors.grey.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: sub.isActive
                          ? [
                              BoxShadow(
                                color: AppColors.income.withValues(alpha: 0.4),
                                blurRadius: 6,
                              )
                            ]
                          : [],
                    ),
                    child: AnimatedAlign(
                      duration: const Duration(milliseconds: 200),
                      alignment: sub.isActive
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.all(3),
                        width: 18,
                        height: 18,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
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
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────
class _EmptySubscriptions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
                  color: AppColors.primary.withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(Icons.subscriptions_outlined,
                color: Colors.white, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            'No Subscriptions Yet',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Track your recurring subscriptions to see how much you\'re spending.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 13, color: Colors.grey, height: 1.5),
          ),
        ],
      ),
    );
  }
}

// ── Add Subscription Sheet ────────────────────────────────────────────────────
class _AddSubscriptionSheet extends StatefulWidget {
  final SubscriptionProvider sp;
  const _AddSubscriptionSheet({required this.sp});

  @override
  State<_AddSubscriptionSheet> createState() => _AddSubscriptionSheetState();
}

class _AddSubscriptionSheetState extends State<_AddSubscriptionSheet> {
  final _nameCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  String _billingCycle = 'monthly';
  bool _loading = false;

  final _cycles = ['weekly', 'monthly', 'yearly'];

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
                shaderCallback: (b) =>
                    AppColors.gradientPrimary.createShader(b),
                child: Text(
                  'Add Subscription',
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
                  labelText: 'Service Name',
                  hintText: 'e.g. Netflix, Spotify',
                  prefixIcon: Icon(Icons.subscriptions_outlined),
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
              const SizedBox(height: 12),
              Text(
                'Billing Cycle',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : const Color(0xFFF1F3FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: _cycles.map((c) {
                    final selected = _billingCycle == c;
                    final label = c[0].toUpperCase() + c.substring(1);
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _billingCycle = c),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            gradient:
                                selected ? AppColors.gradientPrimary : null,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: selected
                                ? [
                                    BoxShadow(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.35),
                                      blurRadius: 8,
                                    )
                                  ]
                                : [],
                          ),
                          child: Center(
                            child: Text(
                              label,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: selected ? Colors.white : Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
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
                        await widget.sp.addSubscription(
                          name: name,
                          amount: amount,
                          billingCycle: _billingCycle,
                        );
                        if (context.mounted) Navigator.pop(context);
                      },
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: AppColors.gradientPrimary,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.4),
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
                            'Add Subscription',
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
}
