import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:mh_employee_app/core/theme/app_colors.dart';
import 'package:mh_employee_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:mh_employee_app/services/api_service.dart';
import 'package:mh_employee_app/features/auth/data/models/user_model.dart';
import 'package:mh_employee_app/features/auth/domain/entities/user.dart' as entity;
import 'package:mh_employee_app/features/auth/presentation/screens/login_screen_new.dart';
import 'package:mh_employee_app/shared/widgets/modern_glass_card.dart';
import 'package:mh_employee_app/shared/widgets/modern_buttons.dart';
import 'package:mh_employee_app/shared/widgets/modern_app_bar.dart';
import 'dart:typed_data';

class ProfileScreenNew extends StatefulWidget {
  final entity.User userData;
  const ProfileScreenNew({Key? key, required this.userData}) : super(key: key);

  @override
  State<ProfileScreenNew> createState() => _ProfileScreenNewState();
}

class _ProfileScreenNewState extends State<ProfileScreenNew> {
  late UserModel _currentUserData;
  Uint8List? _profilePicture;
  final TextEditingController _nicknameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.userData == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _refreshProfile();
      });
    } else {
      _currentUserData = UserModel.fromEntity(widget.userData!);
      _profilePicture = _currentUserData.profilePicture;
    }
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  String _getDisplayName() {
    if (_currentUserData.nickname != null && _currentUserData.nickname.isNotEmpty) {
      return _currentUserData.nickname;
    }
    return _currentUserData.fullName ?? 'Unknown Name';
  }

  Future<void> _refreshProfile() async {
    try {
      await context.read<AuthProvider>().refreshUserData();
      final updatedUser = context.read<AuthProvider>().currentUser;

      if (updatedUser != null) {
        setState(() {
          _currentUserData = UserModel.fromEntity(updatedUser);
          _profilePicture = _currentUserData.profilePicture;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to refresh profile'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to refresh profile: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _showNicknameDialog() async {
    _nicknameController.text = _currentUserData.nickname ?? '';

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: AppColors.primaryGradient),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.edit, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Edit Nickname',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          content: TextField(
            controller: _nicknameController,
            decoration: InputDecoration(
              hintText: 'Enter your nickname',
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
            autofocus: true,
          ),
          actions: [
            ModernOutlineButton(
              text: 'Cancel',
              onPressed: () => Navigator.pop(context),
              borderColor: AppColors.primary,
              textColor: AppColors.primary,
            ),
            ModernGradientButton(
              text: 'Save',
              onPressed: () async {
                try {
                  await _updateNickname(_nicknameController.text);
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to update nickname: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
              gradientColors: AppColors.primaryGradient,
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateNickname(String nickname) async {
    try {
      final response = await ApiService.updateNickname(nickname);
      if (response) {
        await _refreshProfile();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nickname updated successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      throw Exception('Failed to update nickname: $e');
    }
  }

  Future<void> _handleProfilePictureUpload() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1000,
      maxHeight: 1000,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      try {
        final profilePicture = await pickedFile.readAsBytes();
        await ApiService.uploadProfilePicture(profilePicture);
        await _refreshProfile();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile picture updated successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload profile picture: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: ModernGlassCard(
            padding: const EdgeInsets.all(32),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: AppColors.primary),
                SizedBox(height: 16),
                Text(
                  'Logging out...',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    try {
      await context.read<AuthProvider>().logout();
      Navigator.of(context).pop();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginScreenNew()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Error logging out. Please try again.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUserData == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _refreshProfile,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Modern Gradient Header
            SliverAppBar(
              expandedHeight: 280,
              floating: false,
              pinned: true,
              automaticallyImplyLeading: false,
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: AppColors.primaryGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: FlexibleSpaceBar(
                  centerTitle: true,
                  title: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getDisplayName(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  background: SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 60),
                        // Profile Avatar with Edit Button
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 4),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.glowPrimary,
                                    spreadRadius: 8,
                                    blurRadius: 20,
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 60,
                                backgroundColor: Colors.white24,
                                backgroundImage: _currentUserData.profilePicture != null
                                    ? MemoryImage(_currentUserData.profilePicture!)
                                    : null,
                                child: _currentUserData.profilePicture == null
                                    ? const Icon(Icons.person, size: 60, color: Colors.white)
                                    : null,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: ModernIconButton(
                                icon: Icons.camera_alt,
                                onPressed: _handleProfilePictureUpload,
                                size: 40,
                                gradientColors: AppColors.accentGradient,
                              ),
                            ),
                          ],
                        ).animate().scale(delay: 100.ms, duration: 400.ms),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _currentUserData.department?.name ?? 'No Department',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.white, size: 18),
                              onPressed: _showNicknameDialog,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Profile Information Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ModernSectionHeader(
                      title: 'Personal Information',
                      subtitle: 'Your account details',
                      icon: Icons.person_rounded,
                    ).animate(delay: 200.ms).fadeIn().slideX(begin: -0.2, end: 0),

                    const SizedBox(height: 16),

                    // Info Cards
                    ModernElevatedCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          _buildInfoRow(Icons.email_rounded, 'Email', _currentUserData.email ?? 'N/A'),
                          const Divider(height: 32),
                          _buildInfoRow(Icons.badge_rounded, 'NRIC', _currentUserData.nric ?? 'N/A'),
                          const Divider(height: 32),
                          _buildInfoRow(Icons.confirmation_number_rounded, 'TIN', _currentUserData.tin ?? 'N/A'),
                          const Divider(height: 32),
                          _buildInfoRow(Icons.account_balance_rounded, 'EPF', _currentUserData.epf ?? 'N/A'),
                        ],
                      ),
                    ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.2, end: 0),

                    const SizedBox(height: 24),

                    // Logout Button
                    ModernGradientButton(
                      text: 'Logout',
                      icon: Icons.logout_rounded,
                      onPressed: () => _handleLogout(context),
                      gradientColors: [AppColors.error, const Color(0xFFDC2626)],
                      height: 56,
                    ).animate(delay: 400.ms).fadeIn().scale(),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: AppColors.primaryGradient),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.4),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  shadows: [
                    Shadow(
                      color: isDark ? Colors.black26 : Colors.white38,
                      blurRadius: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
