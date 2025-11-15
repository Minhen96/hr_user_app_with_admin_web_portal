import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mh_employee_app/core/theme/app_colors.dart';
import 'package:mh_employee_app/shared/widgets/modern_glass_card.dart';
import 'package:mh_employee_app/shared/widgets/modern_app_bar.dart';
import 'package:mh_employee_app/services/api_service.dart';
import 'package:mh_employee_app/features/documents/presentation/screens/document_screen.dart';

class HandbookScreenNew extends StatefulWidget {
  const HandbookScreenNew({Key? key}) : super(key: key);

  @override
  _HandbookScreenNewState createState() => _HandbookScreenNewState();
}

class _HandbookScreenNewState extends State<HandbookScreenNew> {
  Map<String, int> _documentUnreadCounts = {
    'MEMO': 0,
    'SOP': 0,
    'POLICY': 0,
    'UserGuide': 0,
  };

  @override
  void initState() {
    super.initState();
    _loadDocumentUnreadCounts();
  }

  Future<void> _loadDocumentUnreadCounts() async {
    try {
      final counts = await ApiService.getDocumentUnreadCounts();
      if (mounted) {
        setState(() {
          _documentUnreadCounts = counts;
        });
      }
    } catch (e) {
      print('Error loading document unread counts: $e');
    }
  }

  Future<void> _navigateToDocumentScreen(String type, String title) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DocumentScreen(
          initialType: type,
          title: title,
        ),
      ),
    );
    _loadDocumentUnreadCounts();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Modern App Bar
          SliverAppBar(
            expandedHeight: 120,
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
                  'Handbook',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                centerTitle: false,
                titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // Company Info Section - NOW ON TOP
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ModernSectionHeader(
                    title: 'Company Info',
                    subtitle: 'Our vision, mission & values',
                    icon: Icons.business_rounded,
                  ).animate(delay: 100.ms).fadeIn().slideX(begin: -0.2, end: 0),
                  const SizedBox(height: 16),
                  _buildCompanyInfoCards(),
                ],
              ),
            ),
          ),

          // Document Types Section - NOW BELOW
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ModernSectionHeader(
                    title: 'Documents',
                    subtitle: 'Company policies and guidelines',
                    icon: Icons.folder_rounded,
                  ).animate(delay: 300.ms).fadeIn().slideX(begin: -0.2, end: 0),
                  const SizedBox(height: 16),
                  _buildDocumentGrid(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        _buildDocumentCard(
          title: 'Memo',
          icon: Icons.description_rounded,
          gradient: AppColors.gradientBlue,
          count: _documentUnreadCounts['MEMO'] ?? 0,
          onTap: () => _navigateToDocumentScreen('MEMO', 'Memos'),
        ).animate(delay: 150.ms).fadeIn().scale(),
        _buildDocumentCard(
          title: 'Policy',
          icon: Icons.policy_rounded,
          gradient: AppColors.gradientPurple,
          count: _documentUnreadCounts['POLICY'] ?? 0,
          onTap: () => _navigateToDocumentScreen('POLICY', 'Policies'),
        ).animate(delay: 200.ms).fadeIn().scale(),
        _buildDocumentCard(
          title: 'SOP',
          icon: Icons.assignment_rounded,
          gradient: AppColors.gradientOrange,
          count: _documentUnreadCounts['SOP'] ?? 0,
          onTap: () => _navigateToDocumentScreen('SOP', 'SOPs'),
        ).animate(delay: 250.ms).fadeIn().scale(),
        _buildDocumentCard(
          title: 'User Guide',
          icon: Icons.menu_book_rounded,
          gradient: AppColors.gradientGreen,
          count: _documentUnreadCounts['UserGuide'] ?? 0,
          onTap: () => _navigateToDocumentScreen('UserGuide', 'User Guides'),
        ).animate(delay: 300.ms).fadeIn().scale(),
      ],
    );
  }

  Widget _buildDocumentCard({
    required String title,
    required IconData icon,
    required List<Color> gradient,
    required int count,
    required VoidCallback onTap,
  }) {
    return ModernFeatureCard(
      icon: icon,
      title: title,
      gradientColors: gradient,
      badgeCount: count > 0 ? count : null,
      onTap: onTap,
    );
  }

  Widget _buildCompanyInfoCards() {
    return Column(
      children: [
        _buildInfoCard(
          title: 'Our Vision',
          icon: Icons.visibility_rounded,
          gradient: AppColors.gradientBlue,
          content: 'Building a better future together',
          onTap: () => _showInfoDialog('Vision'),
        ).animate(delay: 350.ms).fadeIn().slideX(begin: 0.2, end: 0),
        const SizedBox(height: 12),
        _buildInfoCard(
          title: 'Our Mission',
          icon: Icons.flag_rounded,
          gradient: AppColors.gradientPink,
          content: 'Excellence in everything we do',
          onTap: () => _showInfoDialog('Mission'),
        ).animate(delay: 400.ms).fadeIn().slideX(begin: 0.2, end: 0),
        const SizedBox(height: 12),
        _buildInfoCard(
          title: 'Our Values',
          icon: Icons.favorite_rounded,
          gradient: AppColors.gradientGreen,
          content: 'Integrity, Innovation, Impact',
          onTap: () => _showInfoDialog('Values'),
        ).animate(delay: 450.ms).fadeIn().slideX(begin: 0.2, end: 0),
      ],
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Color> gradient,
    required String content,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ModernElevatedCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradient),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: gradient.first.withOpacity(0.4),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(String type) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Our $type'),
        content: SingleChildScrollView(
          child: Text('Detailed information about our $type would go here.'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
