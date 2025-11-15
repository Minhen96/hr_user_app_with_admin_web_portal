import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mh_employee_app/core/theme/app_colors.dart';
import 'package:mh_employee_app/features/auth/data/models/user_model.dart';
import 'package:mh_employee_app/shared/widgets/modern_page_template.dart';
import 'package:mh_employee_app/features/equipment/presentation/screens/equipment_screen_new.dart';
import 'package:mh_employee_app/features/change_request/presentation/screens/change_request_screen_new.dart';
import 'package:mh_employee_app/features/profile/presentation/screens/change_password_screen_new.dart';
import 'package:mh_employee_app/features/auth/domain/entities/user.dart' as entity;

class FormScreenNew extends StatelessWidget {
  final User userData;
  const FormScreenNew({Key? key, required this.userData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ModernPageTemplate(
      title: 'Request Forms',
      gradientColors: AppColors.gradientTeal,
      showBackButton: true,
      children: [
        const SizedBox(height: 20),

        // Info Card
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ModernInfoCard(
            title: 'Form Submission',
            content: 'The form will be submitted to the admin, and please wait for the confirmation.',
            icon: Icons.info_rounded,
            gradient: AppColors.gradientBlue,
          ).animate(delay: 100.ms).fadeIn().slideY(begin: -0.2, end: 0),
        ),

        const SizedBox(height: 24),

        // Form Options
        ModernListTile(
          title: 'Equipment Request',
          subtitle: 'Request new equipment',
          icon: Icons.computer_rounded,
          gradient: AppColors.gradientBlue,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EquipmentScreenNew(userData: userData)),
          ),
        ).animate(delay: 150.ms).fadeIn().slideX(begin: -0.2, end: 0),

        ModernListTile(
          title: 'Change Request',
          subtitle: 'Submit change request',
          icon: Icons.edit_note_rounded,
          gradient: AppColors.gradientPurple,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ChangeRequestScreenNew(userData: userData)),
          ),
        ).animate(delay: 200.ms).fadeIn().slideX(begin: -0.2, end: 0),

        ModernListTile(
          title: 'Change Password',
          subtitle: 'Update your password',
          icon: Icons.lock_rounded,
          gradient: AppColors.gradientOrange,
          onTap: () {
            final entityUser = entity.User(
              id: int.parse(userData.id),
              name: userData.fullName,
              email: userData.email,
              role: userData.role,
              department: userData.department.name,
              departmentId: userData.department.id.isNotEmpty ? int.tryParse(userData.department.id) : null,
            );
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ChangePasswordScreenNew(userData: entityUser)),
            );
          },
        ).animate(delay: 250.ms).fadeIn().slideX(begin: -0.2, end: 0),

        const SizedBox(height: 100),
      ],
    );
  }
}
