import 'package:flutter/material.dart';
import '../theme/theme.dart';

class PremiumButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final double height;

  const PremiumButton({
    super.key,
    required this.text,
    this.onTap,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height = 54.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onTap == null || isLoading;

    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        gradient: isDisabled
            ? LinearGradient(
                colors: [
                  AppTheme.royalPurple.withValues(alpha: 0.5),
                  AppTheme.electricBlue.withValues(alpha: 0.5),
                ],
              )
            : AppTheme.premiumGradient,
        borderRadius: BorderRadius.circular(14),
        boxShadow: isDisabled
            ? []
            : [
                BoxShadow(
                  color: AppTheme.royalPurple.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled ? null : onTap,
          borderRadius: BorderRadius.circular(14),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: AppTheme.softWhite,
                      strokeWidth: 2.5,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, color: AppTheme.softWhite, size: 20),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        text,
                        style: const TextStyle(
                          color: AppTheme.softWhite,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
