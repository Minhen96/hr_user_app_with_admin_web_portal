import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:mh_employee_app/core/theme/app_colors.dart';
import 'package:mh_employee_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:mh_employee_app/shared/widgets/modern_app_bar.dart';
import 'package:mh_employee_app/shared/widgets/modern_glass_card.dart';

// Import screens - NEW REDESIGNED VERSIONS
import 'package:mh_employee_app/features/documents/presentation/screens/document_screen.dart';
import 'package:mh_employee_app/features/documents/presentation/screens/company_updates_screen.dart';
import 'package:mh_employee_app/features/leave/presentation/screens/leave_screen_new.dart';
import 'package:mh_employee_app/features/profile/presentation/screens/profile_screen_new.dart';
import 'package:mh_employee_app/features/calendar/presentation/screens/calendar_screen_new.dart';
import 'package:mh_employee_app/features/attendance/presentation/screens/attendance_screen_new.dart';
import 'package:mh_employee_app/features/moments/presentation/screens/moment_screen_new.dart';
import 'package:mh_employee_app/features/handbook/presentation/screens/handbook_screen_new.dart';
import 'package:mh_employee_app/shared/screens/training_screen_new.dart';
import 'package:mh_employee_app/shared/screens/form_screen_new.dart';
import 'package:mh_employee_app/features/auth/data/models/user_model.dart';

class HomeScreenNew extends StatefulWidget {
  const HomeScreenNew({Key? key}) : super(key: key);

  @override
  _HomeScreenNewState createState() => _HomeScreenNewState();
}

