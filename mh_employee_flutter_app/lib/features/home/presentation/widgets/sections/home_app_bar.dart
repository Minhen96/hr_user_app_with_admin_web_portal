import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/theme/theme_provider.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/widgets/buttons/modern_button.dart';
import '../../../../profile/presentation/screens/profile_screen_new.dart';
import '../../../../auth/domain/entities/user.dart' as entity;

/// Modern App Bar for Home Screen
class HomeAppBar extends StatelessWidget {
  final entity.User? user;
  final VoidCallback? onLogoTap;
  final VoidCallback? onCompanyTap;

  const HomeAppBar({
    Key? key,
    this.user,
    this.onLogoTap,
    this.onCompanyTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          // Company Logo
          _buildLogo(context),
          const SizedBox(width: AppSpacing.lg),

          // Company Info
          Expanded(
            child: _buildCompanyInfo(context),
          ),

          // Theme Toggle
          _buildThemeToggle(context),
          const SizedBox(width: AppSpacing.sm),

          // Profile Button
          _buildProfileButton(context),
        ],
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    return GestureDetector(
      onTap: onLogoTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipOval(
          child: Image.asset(
            'assets/images/company-logo.jpg',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildCompanyInfo(BuildContext context) {
    return GestureDetector(
      onTap: onCompanyTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'MH',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Employee Portal',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
              letterSpacing: 0.85,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeToggle(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return ModernIconButton(
          icon: themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
          iconColor: Theme.of(context).iconTheme.color,
          tooltip: themeProvider.isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
          onPressed: () {
            themeProvider.toggleTheme();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  themeProvider.isDarkMode ? 'Dark mode enabled' : 'Light mode enabled',
                ),
                duration: const Duration(seconds: 1),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProfileButton(BuildContext context) {
    return ModernIconButton(
      icon: Icons.person,
      iconColor: Theme.of(context).iconTheme.color,
      tooltip: 'Profile',
      onPressed: () {
        if (user != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfileScreenNew(userData: user!),
            ),
          );
        }
      },
    );
  }
}
