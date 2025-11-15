import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:mh_employee_app/core/theme/app_colors.dart';
import 'package:mh_employee_app/features/documents/data/models/document_model.dart';

class DocumentDetailScreen extends StatelessWidget {
  final Document document;
  final VoidCallback? onDownload;
  final VoidCallback? onPreview;

  const DocumentDetailScreen({
    Key? key,
    required this.document,
    this.onDownload,
    this.onPreview,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Modern App Bar
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _getTypeGradient(),
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            document.type.toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                          ),
                        ).animate().fadeIn().slideX(begin: -0.2, end: 0),
                        SizedBox(height: 12),
                        Text(
                          document.title,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ).animate(delay: 100.ms).fadeIn().slideX(begin: -0.2, end: 0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverPadding(
            padding: EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Info Card
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Author Info
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: _getTypeGradient(),
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.person_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Posted by',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                  ),
                                ),
                                Text(
                                  document.posterName,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ).animate().fadeIn().slideX(begin: -0.1, end: 0),

                      SizedBox(height: 16),
                      Divider(color: isDark ? AppColors.darkBorder : AppColors.border),
                      SizedBox(height: 16),

                      // Date Info
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 18,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                          ),
                          SizedBox(width: 8),
                          Text(
                            DateFormat('MMMM dd, yyyy').format(document.postDate),
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ).animate(delay: 100.ms).fadeIn().slideX(begin: -0.1, end: 0),

                      SizedBox(height: 12),

                      // Department Info
                      Row(
                        children: [
                          Icon(
                            Icons.business_rounded,
                            size: 18,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                          ),
                          SizedBox(width: 8),
                          Text(
                            document.departmentName,
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ).animate(delay: 200.ms).fadeIn().slideX(begin: -0.1, end: 0),
                    ],
                  ),
                ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.1, end: 0),

                SizedBox(height: 20),

                // Content Card
                if (document.content != null && document.content!.isNotEmpty)
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.description_rounded,
                              color: _getTypeColor(),
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Description',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Text(
                          document.content!,
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.6,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.1, end: 0),

                SizedBox(height: 20),

                // Action Buttons
                Row(
                  children: [
                    if (onDownload != null) ...[
                      Expanded(
                        child: Container(
                          height: 54,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isDark ? AppColors.darkBorder : AppColors.border,
                              width: 1.5,
                            ),
                          ),
                          child: ElevatedButton(
                            onPressed: onDownload,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
                              foregroundColor: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                              elevation: 0,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.download_rounded, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Download',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ).animate(delay: 500.ms).fadeIn().scale(),
                      ),
                      SizedBox(width: 12),
                    ],
                    if (onPreview != null)
                      Expanded(
                        child: Container(
                          height: 54,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: _getTypeGradient(),
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: _getTypeColor().withOpacity(0.4),
                                blurRadius: 12,
                                offset: Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: onPreview,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.visibility_rounded, size: 20, color: Colors.white),
                                SizedBox(width: 8),
                                Text(
                                  'Preview',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ).animate(delay: 600.ms).fadeIn().scale(),
                      ),
                  ],
                ),

                SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _getTypeGradient() {
    switch (document.type.toUpperCase()) {
      case 'MEMO':
        return [Color(0xFF38EF7D), Color(0xFF11998E)]; // Green gradient
      case 'POLICY':
        return [Color(0xFF00D4FF), Color(0xFF0099FF)]; // Blue gradient
      case 'SOP':
        return [Color(0xFFFF9A56), Color(0xFFFF6B6B)]; // Orange gradient
      case 'UPDATES':
        return [Color(0xFF667EEA), Color(0xFF764BA2)]; // Purple gradient
      case 'HANDBOOK':
        return [Color(0xFF4568DC), Color(0xFFB06AB3)]; // Violet gradient
      default:
        return [Color(0xFF667EEA), Color(0xFF764BA2)];
    }
  }

  Color _getTypeColor() {
    switch (document.type.toUpperCase()) {
      case 'MEMO':
        return Color(0xFF38EF7D);
      case 'POLICY':
        return Color(0xFF00D4FF);
      case 'SOP':
        return Color(0xFFFF9A56);
      case 'UPDATES':
        return Color(0xFF667EEA);
      case 'HANDBOOK':
        return Color(0xFF4568DC);
      default:
        return Color(0xFF667EEA);
    }
  }
}