class _HomeScreenNewState extends State<HomeScreenNew> {
  int _currentNavIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    setState(() => _currentNavIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _currentNavIndex = index),
        physics: const NeverScrollableScrollPhysics(), // Disable swipe
        children: [
          _buildHomePage(),
          _buildHandbookPage(),
          _buildProfilePage(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        boxShadow: [
          BoxShadow(
            color: isDark
                ? AppColors.glowPrimary.withOpacity(0.1)
                : AppColors.shadow.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 4), // Add padding to prevent overflow
          child: SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  index: 0,
                ),
                _buildNavItem(
                  icon: Icons.menu_book_rounded,
                  label: 'Handbook',
                  index: 1,
                ),
                _buildNavItem(
                  icon: Icons.person_rounded,
                  label: 'Profile',
                  index: 2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _currentNavIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Flexible(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onNavTap(index),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4), // Reduced vertical padding
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(6), // Reduced padding from 8 to 6
                  decoration: isSelected
                      ? BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDark
                                ? AppColors.darkPrimaryGradient
                                : AppColors.primaryGradient,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        )
                      : null,
                  child: Icon(
                    icon,
                    size: 20,
                    color: isSelected
                        ? Colors.white
                        : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                  ),
                ),
                const SizedBox(height: 2), // Reduced from 4 to 2
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected
                        ? (isDark ? AppColors.darkPrimary : AppColors.primary)
                        : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHomePage() {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Modern Header
        SliverToBoxAdapter(
          child: ModernHomeHeader(
            userName: user?.name ?? 'User',
            userRole: user?.role ?? 'Employee',
            notificationCount: 5, // TODO: Get real notification count
            onProfileTap: () => _onNavTap(2),
            onNotificationTap: () {
              // TODO: Navigate to notifications
            },
          ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0),
        ),

        // Company Updates Section - Top Banner
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: ModernGlassCard(
              padding: const EdgeInsets.all(18),
              gradient: AppColors.gradientBlue.map((c) => c.withOpacity(0.08)).toList(),
              onTap: () => _navigateToUpdates(),
              child: Row(
                children: [
                  // Animated Icon Container
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: AppColors.gradientBlue,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.gradientBlue[0].withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.campaign_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Company Updates',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [AppColors.error, Color(0xFFDC2626)],
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                '2 NEW',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.notifications_active_rounded,
                              size: 12,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'Latest news and announcements',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: isDark ? AppColors.darkPrimary : AppColors.primary,
                  ),
                ],
              ),
            ).animate(delay: 100.ms).fadeIn().slideY(begin: -0.2, end: 0).shimmer(duration: 1500.ms, delay: 400.ms),
          ),
        ),

        // Quick Stats Cards
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _navigateToLeave(),
                    child: _buildStatCard(
                      title: 'Leave Days',
                      value: '12',
                      icon: Icons.event_available,
                      gradient: AppColors.gradientBlue,
                    ).animate(delay: 100.ms).fadeIn().scale(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildAttendanceCard().animate(delay: 200.ms).fadeIn().scale(),
                ),
              ],
            ),
          ),
        ),

        // Quick Access Section
        SliverToBoxAdapter(
          child: ModernSectionHeader(
            title: 'Quick Access',
            subtitle: 'Access all features',
            icon: Icons.dashboard_rounded,
          ).animate(delay: 300.ms).fadeIn().slideX(begin: -0.2, end: 0),
        ),

        // Quick Access Grid
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.1,
            ),
            delegate: SliverChildListDelegate([
              // _buildFeatureCard(
              //   title: 'Equipment',
              //   icon: Icons.devices_rounded,
              //   gradient: AppColors.gradientPurple,
              //   onTap: () => _navigateToEquipment(),
              // ).animate(delay: 400.ms).fadeIn().scale(),
              _buildFeatureCard(
                title: 'Calendar',
                icon: Icons.event_note_rounded,
                gradient: AppColors.gradientGreen,
                onTap: () => _navigateToCalendar(),
              ).animate(delay: 450.ms).fadeIn().scale(),
              _buildFeatureCard(
                title: 'Training',
                icon: Icons.school_rounded,
                gradient: AppColors.gradientOrange,
                onTap: () => _navigateTo(TrainingScreenNew()),
              ).animate(delay: 500.ms).fadeIn().scale(),
              _buildFeatureCard(
                title: 'Forms',
                icon: Icons.description_outlined,
                gradient: AppColors.gradientTeal,
                onTap: () => _navigateToForms(),
              ).animate(delay: 550.ms).fadeIn().scale(),
              _buildFeatureCard(
                title: 'Moments',
                icon: Icons.photo_library_rounded,
                gradient: AppColors.gradientPink,
                onTap: () => _navigateTo(MomentsScreenNew()),
              ).animate(delay: 600.ms).fadeIn().scale(),
            ]),
          ),
        ),

        // Bottom padding
        const SliverToBoxAdapter(
          child: SizedBox(height: 100),
        ),
      ],
    );
  }

  Widget _buildHandbookPage() {
    return const HandbookScreenNew();
  }

  Widget _buildProfilePage() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    if (user != null) {
      return ProfileScreenNew(userData: user);
    }
    return const Center(child: Text('Please login'));
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required List<Color> gradient,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ModernGlassCard(
      padding: const EdgeInsets.all(16),
      gradient: gradient.map((c) => c.withOpacity(0.1)).toList(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradient),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: gradient.first.withOpacity(0.4),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              shadows: [
                Shadow(
                  color: isDark ? Colors.black26 : Colors.white38,
                  blurRadius: 2,
                ),
              ],
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceCard() {
    final now = DateTime.now();
    final hour = now.hour;
    final isCheckedIn = hour >= 8 && hour < 18; // Mock check-in status
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ModernGlassCard(
      padding: const EdgeInsets.all(16),
      gradient: AppColors.gradientTeal.map((c) => c.withOpacity(0.1)).toList(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: AppColors.gradientTeal),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gradientTeal.first.withOpacity(0.4),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.access_time_rounded, color: Colors.white, size: 20),
              ),
              Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: (isCheckedIn ? AppColors.success : AppColors.error).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isCheckedIn ? AppColors.success : AppColors.error,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (isCheckedIn ? AppColors.success : AppColors.error).withOpacity(0.5),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            isCheckedIn ? 'Check Out' : 'Check In',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              shadows: [
                Shadow(
                  color: isDark ? Colors.black26 : Colors.white38,
                  blurRadius: 2,
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isCheckedIn ? 'Tap to check out' : 'Tap to check in',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
      onTap: () => _navigateToAttendance(),
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required IconData icon,
    required List<Color> gradient,
    int? badgeCount,
    required VoidCallback onTap,
  }) {
    return ModernFeatureCard(
      icon: icon,
      title: title,
      gradientColors: gradient,
      badgeCount: badgeCount,
      onTap: onTap,
    );
  }

  void _navigateToLeave() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    if (user != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LeaveScreenNew(userData: UserModel.fromEntity(user)),
        ),
      );
    }
  }

  void _navigateToUpdates() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CompanyUpdatesScreen(),
      ),
    );
  }

  void _navigateTo(Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  void _navigateToCalendar() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    if (user != null) {
      _navigateTo(CalendarScreenNew(userData: UserModel.fromEntity(user)));
    }
  }

  void _navigateToAttendance() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    if (user != null) {
      _navigateTo(AttendanceProfileScreenNew(
        username: user.name,
        userid: user.id,
      ));
    }
  }

  void _navigateToForms() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    if (user != null) {
      _navigateTo(FormScreenNew(userData: UserModel.fromEntity(user)));
    }
  }
}
