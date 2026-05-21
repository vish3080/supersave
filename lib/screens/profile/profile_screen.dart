import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/finance_provider.dart';
import '../../providers/wealth_provider.dart';
import '../../providers/bills_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../providers/premium_provider.dart';
import '../../widgets/common_widgets.dart';
import '../budget/budget_screen.dart';
import '../networth/net_worth_screen.dart';
import '../debt/debt_screen.dart';
import '../subscriptions/subscriptions_screen.dart';
import '../bills/bills_screen.dart';
import '../settings/settings_screen.dart';
import '../premium/premium_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final fp = context.watch<FinanceProvider>();
    final wp = context.watch<WealthProvider>();
    final bp = context.watch<BillsProvider>();
    final sp = context.watch<SubscriptionProvider>();
    final premium = context.watch<PremiumProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        children: [
          // ── Profile card ──────────────────────────────────────────────────
          AppCard(
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: AppColors.gradientPrimary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.person_rounded,
                      color: Colors.white, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My Account',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color:
                              isDark ? Colors.white : const Color(0xFF1A1A2E),
                        ),
                      ),
                      Text(
                        'ID: ${(auth.userId ?? '—').substring(0, 8)}…',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const PremiumScreen())),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: premium.isPremium
                          ? AppColors.gradientIncome
                          : const LinearGradient(
                              colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)]),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      premium.isPremium ? '✓ Premium' : '⭐ Upgrade',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Net worth quick view ──────────────────────────────────────────
          GestureDetector(
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const NetWorthScreen())),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: wp.netWorth >= 0
                    ? AppColors.gradientIncome
                    : AppColors.gradientExpense,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: (wp.netWorth >= 0
                            ? AppColors.income
                            : AppColors.expense)
                        .withValues(alpha: 0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.account_balance_rounded,
                      color: Colors.white, size: 28),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Net Worth',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                      Text(
                        formatCurrency(wp.netWorth),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.arrow_forward_ios_rounded,
                        color: Colors.white, size: 16),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Quick stats row ───────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _QuickStat(
                  label: 'Bills/mo',
                  value: formatCurrency(bp.totalMonthlyBills),
                  icon: Icons.receipt_outlined,
                  gradient: AppColors.gradientPrimary,
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const BillsScreen())),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickStat(
                  label: 'Subs/mo',
                  value: formatCurrency(sp.monthlyTotal),
                  icon: Icons.subscriptions_outlined,
                  gradient: AppColors.gradientExpense,
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const SubscriptionsScreen())),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Tools section ─────────────────────────────────────────────────
          SectionTitle('Financial Tools'),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _NavTile(
                  icon: Icons.credit_card_rounded,
                  gradient: AppColors.gradientPrimary,
                  label: 'Budget & Categories',
                  subtitle: '${fp.categories.length} categories',
                  isDark: isDark,
                  isFirst: true,
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const BudgetScreen())),
                ),
                _NavTile(
                  icon: Icons.trending_down_rounded,
                  gradient: AppColors.gradientExpense,
                  label: 'Debt Payoff Planner',
                  subtitle: '${wp.debts.length} debts tracked',
                  isDark: isDark,
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const DebtScreen())),
                ),
                _NavTile(
                  icon: Icons.subscriptions_rounded,
                  gradient: const LinearGradient(
                      colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA)]),
                  label: 'Subscriptions',
                  subtitle:
                      '${sp.activeSubscriptions.length} active · ${formatCurrency(sp.monthlyTotal)}/mo',
                  isDark: isDark,
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const SubscriptionsScreen())),
                ),
                _NavTile(
                  icon: Icons.notifications_rounded,
                  gradient: AppColors.gradientSavings,
                  label: 'Bills & Reminders',
                  subtitle: bp.overdueBills.isNotEmpty
                      ? '${bp.overdueBills.length} overdue!'
                      : '${bp.bills.length} bills tracked',
                  isDark: isDark,
                  isDanger: bp.overdueBills.isNotEmpty,
                  isLast: true,
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const BillsScreen())),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Account section ───────────────────────────────────────────────
          SectionTitle('Account'),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _NavTile(
                  icon: Icons.workspace_premium_rounded,
                  gradient: const LinearGradient(
                      colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)]),
                  label: premium.isPremium
                      ? 'Premium Active'
                      : 'Upgrade to Premium',
                  subtitle: premium.isPremium
                      ? 'All features unlocked'
                      : 'Bank linking, AI chat, credit score & more',
                  isDark: isDark,
                  isFirst: true,
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const PremiumScreen())),
                ),
                _NavTile(
                  icon: Icons.settings_rounded,
                  gradient: const LinearGradient(
                      colors: [Color(0xFF6B7280), Color(0xFF9CA3AF)]),
                  label: 'Settings',
                  subtitle: 'Version 1.0.0 · Supabase',
                  isDark: isDark,
                  isLast: true,
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const SettingsScreen())),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Sign out ──────────────────────────────────────────────────────
          GestureDetector(
            onTap: () => showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                title: Text('Sign Out?',
                    style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700)),
                content: const Text('You will need to sign in again.'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel')),
                  FilledButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      auth.signOut();
                    },
                    style: FilledButton.styleFrom(
                        backgroundColor: AppColors.expense),
                    child: const Text('Sign Out'),
                  ),
                ],
              ),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.expense.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
                border:
                    Border.all(color: AppColors.expense.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.logout_rounded,
                      color: AppColors.expense, size: 20),
                  const SizedBox(width: 10),
                  Text('Sign Out',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.expense)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Quick Stat ────────────────────────────────────────────────────────────────
class _QuickStat extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const _QuickStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 18),
            ),
            const SizedBox(height: 10),
            Text(value,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : const Color(0xFF1A1A2E))),
            Text(label,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

// ── Nav Tile ──────────────────────────────────────────────────────────────────
class _NavTile extends StatelessWidget {
  final IconData icon;
  final LinearGradient gradient;
  final String label, subtitle;
  final bool isDark;
  final bool isFirst;
  final bool isLast;
  final bool isDanger;
  final VoidCallback onTap;

  const _NavTile({
    required this.icon,
    required this.gradient,
    required this.label,
    required this.subtitle,
    required this.isDark,
    this.isFirst = false,
    this.isLast = false,
    this.isDanger = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.vertical(
            top: isFirst ? const Radius.circular(20) : Radius.zero,
            bottom: isLast ? const Radius.circular(20) : Radius.zero,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color:
                                isDark ? Colors.white : const Color(0xFF1A1A2E),
                          )),
                      Text(subtitle,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: isDanger ? AppColors.expense : Colors.grey,
                            fontWeight:
                                isDanger ? FontWeight.w600 : FontWeight.w400,
                          )),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    color: Colors.grey.withValues(alpha: 0.5), size: 20),
              ],
            ),
          ),
        ),
        if (!isLast)
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : const Color(0xFFEEEEFF),
          ),
      ],
    );
  }
}
