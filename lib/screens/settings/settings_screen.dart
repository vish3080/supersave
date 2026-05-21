import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/finance_provider.dart';
import '../../widgets/common_widgets.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final fp = context.watch<FinanceProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          // Profile card
          AppCard(
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
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
                      color: Colors.white, size: 26),
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
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.income.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Active',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.income,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Stats section
          SectionTitle('Your Data'),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _StatRow(
                  icon: Icons.tag_rounded,
                  gradient: AppColors.gradientPrimary,
                  label: 'Categories',
                  value: '${fp.categories.length}',
                  isDark: isDark,
                  isFirst: true,
                ),
                _Divider(),
                _StatRow(
                  icon: Icons.receipt_long_rounded,
                  gradient: AppColors.gradientExpense,
                  label: 'Expenses this month',
                  value: '${fp.expenses.length}',
                  isDark: isDark,
                ),
                _Divider(),
                _StatRow(
                  icon: Icons.savings_rounded,
                  gradient: AppColors.gradientSavings,
                  label: 'Savings Goals',
                  value: '${fp.savingsGoals.length}',
                  isDark: isDark,
                ),
                _Divider(),
                _StatRow(
                  icon: Icons.account_balance_wallet_rounded,
                  gradient: AppColors.gradientIncome,
                  label: 'Total saved this month',
                  value: formatCurrency(fp.savings),
                  isDark: isDark,
                  isLast: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // App info
          SectionTitle('About'),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _InfoRow(
                  icon: Icons.info_outline_rounded,
                  label: 'Version',
                  trailing: '1.0.0',
                  isDark: isDark,
                  isFirst: true,
                ),
                _Divider(),
                _InfoRow(
                  icon: Icons.cloud_done_outlined,
                  label: 'Backend',
                  trailing: 'Supabase',
                  isDark: isDark,
                  isLast: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Sign out
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
                border: Border.all(
                    color: AppColors.expense.withValues(alpha: 0.2), width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.logout_rounded,
                      color: AppColors.expense, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    'Sign Out',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.expense,
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

// ── Stat Row ──────────────────────────────────────────────────────────────────
class _StatRow extends StatelessWidget {
  final IconData icon;
  final LinearGradient gradient;
  final String label;
  final String value;
  final bool isDark;
  final bool isFirst;
  final bool isLast;

  const _StatRow({
    required this.icon,
    required this.gradient,
    required this.label,
    required this.value,
    required this.isDark,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(20) : Radius.zero,
          bottom: isLast ? const Radius.circular(20) : Radius.zero,
        ),
      ),
      child: Row(
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
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : const Color(0xFF1A1A2E),
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF1A1A2E),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Info Row ──────────────────────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String trailing;
  final bool isDark;
  final bool isFirst;
  final bool isLast;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.trailing,
    required this.isDark,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon,
              size: 20,
              color:
                  isDark ? Colors.white.withValues(alpha: 0.5) : Colors.grey),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: isDark ? Colors.white : const Color(0xFF1A1A2E)),
            ),
          ),
          Text(
            trailing,
            style:
                GoogleFonts.plusJakartaSans(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

// ── Divider ───────────────────────────────────────────────────────────────────
class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: isDark
          ? Colors.white.withValues(alpha: 0.06)
          : const Color(0xFFEEEEFF),
    );
  }
}
