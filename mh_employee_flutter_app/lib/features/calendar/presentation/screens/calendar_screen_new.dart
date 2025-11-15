import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mh_employee_app/core/theme/app_colors.dart';
import 'package:mh_employee_app/features/auth/data/models/user_model.dart';
import 'package:mh_employee_app/shared/widgets/modern_page_template.dart';
import 'package:mh_employee_app/features/calendar/presentation/screens/implement_calendar_screen_new.dart';
import 'package:mh_employee_app/features/calendar/presentation/screens/holiday_screen.dart';
import 'package:mh_employee_app/features/calendar/presentation/screens/birthday_screen.dart';
import 'package:mh_employee_app/features/leave/presentation/screens/Leave_Calender.dart';

class CalendarScreenNew extends StatelessWidget {
  final User userData;
  const CalendarScreenNew({Key? key, required this.userData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ModernPageTemplate(
      title: 'Calendar',
      gradientColors: AppColors.gradientGreen,
      showBackButton: true,
      children: [
        const SizedBox(height: 20),

        // Calendar Features
        ModernListTile(
          title: 'Implement Calendar',
          subtitle: 'Insert a new event',
          icon: Icons.calendar_month_rounded,
          gradient: AppColors.gradientBlue,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ImplementCalendarScreenNew(userid: int.parse(userData.id)),
            ),
          ),
        ).animate(delay: 100.ms).fadeIn().slideX(begin: -0.2, end: 0),

        ModernListTile(
          title: 'Public Holiday',
          subtitle: 'View all public holidays',
          icon: Icons.public_rounded,
          gradient: AppColors.gradientOrange,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HolidayScreen()),
          ),
        ).animate(delay: 150.ms).fadeIn().slideX(begin: -0.2, end: 0),

        ModernListTile(
          title: 'Birthday',
          subtitle: 'Check birthday calendar',
          icon: Icons.cake_rounded,
          gradient: AppColors.gradientPink,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => BirthdayScreen()),
          ),
        ).animate(delay: 200.ms).fadeIn().slideX(begin: -0.2, end: 0),

        ModernListTile(
          title: 'Leave Calendar',
          subtitle: 'Manage your leaves',
          icon: Icons.event_rounded,
          gradient: AppColors.gradientTeal,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LeaveCalendar()),
          ),
        ).animate(delay: 250.ms).fadeIn().slideX(begin: -0.2, end: 0),

        const SizedBox(height: 100),
      ],
    );
  }
}
