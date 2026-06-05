import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/premium_button.dart';
import '../../../../core/constants/app_constants.dart';
import '../../providers/subscription_provider.dart';
import '../../../auth/providers/auth_provider.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  void _handleSubscribe(BuildContext context, String planId, String price) async {
    final subProvider = Provider.of<SubscriptionProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Call checkout api
    final checkoutResult = await subProvider.checkout(planId);

    if (checkoutResult != null && context.mounted) {
      final orderId = checkoutResult['orderId'] as String;
      
      // Simulate Payment gateway screen / Razorpay prompt success
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            backgroundColor: AppTheme.cardGrey,
            title: const Text('Razorpay Gateway', style: TextStyle(color: AppTheme.softWhite)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.payment, color: AppTheme.royalPurple, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Processing payment of ₹$price via UPI/Card...',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppTheme.silverAccent),
                ),
              ],
            ),
            actions: [
              TextButton(
                child: const Text('Cancel', style: TextStyle(color: AppTheme.errorRed)),
                onPressed: () => Navigator.pop(context),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.royalPurple),
                child: const Text('Simulate Success'),
                onPressed: () async {
                  Navigator.pop(context); // Close gateway dialog
                  
                  // Call verify API
                  final success = await subProvider.verifyPayment(
                    orderId: orderId,
                    paymentId: 'pay_mock_${DateTime.now().millisecondsSinceEpoch}',
                    signature: 'mock_signature',
                    planId: planId,
                  );

                  if (success && context.mounted) {
                    // Refresh session in auth state
                    await authProvider.login(authProvider.currentUser?.email ?? 'user@vanix.com', 'userpassword123');
                    
                    if (context.mounted) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: AppTheme.cardGrey,
                          title: const Text('Success!'),
                          content: const Text('Welcome to the Premium tier! Your subscription is now active.'),
                          actions: [
                            TextButton(
                              child: const Text('Start Streaming'),
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.pop(context); // Go back to profile screen
                              },
                            )
                          ],
                        ),
                      );
                    }
                  }
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const plans = AppConstants.subscriptionPlans;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Premium Plans'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Choose Your Universe',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                'Select a subscription tier to activate Dolby Atmos and 4K HDR streams.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.silverAccent.withValues(alpha: 0.6), fontSize: 13),
              ),
              const SizedBox(height: 32),

              // Plans Card list
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: plans.length,
                itemBuilder: (context, index) {
                  final plan = plans[index];
                  final isPremium = plan['id'] == 'premium';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    child: GlassCard(
                      padding: const EdgeInsets.all(24),
                      opacity: isPremium ? 0.12 : 0.06,
                      color: isPremium ? AppTheme.royalPurple : Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isPremium)
                            Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [Colors.amber, Colors.orange]),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'RECOMMENDED TIER',
                                style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black),
                              ),
                            ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                plan['name'] as String,
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.softWhite),
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    '₹${plan['price']}',
                                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppTheme.softWhite),
                                  ),
                                  Text(
                                    ' / ${plan['duration']}',
                                    style: TextStyle(fontSize: 12, color: AppTheme.silverAccent.withValues(alpha: 0.6)),
                                  ),
                                ],
                              )
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Divider(color: Colors.white10),
                          const SizedBox(height: 16),
                          ...List.generate((plan['features'] as List).length, (fIdx) {
                            final feature = (plan['features'] as List)[fIdx] as String;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                children: [
                                  const Icon(Icons.check, color: AppTheme.royalPurple, size: 18),
                                  const SizedBox(width: 12),
                                  Text(
                                    feature,
                                    style: const TextStyle(color: AppTheme.silverAccent, fontSize: 13),
                                  ),
                                ],
                              ),
                            );
                          }),
                          const SizedBox(height: 24),
                          PremiumButton(
                            text: plan['price'] == '0' ? 'Free Tier' : 'Upgrade Plan',
                            onTap: plan['price'] == '0'
                                ? null
                                : () => _handleSubscribe(context, plan['id'] as String, plan['price'] as String),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: (index * 150).ms, duration: 400.ms);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
