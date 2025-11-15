import 'package:flutter/material.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_decorations.dart';
import '../../../../../core/widgets/cards/modern_card.dart';

/// Modern Welcome Section with Glassmorphic Design
class WelcomeSection extends StatelessWidget {
  final String userName;
  final VoidCallback? onWelcomeTap;

  const WelcomeSection({
    Key? key,
    required this.userName,
    this.onWelcomeTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.lg),

          // Divider
          Divider(
            color: Theme.of(context).dividerColor,
            thickness: 1.0,
          ),

          const SizedBox(height: AppSpacing.lg),

          // Welcome Card
          Container(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              children: [
                // Welcome Text with tap gesture for testing
                GestureDetector(
                  onTap: onWelcomeTap,
                  child: Text(
                    'Welcome to MH, $userName!',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // Description
                Text(
                  "We're excited to have you as part of our team. Access company resources and stay connected with our community.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                    height: 1.5,
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
