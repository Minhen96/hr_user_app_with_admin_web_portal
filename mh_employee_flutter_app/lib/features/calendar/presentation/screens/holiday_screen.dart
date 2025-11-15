import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:mh_employee_app/core/theme/app_colors.dart';
import 'package:mh_employee_app/services/api_service.dart';
import 'package:mh_employee_app/features/calendar/data/models/holiday_model.dart';
import 'package:mh_employee_app/shared/widgets/modern_glass_card.dart';
import 'package:mh_employee_app/shared/widgets/modern_buttons.dart';
import 'package:mh_employee_app/shared/widgets/modern_page_template.dart';

class HolidayScreen extends StatefulWidget {
  const HolidayScreen({Key? key}) : super(key: key);

  @override
  _HolidayScreenState createState() => _HolidayScreenState();
}

class _HolidayScreenState extends State<HolidayScreen> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  late int _selectedYear;
  final List<int> _years = List.generate(
    10,
    (index) => DateTime.now().year - 5 + index,
  );
  Map<DateTime, String> _holidays = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _selectedYear = DateTime.now().year;
    _loadHolidays();
  }

  void _navigateMonth(bool next) {
    setState(() {
      if (next) {
        if (_focusedDay.month == 12) {
          _focusedDay = DateTime(_focusedDay.year + 1, 1);
          _selectedYear = _focusedDay.year;
        } else {
          _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1);
        }
      } else {
        if (_focusedDay.month == 1) {
          _focusedDay = DateTime(_focusedDay.year - 1, 12);
          _selectedYear = _focusedDay.year;
        } else {
          _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1);
        }
      }
    });
    _loadHolidays();
  }

  Future<void> _loadHolidays() async {
    if (!mounted) return;

    setState(() => _isLoading = true);
    try {
      final holidays = await ApiService.getHolidays(
        _focusedDay.year,
        _focusedDay.month,
      );

      if (!mounted) return;

      setState(() {
        _holidays = {
          for (var holiday in holidays)
            DateTime(
              holiday.holidayDate.year,
              holiday.holidayDate.month,
              holiday.holidayDate.day,
            ): holiday.holidayName,
        };
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load holidays: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String? _getHolidayForDay(DateTime day) {
    return _holidays[DateTime(day.year, day.month, day.day)];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });

    final holidayName = _getHolidayForDay(selectedDay);
    if (holidayName != null) {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          child: ModernElevatedCard(
            padding: EdgeInsets.zero,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header with gradient
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: AppColors.gradientOrange,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.only(
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
                          child: const Icon(
                            Icons.celebration_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            DateFormat('dd MMMM yyyy').format(selectedDay),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),

                  // Content
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: AppColors.gradientOrange
                                  .map((c) => c.withOpacity(0.1))
                                  .toList(),
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.event_rounded,
                                color: Colors.orange,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  holidayName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    height: 1.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        ModernGradientButton(
                          text: 'Close',
                          onPressed: () => Navigator.pop(context),
                          gradientColors: AppColors.gradientOrange,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ).animate().scale(duration: 300.ms),
        ),
      );
    }
  }

  void _onPageChanged(DateTime focusedDay) {
    setState(() {
      _focusedDay = focusedDay;
    });
    _loadHolidays();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ModernPageTemplate(
      title: 'Public Holidays',
      gradientColors: AppColors.gradientOrange,
      showBackButton: true,
      children: [
        const SizedBox(height: 20),

        // Month Navigation & Year Selector
        ModernGlassCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ModernIconButton(
                icon: Icons.chevron_left_rounded,
                onPressed: () => _navigateMonth(false),
                backgroundColor: (isDark ? AppColors.darkPrimary : AppColors.primary).withOpacity(0.1),
                iconColor: isDark ? AppColors.darkPrimary : AppColors.primary,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: AppColors.gradientOrange.map((c) => c.withOpacity(0.1)).toList(),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.event_rounded,
                      color: isDark ? AppColors.darkPrimary : AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('MMMM').format(_focusedDay),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              ModernIconButton(
                icon: Icons.chevron_right_rounded,
                onPressed: () => _navigateMonth(true),
                backgroundColor: (isDark ? AppColors.darkPrimary : AppColors.primary).withOpacity(0.1),
                iconColor: isDark ? AppColors.darkPrimary : AppColors.primary,
              ),
            ],
          ),
        ).animate(delay: 100.ms).fadeIn().slideY(begin: -0.2, end: 0),

        const SizedBox(height: 16),

        // Year Selector
        ModernGlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.calendar_today_rounded,
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'Year:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceVariant : AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.border,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _selectedYear,
                    isDense: true,
                    style: TextStyle(
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    dropdownColor: isDark ? AppColors.darkSurface : Colors.white,
                    items: _years.map((year) {
                      return DropdownMenuItem(
                        value: year,
                        child: Text(year.toString()),
                      );
                    }).toList(),
                    onChanged: (year) {
                      if (year != null) {
                        setState(() {
                          _selectedYear = year;
                          _focusedDay = DateTime(year, _focusedDay.month);
                        });
                        _loadHolidays();
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ).animate(delay: 150.ms).fadeIn().slideY(begin: -0.2, end: 0),

        const SizedBox(height: 20),

        // Loading Indicator
        if (_isLoading)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: CircularProgressIndicator(
                color: isDark ? AppColors.darkPrimary : AppColors.primary,
              ),
            ),
          ),

        // Calendar
        ModernElevatedCard(
          padding: const EdgeInsets.all(16),
          child: TableCalendar(
            firstDay: DateTime(_selectedYear, 1, 1),
            lastDay: DateTime(_selectedYear, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarFormat: CalendarFormat.month,
            startingDayOfWeek: StartingDayOfWeek.monday,
            headerVisible: false,
            daysOfWeekHeight: 40,
            rowHeight: 60,
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              weekendTextStyle: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
              selectedDecoration: const BoxDecoration(
                gradient: LinearGradient(colors: AppColors.gradientOrange),
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: (isDark ? AppColors.darkPrimary : AppColors.primary).withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              defaultTextStyle: TextStyle(
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              weekendDecoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              defaultDecoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: TextStyle(
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
              weekendStyle: const TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            onDaySelected: _onDaySelected,
            onPageChanged: _onPageChanged,
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, day, events) {
                final holiday = _getHolidayForDay(day);
                if (holiday != null) {
                  return Positioned(
                    right: 10,
                    top: 10,
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(colors: AppColors.gradientOrange),
                      ),
                      width: 8,
                      height: 8,
                    ),
                  );
                }
                return null;
              },
            ),
          ),
        ).animate(delay: 200.ms).fadeIn().scale(),

        const SizedBox(height: 20),

        // Holiday Count Summary
        if (_holidays.isNotEmpty)
          ModernGlassCard(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: AppColors.gradientOrange),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.event_available_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_holidays.length} ${_holidays.length == 1 ? "Holiday" : "Holidays"}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'in ${DateFormat('MMMM yyyy').format(_focusedDay)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.2, end: 0),

        const SizedBox(height: 100),
      ],
    );
  }
}
