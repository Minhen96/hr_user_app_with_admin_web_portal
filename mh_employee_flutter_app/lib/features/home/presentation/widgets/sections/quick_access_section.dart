import 'package:flutter/material.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/text_styles.dart';
import '../../../../../features/auth/data/models/user_model.dart';

// Import icon buttons
import '../../widgets/icon_buttons/handbook_button.dart';
import '../../widgets/icon_buttons/memo_button.dart';
import '../../widgets/icon_buttons/attendance_button.dart';
import '../../widgets/icon_buttons/calendar_button.dart';
import '../../widgets/icon_buttons/form_button.dart';
import '../../widgets/icon_buttons/training_button.dart';
import '../../widgets/icon_buttons/leave_button.dart';
import '../../widgets/icon_buttons/gallery_button.dart';

/// Modern Quick Access Grid Section
class QuickAccessSection extends StatelessWidget {
  final UserModel? userData;
  final Map<String, int> documentUnreadCounts;
  final VoidCallback onDocumentsRefresh;

  const QuickAccessSection({
    Key? key,
    this.userData,
    required this.documentUnreadCounts,
    required this.onDocumentsRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonSpacing = screenWidth < 600 ? 16.0 : 20.0;
    final horizontalPadding = screenWidth < 600 ? 20.0 : 30.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          _buildSectionHeader(context),

          const SizedBox(height: AppSpacing.xl),

          // Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            mainAxisSpacing: buttonSpacing,
            crossAxisSpacing: buttonSpacing,
            childAspectRatio: 0.85,
            children: _buildGridItems(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: AppSpacing.md),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 4,
          ),
        ),
      ),
      child: Text(
        'Quick Access',
        style: AppTextStyles.heading2.copyWith(
          color: Theme.of(context).textTheme.titleLarge?.color,
        ),
      ),
    );
  }

  List<Widget> _buildGridItems(BuildContext context) {
    return [
      HandbookButton(
        unreadCount: documentUnreadCounts['SOP']! + documentUnreadCounts['POLICY']!,
        onTap: () => _navigateToHandbook(context),
      ),
      MemoButton(
        unreadCount: documentUnreadCounts['MEMO'] ?? 0,
        onTap: () => _navigateToMemo(context),
      ),
      AttendanceButton(
        onTap: () => _navigateToAttendance(context),
      ),
      CalenderButton(
        onTap: () => _navigateToCalendar(context),
      ),
      FormButton(
        onTap: () => _navigateToForm(context),
      ),
      TrainingButton(
        onTap: () => _navigateToTraining(context),
      ),
      LeaveButton(
        onTap: () => _navigateToLeave(context),
      ),
      GalleryButton(
        onTap: () => _navigateToGallery(context),
      ),
    ];
  }

  // Navigation methods
  void _navigateToHandbook(BuildContext context) {
    // Navigation logic here
    onDocumentsRefresh();
  }

  void _navigateToMemo(BuildContext context) {
    // Navigation logic here
    onDocumentsRefresh();
  }

  void _navigateToAttendance(BuildContext context) {
    // Navigation logic here
  }

  void _navigateToCalendar(BuildContext context) {
    // Navigation logic here
  }

  void _navigateToForm(BuildContext context) {
    // Navigation logic here
  }

  void _navigateToTraining(BuildContext context) {
    // Navigation logic here
  }

  void _navigateToLeave(BuildContext context) {
    // Navigation logic here
  }

  void _navigateToGallery(BuildContext context) {
    // Navigation logic here
  }
}
