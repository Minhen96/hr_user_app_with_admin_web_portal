import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:mh_employee_app/core/theme/app_colors.dart';
import 'package:mh_employee_app/services/api_service.dart';
import 'package:mh_employee_app/shared/models/user_birthday.dart';
import 'package:mh_employee_app/shared/widgets/modern_glass_card.dart';
import 'package:mh_employee_app/shared/widgets/modern_buttons.dart';
import 'package:mh_employee_app/shared/widgets/modern_page_template.dart';

class BirthdayScreen extends StatefulWidget {
  const BirthdayScreen({Key? key}) : super(key: key);

  @override
  _BirthdayScreenState createState() => _BirthdayScreenState();
}

class _BirthdayScreenState extends State<BirthdayScreen> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  bool _isLoading = false;
  Map<DateTime, List<UserBirthday>> _birthdays = {};

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _loadBirthdays();
  }

  Future<void> _loadBirthdays() async {
    if (!mounted) return;

    setState(() => _isLoading = true);
    try {
      final birthdays = await ApiService.getBirthdays(_focusedDay.month);

      if (!mounted) return;

      setState(() {
        _birthdays = groupBirthdays(birthdays);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load birthdays: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Map<DateTime, List<UserBirthday>> groupBirthdays(List<UserBirthday> birthdays) {
    Map<DateTime, List<UserBirthday>> grouped = {};
    for (var birthday in birthdays) {
      final date = DateTime(
        _focusedDay.year,
        birthday.birthDate.month,
        birthday.birthDate.day,
      );
      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      grouped[date]!.add(birthday);
    }
    return grouped;
  }

  List<UserBirthday>? _getBirthdaysForDay(DateTime day) {
    return _birthdays[DateTime(_focusedDay.year, day.month, day.day)];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });

    final birthdays = _getBirthdaysForDay(selectedDay);
    if (birthdays != null && birthdays.isNotEmpty) {
      _showBirthdayDialog(birthdays, selectedDay);
    }
  }

  void _showBirthdayDialog(List<UserBirthday> birthdays, DateTime selectedDay) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ModernElevatedCard(
          padding: EdgeInsets.zero,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
              maxWidth: 500,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: AppColors.gradientPink,
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
                        child: const Icon(Icons.cake_rounded, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat('dd MMMM').format(selectedDay),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              '${birthdays.length} ${birthdays.length == 1 ? "Birthday" : "Birthdays"}',
                              style: const TextStyle(color: Colors.white70, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(16),
                    itemCount: birthdays.length,
                    itemBuilder: (context, index) {
                      final birthday = birthdays[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: AppColors.gradientPink.map((c) => c.withOpacity(0.1)).toList(),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.pink.shade100,
                              child: Text(
                                birthday.fullName[0].toUpperCase(),
                                style: TextStyle(color: Colors.pink.shade900, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(birthday.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  Text(birthday.department, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ModernGradientButton(
                    text: 'Close',
                    onPressed: () => Navigator.pop(context),
                    gradientColors: AppColors.gradientPink,
                  ),
                ),
              ],
            ),
          ),
        ).animate().scale(duration: 300.ms),
      ),
    );
  }

  void _navigateMonth(bool next) {
    setState(() {
      _focusedDay = next
          ? DateTime(_focusedDay.year, _focusedDay.month + 1)
          : DateTime(_focusedDay.year, _focusedDay.month - 1);
    });
    _loadBirthdays();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final monthBirthdays = _birthdays.values.expand((e) => e).toList();

    return ModernPageTemplate(
      title: 'Birthday Calendar',
      gradientColors: AppColors.gradientPink,
      showBackButton: true,
      children: [
        const SizedBox(height: 20),
        ModernGlassCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ModernIconButton(
                icon: Icons.chevron_left_rounded,
                onPressed: () => _navigateMonth(false),
                backgroundColor: Colors.pink.withOpacity(0.1),
                iconColor: Colors.pink.shade700,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: AppColors.gradientPink.map((c) => c.withOpacity(0.1)).toList()),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.event_rounded, color: Colors.pink.shade700, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('MMMM yyyy').format(_focusedDay),
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
                backgroundColor: Colors.pink.withOpacity(0.1),
                iconColor: Colors.pink.shade700,
              ),
            ],
          ),
        ).animate(delay: 100.ms).fadeIn().slideY(begin: -0.2, end: 0),
        const SizedBox(height: 20),
        if (_isLoading)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: CircularProgressIndicator(color: Colors.pink.shade400),
            ),
          ),
        ModernElevatedCard(
          padding: const EdgeInsets.all(16),
          child: TableCalendar(
            firstDay: DateTime(_focusedDay.year, 1, 1),
            lastDay: DateTime(_focusedDay.year, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarFormat: CalendarFormat.month,
            startingDayOfWeek: StartingDayOfWeek.monday,
            headerVisible: false,
            daysOfWeekHeight: 40,
            rowHeight: 60,
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              weekendTextStyle: const TextStyle(color: AppColors.error, fontWeight: FontWeight.w600),
              selectedDecoration: const BoxDecoration(gradient: LinearGradient(colors: AppColors.gradientPink), shape: BoxShape.circle),
              todayDecoration: BoxDecoration(color: Colors.pink.shade200, shape: BoxShape.circle),
              defaultTextStyle: TextStyle(color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary, fontWeight: FontWeight.w500),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: TextStyle(color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary, fontWeight: FontWeight.bold),
              weekendStyle: const TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
            ),
            onDaySelected: _onDaySelected,
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, day, events) {
                final birthdays = _getBirthdaysForDay(day);
                if (birthdays != null && birthdays.isNotEmpty) {
                  return Positioned(
                    right: 10,
                    top: 10,
                    child: Container(
                      decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: AppColors.gradientPink)),
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
        if (monthBirthdays.isNotEmpty)
          ModernGlassCard(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(gradient: const LinearGradient(colors: AppColors.gradientPink), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.celebration_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${monthBirthdays.length} ${monthBirthdays.length == 1 ? "Birthday" : "Birthdays"}',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                    ),
                    Text(
                      'in ${DateFormat('MMMM yyyy').format(_focusedDay)}',
                      style: TextStyle(fontSize: 14, color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.2, end: 0),
        const SizedBox(height: 20),
        if (monthBirthdays.isNotEmpty)
          ...monthBirthdays.asMap().entries.map((entry) {
            final index = entry.key;
            final birthday = entry.value;
            return ModernElevatedCard(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.pink.shade100,
                    radius: 28,
                    child: Text(
                      birthday.fullName[0].toUpperCase(),
                      style: TextStyle(color: Colors.pink.shade900, fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          birthday.fullName,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          birthday.department,
                          style: TextStyle(color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(gradient: const LinearGradient(colors: AppColors.gradientPink), borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      DateFormat('dd MMM').format(birthday.birthDate),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ).animate(delay: (100 * index).ms).fadeIn().slideX(begin: 0.2, end: 0);
          }).toList(),
        const SizedBox(height: 100),
      ],
    );
  }
}
