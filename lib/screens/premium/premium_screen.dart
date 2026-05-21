import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/premium_provider.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  static const _features = [
    _Feature(
      icon: Icons.account_balance_rounded,
      title: 'Bank Account Linking',
      body: 'Connect your banks via Plaid for automatic transaction import.',
      gradient: AppColors.gradientPrimary,
    ),
    _Feature(
      icon: Icons.credit_score_rounded,
      title: 'Credit Score Monitoring',
      body: 'Track your credit score and get tips to improve it.',
      gradient: AppColors.gradientSavings,
    ),
    _Feature(
      icon: Icons.auto_awesome_rounded,
      title: 'AI Financial Assistant',
      body: 'Unlimited AI chat to answer any financial question.',
      gradient: AppColors.gradientIncome,
    ),
    _Feature(
      icon: Icons.notifications_active_rounded,
      title: 'Smart Alerts',
      body: 'Get notified about bills, budget limits, and unusual spending.',
      gradient: AppColors.gradientExpense,
    ),
    _Feature(
      icon: Icons.bar_chart_rounded,
      title: 'Advanced Insights',
      body: 'Month-over-month trends, spending forecasts, and more.',
      gradient: AppColors.gradientPrimary,
    ),
    _Feature(
      icon: Icons.file_download_rounded,
      title: 'Export Reports',
      body: 'Export your finances to CSV or PDF for tax prep.',
      gradient: AppColors.gradientSavings,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final premium = context.watch<PremiumProvider>();

    return Scaffold(
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: const BoxDecoration(gradient: AppColors.gradientBg),
          ),
          // Orbs
          Positioned(
            top: -80,
            right: -60,
            child: _Orb(size: 280, color: Colors.white.withValues(alpha: 0.06)),
          ),
          Positioned(
            bottom: 100,
            left: -60,
            child: _Orb(size: 200, color: Colors.white.withValues(alpha: 0.05)),
          ),

          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.close_rounded,
                              color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                    child: Column(
                      children: [
                        // Crown icon
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.4),
                                width: 2),
                          ),
                          child: const Icon(Icons.workspace_premium_rounded,
                              size: 40, color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'SuperSave Premium',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Unlock everything to take full\ncontrol of your finances.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            color: Colors.white.withValues(alpha: 0.8),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Pricing card
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.3),
                                    width: 1),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _PriceTile(
                                      label: 'Monthly',
                                      price: '\$9.99',
                                      sub: 'per month',
                                      isHighlighted: false,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _PriceTile(
                                      label: 'Annual',
                                      price: '\$59.99',
                                      sub: '\$5/month · Save 40%',
                                      isHighlighted: true,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Features list
                        ...(_features.map(
                          (f) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: BackdropFilter(
                                filter:
                                    ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                        color:
                                            Colors.white.withValues(alpha: 0.2),
                                        width: 1),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 42,
                                        height: 42,
                                        decoration: BoxDecoration(
                                          gradient: f.gradient,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Icon(f.icon,
                                            color: Colors.white, size: 20),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              f.title,
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white,
                                              ),
                                            ),
                                            Text(
                                              f.body,
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                fontSize: 12,
                                                color: Colors.white
                                                    .withValues(alpha: 0.7),
                                                height: 1.4,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(Icons.check_circle_rounded,
                                          color: Color(0xFF34D399), size: 22),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )),

                        const SizedBox(height: 24),

                        // CTA button
                        GestureDetector(
                          onTap: () async {
                            // TODO: Integrate RevenueCat/Stripe purchase flow
                            // For now, simulate premium unlock
                            await context
                                .read<PremiumProvider>()
                                .setPremium(true);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '🎉 Welcome to Premium!',
                                    style: GoogleFonts.plusJakartaSans(
                                        fontWeight: FontWeight.w600),
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  backgroundColor: AppColors.income,
                                ),
                              );
                              Navigator.pop(context);
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.25),
                                  blurRadius: 24,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                'Start Free Trial — 7 Days Free',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Cancel anytime · No commitment',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.6)),
                        ),
                      ],
                    ),
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

class _PriceTile extends StatelessWidget {
  final String label, price, sub;
  final bool isHighlighted;
  const _PriceTile(
      {required this.label,
      required this.price,
      required this.sub,
      required this.isHighlighted});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isHighlighted
            ? Colors.white.withValues(alpha: 0.25)
            : Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isHighlighted ? Colors.white : Colors.transparent,
            width: 1.5),
      ),
      child: Column(
        children: [
          if (isHighlighted)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFFBBF24),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('BEST VALUE',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: Colors.black)),
            ),
          if (isHighlighted) const SizedBox(height: 6),
          Text(label,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 12, color: Colors.white.withValues(alpha: 0.75))),
          Text(price,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Colors.white)),
          Text(sub,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 10, color: Colors.white.withValues(alpha: 0.65))),
        ],
      ),
    );
  }
}

class _Feature {
  final IconData icon;
  final String title, body;
  final LinearGradient gradient;
  const _Feature(
      {required this.icon,
      required this.title,
      required this.body,
      required this.gradient});
}

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
