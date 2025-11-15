import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mh_employee_app/core/theme/app_colors.dart';
import 'package:mh_employee_app/features/auth/data/models/user_model.dart';
import 'package:mh_employee_app/shared/widgets/modern_glass_card.dart';
import 'package:mh_employee_app/shared/widgets/modern_app_bar.dart';
import 'package:mh_employee_app/features/leave/presentation/screens/AN_Leave_new.dart';
import 'package:mh_employee_app/features/leave/presentation/screens/MC_Leave_new.dart';

class LeaveScreenNew extends StatefulWidget {
  final User userData;
  const LeaveScreenNew({super.key, required this.userData});

  @override
  _LeaveScreenNewState createState() => _LeaveScreenNewState();
}

class _LeaveScreenNewState extends State<LeaveScreenNew> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Modern Gradient App Bar
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            automaticallyImplyLeading: false,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: AppColors.gradientBlue,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: FlexibleSpaceBar(
                centerTitle: false,
                title: const Text(
                  'Leave Management',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
                background: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 60, left: 20, right: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Request & Track Leave',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
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
              Container(
                margin: const EdgeInsets.only(right: 16),
                child: CircleAvatar(
                  backgroundColor: Colors.white24,
                  child: Text(
                    widget.userData.fullName[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Tab Selector
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: ModernGlassCard(
                padding: const EdgeInsets.all(4),
                gradient: AppColors.gradientBlue.map((c) => c.withOpacity(0.1)).toList(),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    gradient: const LinearGradient(colors: AppColors.gradientBlue),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.glowPrimary,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.textSecondary,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  tabs: const [
                    Tab(
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.medical_services_rounded, size: 20),
                          SizedBox(width: 8),
                          Text('Medical Leave'),
                        ],
                      ),
                    ),
                    Tab(
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calendar_today_rounded, size: 20),
                          SizedBox(width: 8),
                          Text('Annual Leave'),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate(delay: 100.ms).fadeIn().slideY(begin: -0.2, end: 0),
            ),
          ),

          // Tab Content
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                McLeaveScreenNew(
                  username: widget.userData.fullName,
                  email: widget.userData.email,
                  userid: int.parse(widget.userData.id),
                ),
                AnnualLeaveScreenNew(
                  userid: int.parse(widget.userData.id),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
