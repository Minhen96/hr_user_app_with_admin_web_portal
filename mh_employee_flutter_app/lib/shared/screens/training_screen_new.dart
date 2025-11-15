import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mh_employee_app/core/theme/app_colors.dart';
import 'package:mh_employee_app/services/api_service.dart';
import 'package:mh_employee_app/features/training/data/models/training_record_model.dart';
import 'package:mh_employee_app/features/training/presentation/widgets/training_card.dart';
import 'package:mh_employee_app/features/training/presentation/screens/add_training_screen.dart';
import 'package:mh_employee_app/shared/widgets/modern_glass_card.dart';
import 'package:mh_employee_app/shared/widgets/modern_page_template.dart';
import 'package:mh_employee_app/shared/widgets/modern_buttons.dart';

// Import TrainingStatus enum
export 'package:mh_employee_app/features/training/data/models/training_record_model.dart' show TrainingStatus;

class TrainingScreenNew extends StatefulWidget {
  @override
  _TrainingScreenNewState createState() => _TrainingScreenNewState();
}

class _TrainingScreenNewState extends State<TrainingScreenNew> {
  List<TrainingCourse> trainings = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadTrainings();
  }

  Future<void> _refreshTrainings() async {
    await _loadTrainings();
  }

  Future<void> _loadTrainings() async {
    setState(() => _isLoading = true);
    try {
      final courses = await ApiService.getTrainingCourses();
      setState(() => trainings = courses);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading training courses: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: RefreshIndicator(
        onRefresh: _refreshTrainings,
        color: AppColors.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Modern Gradient Header
            SliverAppBar(
              expandedHeight: 180,
              floating: false,
              pinned: true,
              automaticallyImplyLeading: false,
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: AppColors.gradientPurple,
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                ),
                child: const FlexibleSpaceBar(
                  centerTitle: false,
                  title: Text(
                    'Training Portal',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                  titlePadding: EdgeInsets.only(left: 56, bottom: 16),
                ),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),

            // Stats Cards
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: ModernGlassCard(
                        padding: const EdgeInsets.all(16),
                        gradient: AppColors.gradientPurple.map((c) => c.withOpacity(0.1)).toList(),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: AppColors.gradientPurple),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.school_rounded, color: Colors.white, size: 24),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '${trainings.length}',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const Text(
                              'Total Courses',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ).animate(delay: 100.ms).fadeIn().scale(),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ModernGlassCard(
                        padding: const EdgeInsets.all(16),
                        gradient: AppColors.gradientOrange.map((c) => c.withOpacity(0.1)).toList(),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: AppColors.gradientOrange),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 24),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '${trainings.where((t) => t.status == TrainingStatus.approved).length}',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const Text(
                              'Completed',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ).animate(delay: 150.ms).fadeIn().scale(),
                    ),
                  ],
                ),
              ),
            ),

            // Training List
            _isLoading
                ? const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  )
                : trainings.isEmpty
                    ? SliverFillRemaining(
                        child: ModernEmptyState(
                          message: 'No training courses available',
                          icon: Icons.school_rounded,
                          actionText: 'Add Training',
                          onAction: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => AddTrainingScreen()),
                            ).then((_) => _loadTrainings());
                          },
                        ),
                      )
                    : SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              return TrainingCard(
                                training: trainings[index],
                              ).animate(delay: (200 + index * 50).ms).fadeIn().slideX(begin: -0.2, end: 0);
                            },
                            childCount: trainings.length,
                          ),
                        ),
                      ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      floatingActionButton: ModernFAB(
        icon: Icons.add_rounded,
        label: 'Add Training',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTrainingScreen()),
          ).then((_) => _loadTrainings());
        },
        gradientColors: AppColors.gradientPurple,
      ),
    );
  }
}
