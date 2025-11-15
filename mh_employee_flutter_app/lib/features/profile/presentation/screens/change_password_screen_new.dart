import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:mh_employee_app/core/theme/app_colors.dart';
import 'package:mh_employee_app/shared/widgets/modern_glass_card.dart';
import 'package:mh_employee_app/shared/widgets/modern_buttons.dart';
import 'package:mh_employee_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:mh_employee_app/services/api_service.dart';
import 'package:mh_employee_app/features/auth/data/models/user_model.dart';
import 'package:mh_employee_app/features/auth/domain/entities/user.dart' as entity;

class ChangePasswordScreenNew extends StatefulWidget {
  final entity.User userData;
  const ChangePasswordScreenNew({Key? key, required this.userData}) : super(key: key);

  @override
  _ChangePasswordScreenNewState createState() => _ChangePasswordScreenNewState();
}

class _ChangePasswordScreenNewState extends State<ChangePasswordScreenNew> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _isRefreshing = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> _refreshUserData() async {
    setState(() {
      _isRefreshing = true;
    });

    try {
      await Provider.of<AuthProvider>(context, listen: false).refreshUserData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to refresh data: ${e.toString()}'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } finally {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await ApiService.requestPasswordChange();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Password change request submitted successfully'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      _refreshUserData();
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _submitPasswordChange() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await ApiService.changePassword(
          currentPassword: _currentPasswordController.text,
          newPassword: _newPasswordController.text,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Password changed successfully'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );

        _refreshUserData();
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showUserGuide() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: ModernElevatedCard(
            padding: EdgeInsets.zero,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Gradient Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: AppColors.primaryGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.help_outline_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          'User Guide',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildGuideItem(
                        '1',
                        'Type in the old password correctly.',
                        isDark,
                      ),
                      const SizedBox(height: 12),
                      _buildGuideItem(
                        '2',
                        'Insert a new password with at least 8 characters, lowercase, uppercase, and digit.',
                        isDark,
                      ),
                      const SizedBox(height: 12),
                      _buildGuideItem(
                        '3',
                        'Insert again the new password for confirmation.',
                        isDark,
                      ),
                      const SizedBox(height: 12),
                      _buildGuideItem(
                        '4',
                        'Click the eye icon to check the form.',
                        isDark,
                      ),
                      const SizedBox(height: 12),
                      _buildGuideItem(
                        '5',
                        'Submit and wait for the confirmation from admin.',
                        isDark,
                      ),
                    ],
                  ),
                ),
                // Close Button
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: ModernGradientButton(
                    text: 'Got it',
                    icon: Icons.check_rounded,
                    onPressed: () => Navigator.pop(context),
                    gradientColors: AppColors.primaryGradient,
                    width: double.infinity,
                  ),
                ),
              ],
            ),
          ).animate().scale(duration: 300.ms),
        );
      },
    );
  }

  Widget _buildGuideItem(String number, String text, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: AppColors.primaryGradient),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback onToggle,
    required bool isDark,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(
        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
        ),
        prefixIcon: Icon(
          Icons.lock_rounded,
          color: isDark ? AppColors.darkPrimary : AppColors.primary,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off_rounded : Icons.visibility_rounded,
            color: isDark ? AppColors.darkPrimary : AppColors.primary,
          ),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: isDark ? AppColors.darkSurfaceVariant : AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.border,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? AppColors.darkPrimary : AppColors.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildPasswordChangeForm(bool isDark) {
    return Form(
      key: _formKey,
      child: ModernGlassCard(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: AppColors.primaryGradient),
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  child: const Icon(
                    Icons.vpn_key_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Change Password',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildPasswordField(
              controller: _currentPasswordController,
              label: 'Current Password',
              obscureText: _obscureCurrentPassword,
              onToggle: () => setState(() => _obscureCurrentPassword = !_obscureCurrentPassword),
              isDark: isDark,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your current password';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildPasswordField(
              controller: _newPasswordController,
              label: 'New Password',
              obscureText: _obscureNewPassword,
              onToggle: () => setState(() => _obscureNewPassword = !_obscureNewPassword),
              isDark: isDark,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a new password';
                }
                if (value.length < 8) {
                  return 'Password must be at least 8 characters';
                }
                if (!value.contains(RegExp(r'[a-z]'))) {
                  return 'Password must contain lowercase letter';
                }
                if (!value.contains(RegExp(r'[A-Z]'))) {
                  return 'Password must contain uppercase letter';
                }
                if (!value.contains(RegExp(r'[0-9]'))) {
                  return 'Password must contain digit';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildPasswordField(
              controller: _confirmPasswordController,
              label: 'Confirm New Password',
              obscureText: _obscureConfirmPassword,
              onToggle: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
              isDark: isDark,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm your new password';
                }
                if (value != _newPasswordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            const SizedBox(height: 30),
            ModernGradientButton(
              text: 'Change Password',
              icon: Icons.check_rounded,
              onPressed: _isLoading ? null : _submitPasswordChange,
              gradientColors: AppColors.gradientGreen,
              width: double.infinity,
            ),
          ],
        ),
      ).animate(delay: 100.ms).fadeIn().slideX(begin: 0.2, end: 0),
    );
  }

  Widget _buildRequestForm(User userData, bool isDark) {
    return ModernGlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: AppColors.gradientOrange),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_clock_rounded,
              color: Colors.white,
              size: 48,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Password Change Request',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            userData.status == Status.pending
                ? 'Your password change request is pending admin approval.'
                : 'You need to request admin approval to change your password.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          if (userData.changePasswordDate != null) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (isDark ? AppColors.darkPrimary : AppColors.primary).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColors.darkPrimary : AppColors.primary,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.history_rounded,
                    color: isDark ? AppColors.darkPrimary : AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Last password change: ${DateFormat('MMM dd, yyyy').format(userData.changePasswordDate!)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 30),
          if (userData.status != Status.pending)
            ModernGradientButton(
              text: 'Request Password Change',
              icon: Icons.send_rounded,
              onPressed: _isLoading ? null : _submitRequest,
              gradientColors: AppColors.primaryGradient,
              width: double.infinity,
            ),
        ],
      ),
    ).animate(delay: 100.ms).fadeIn().scale();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;
        final userData = user != null ? UserModel.fromEntity(user) : null;

        return Scaffold(
          backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
          body: RefreshIndicator(
            color: isDark ? AppColors.darkPrimary : AppColors.primary,
            onRefresh: _refreshUserData,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // Modern Gradient App Bar
                SliverAppBar(
                  expandedHeight: 150,
                  floating: false,
                  pinned: true,
                  flexibleSpace: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: AppColors.primaryGradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: FlexibleSpaceBar(
                      title: const Text(
                        'Password Change',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      centerTitle: false,
                      titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
                      background: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 60, right: 20),
                          child: Align(
                            alignment: Alignment.topRight,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.security_rounded,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ModernIconButton(
                        icon: Icons.help_outline_rounded,
                        onPressed: _showUserGuide,
                        size: 40,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        iconColor: Colors.white,
                      ),
                    ),
                  ],
                ),

                // Content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: _isRefreshing
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(100),
                              child: CircularProgressIndicator(
                                color: isDark ? AppColors.darkPrimary : AppColors.primary,
                              ),
                            ),
                          )
                        : userData == null
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.error_outline_rounded,
                                      size: 48,
                                      color: AppColors.error,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'User data not available',
                                      style: TextStyle(
                                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : userData.status == Status.approved
                                ? _buildPasswordChangeForm(isDark)
                                : _buildRequestForm(userData, isDark),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
