import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:mh_employee_app/core/theme/app_colors.dart';
import 'package:mh_employee_app/shared/widgets/modern_glass_card.dart';
import 'package:mh_employee_app/shared/widgets/modern_buttons.dart';
import 'package:mh_employee_app/shared/widgets/modern_page_template.dart';
import '../../services/api_service.dart';
import '../models/news_item.dart';

class UpdateHistoryScreenNew extends StatefulWidget {
  const UpdateHistoryScreenNew({super.key});

  @override
  _UpdateHistoryScreenNewState createState() => _UpdateHistoryScreenNewState();
}

class _UpdateHistoryScreenNewState extends State<UpdateHistoryScreenNew> {
  int selectedYear = DateTime.now().year;
  int selectedMonth = DateTime.now().month;
  List<NewsItem> historyItems = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchHistoryUpdates();
  }

  Future<void> _fetchHistoryUpdates() async {
    setState(() => isLoading = true);
    try {
      final response = await ApiService.getUpdateDocuments(
        year: selectedYear,
        month: selectedMonth,
      );
      setState(() {
        historyItems = response.items;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load history: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  List<int> _getAvailableYears() {
    final currentYear = DateTime.now().year;
    return List.generate(5, (index) => currentYear - index);
  }

  List<int> _getAvailableMonths() {
    final currentYear = DateTime.now().year;
    final currentMonth = DateTime.now().month;

    if (selectedYear == currentYear) {
      return List.generate(currentMonth, (index) => index + 1);
    }
    return List.generate(12, (index) => index + 1);
  }

  List<Color> _getCategoryGradient(String title) {
    if (title.toLowerCase().contains('event')) {
      return AppColors.gradientOrange;
    } else if (title.toLowerCase().contains('update')) {
      return AppColors.gradientBlue;
    } else if (title.toLowerCase().contains('announcement')) {
      return AppColors.gradientPink;
    }
    return AppColors.gradientGreen;
  }

  IconData _getCategoryIcon(String title) {
    if (title.toLowerCase().contains('event')) {
      return Icons.event_note_rounded;
    } else if (title.toLowerCase().contains('update')) {
      return Icons.update_rounded;
    } else if (title.toLowerCase().contains('announcement')) {
      return Icons.campaign_rounded;
    }
    return Icons.article_rounded;
  }

  void _showDetailDialog(NewsItem item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: ModernElevatedCard(
            padding: EdgeInsets.zero,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
                maxWidth: 600,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header with gradient
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _getCategoryGradient(item.title),
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.only(
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
                          child: Icon(
                            _getCategoryIcon(item.title),
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            item.title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),

                  // Content
                  Flexible(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Author and date info
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: _getCategoryGradient(item.title)
                                      .map((c) => c.withOpacity(0.1))
                                      .toList(),
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.person_outline_rounded,
                                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      item.author.split(' ')[0],
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Icon(
                                    Icons.calendar_today_rounded,
                                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    DateFormat('MMM dd, yyyy').format(item.datePosted),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),
                            // Main content
                            Text(
                              item.content,
                              style: TextStyle(
                                fontSize: 16,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ).animate().scale(duration: 300.ms),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ModernPageTemplate(
      title: 'Update History',
      gradientColors: AppColors.primaryGradient,
      showBackButton: true,
      children: [
        const SizedBox(height: 20),

        // Filter Section
        ModernGlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: AppColors.primaryGradient,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.filter_alt_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Filter Updates',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: selectedYear,
                      dropdownColor: isDark ? AppColors.darkSurface : Colors.white,
                      decoration: InputDecoration(
                        labelText: 'Year',
                        labelStyle: TextStyle(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        ),
                        prefixIcon: Icon(
                          Icons.calendar_month_rounded,
                          color: isDark ? AppColors.darkPrimary : AppColors.primary,
                        ),
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
                        filled: true,
                        fillColor: isDark ? AppColors.darkSurfaceVariant : AppColors.surface,
                      ),
                      style: TextStyle(
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      ),
                      items: _getAvailableYears()
                          .map((year) => DropdownMenuItem(
                                value: year,
                                child: Text(year.toString()),
                              ))
                          .toList(),
                      onChanged: (year) {
                        if (year != null) {
                          setState(() {
                            selectedYear = year;
                            if (year == DateTime.now().year &&
                                selectedMonth > DateTime.now().month) {
                              selectedMonth = DateTime.now().month;
                            }
                          });
                          _fetchHistoryUpdates();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: selectedMonth,
                      dropdownColor: isDark ? AppColors.darkSurface : Colors.white,
                      decoration: InputDecoration(
                        labelText: 'Month',
                        labelStyle: TextStyle(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        ),
                        prefixIcon: Icon(
                          Icons.today_rounded,
                          color: isDark ? AppColors.darkPrimary : AppColors.primary,
                        ),
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
                        filled: true,
                        fillColor: isDark ? AppColors.darkSurfaceVariant : AppColors.surface,
                      ),
                      style: TextStyle(
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      ),
                      items: _getAvailableMonths()
                          .map((month) => DropdownMenuItem(
                                value: month,
                                child: Text(DateFormat('MMMM')
                                    .format(DateTime(selectedYear, month))),
                              ))
                          .toList(),
                      onChanged: (month) {
                        if (month != null) {
                          setState(() => selectedMonth = month);
                          _fetchHistoryUpdates();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ).animate(delay: 100.ms).fadeIn().slideY(begin: -0.2, end: 0),

        const SizedBox(height: 20),

        // Content List
        if (isLoading)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(60),
              child: Column(
                children: [
                  CircularProgressIndicator(
                    color: isDark ? AppColors.darkPrimary : AppColors.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading updates...',
                    style: TextStyle(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          )
        else if (historyItems.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(60),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: AppColors.primaryGradient,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.inbox_rounded,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No updates found',
                    style: TextStyle(
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try selecting a different time period',
                    style: TextStyle(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          ...historyItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return ModernElevatedCard(
              margin: const EdgeInsets.only(bottom: 16),
              padding: EdgeInsets.zero,
              onTap: () => _showDetailDialog(item),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _getCategoryGradient(item.title)
                        .map((c) => c.withOpacity(0.05))
                        .toList(),
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _getCategoryGradient(item.title),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getCategoryIcon(item.title),
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.content,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 14,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                DateFormat('MMM dd, yyyy').format(item.datePosted),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
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
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ).animate(delay: (100 * index).ms).fadeIn().slideX(begin: 0.2, end: 0);
          }).toList(),

        const SizedBox(height: 100),
      ],
    );
  }
}
