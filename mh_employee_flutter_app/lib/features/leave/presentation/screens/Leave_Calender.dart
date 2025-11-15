import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mh_employee_app/services/api_service.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mh_employee_app/core/theme/app_colors.dart';
import 'package:mh_employee_app/shared/widgets/modern_glass_card.dart';
import 'package:mh_employee_app/shared/widgets/modern_buttons.dart';
import 'package:mh_employee_app/shared/widgets/modern_page_template.dart';

class LeaveCalendar extends StatefulWidget {
  const LeaveCalendar({super.key});

  @override
  _LeaveCalendarState createState() => _LeaveCalendarState();
}

class _LeaveCalendarState extends State<LeaveCalendar> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final Map<DateTime, List<dynamic>> _events = {};
  final Map<DateTime, List<Map<String, dynamic>>> _leaveDetails = {};

  int _monthlyAnnualLeaves = 0;
  int _monthlyMcLeaves = 0;
  String baseurl = "http://localhost:5000/api";

  @override
  void initState() {
    super.initState();
    _fetchAllApprovedLeaves();
  }

  Future<Map<String, dynamic>> fetchAllApprovedLeaves() async {
    final responseAnnual = await http.get(Uri.parse('\$baseurl/Leave/ANLapprove-leaves'));
    final responseMc = await http.get(Uri.parse('\$baseurl/Mc_Pending_/approved-leaves'));

    if (responseAnnual.statusCode == 200 && responseMc.statusCode == 200) {
      return {
        'AnnualLeaves': json.decode(responseAnnual.body),
        'McLeaves': json.decode(responseMc.body),
      };
    } else {
      throw Exception('Failed to load approved leaves');
    }
  }

  DateTime _normalizeDate(DateTime date) => DateTime(date.year, date.month, date.day);

  DateTime? _parseDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  Future<void> _fetchAllApprovedLeaves() async {
    try {
      final response = await fetchAllApprovedLeaves();
      final annualLeaves = response['AnnualLeaves'];
      final mcLeaves = response['McLeaves'];

      setState(() {
        _events.clear();
        _leaveDetails.clear();
        _monthlyAnnualLeaves = 0;
        _monthlyMcLeaves = 0;

        for (var leave in annualLeaves) {
          final startDate = _parseDate(leave['leave_date']);
          final endDate = _parseDate(leave['leave_end_date']) ?? startDate;

          if (startDate != null) {
            final numberOfDays = endDate!.difference(startDate).inDays + 1;
            bool isInCurrentMonth = false;

            for (int i = 0; i < numberOfDays; i++) {
              final currentDate = startDate.add(Duration(days: i));
              if (currentDate.year == _focusedDay.year && currentDate.month == _focusedDay.month) {
                isInCurrentMonth = true;
                break;
              }
            }

            if (isInCurrentMonth) _monthlyAnnualLeaves++;

            for (int i = 0; i < numberOfDays; i++) {
              final currentDate = startDate.add(Duration(days: i));
              final normalizedDate = _normalizeDate(currentDate);
              _addLeaveToCalendar(normalizedDate, 'annual', leave);
            }
          }
        }

        for (var leave in mcLeaves) {
          final startDate = _parseDate(leave['start_date']);
          final endDate = _parseDate(leave['end_date']) ?? startDate;

          if (startDate != null && endDate != null) {
            bool isInCurrentMonth = false;
            for (var date = startDate; date.isBefore(endDate.add(const Duration(days: 1))); date = date.add(const Duration(days: 1))) {
              if (date.year == _focusedDay.year && date.month == _focusedDay.month) {
                isInCurrentMonth = true;
                break;
              }
            }

            if (isInCurrentMonth) _monthlyMcLeaves++;

            for (var date = startDate; date.isBefore(endDate.add(const Duration(days: 1))); date = date.add(const Duration(days: 1))) {
              final normalizedDate = _normalizeDate(date);
              _addLeaveToCalendar(normalizedDate, 'mc', leave);
            }
          }
        }
      });
    } catch (e) {
      // Handle error
    }
  }

  void _addLeaveToCalendar(DateTime normalizedDate, String type, Map<String, dynamic> leaveData) {
    if (_events[normalizedDate] == null) _events[normalizedDate] = [];
    if (_leaveDetails[normalizedDate] == null) _leaveDetails[normalizedDate] = [];

    if (!_events[normalizedDate]!.contains(type)) _events[normalizedDate]!.add(type);

    final startDate = type == 'annual' ? _parseDate(leaveData['leave_date']) : _parseDate(leaveData['start_date']);
    final endDate = type == 'annual' ? _parseDate(leaveData['leave_end_date']) ?? startDate : _parseDate(leaveData['end_date']) ?? startDate;

    var detailsWithRange = Map<String, dynamic>.from(leaveData);
    detailsWithRange['start_date'] = startDate;
    detailsWithRange['end_date'] = endDate;

    _leaveDetails[normalizedDate]!.add({'type': type, 'details': detailsWithRange});
  }

  Future<String?> getUsernameByAnnualLeaveId(int annualLeaveId) async {
    try {
      final response = await http.get(Uri.parse('\$baseurl/Auth/username/\$annualLeaveId'));
      if (response.statusCode == 200) return response.body;
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> _showLeaveDetailsDialog(DateTime selectedDay) async {
    final normalizedDay = _normalizeDate(selectedDay);
    final leaveDetailsForDay = _leaveDetails[normalizedDay] ?? [];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    List<Map<String, dynamic>> processedDetails = [];

    for (var leave in leaveDetailsForDay) {
      var leaveDetails = Map<String, dynamic>.from(leave['details']);

      if (leave['type'] == 'annual') {
        final annualLeaveId = leaveDetails['annual_leave_id'];
        if (annualLeaveId != null) {
          final username = await getUsernameByAnnualLeaveId(annualLeaveId);
          leaveDetails['username'] = username ?? 'N/A';
        }
      }

      processedDetails.add({'type': leave['type'], 'details': leaveDetails});
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ModernElevatedCard(
          padding: EdgeInsets.zero,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7, maxWidth: 500),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: AppColors.gradientBlue, begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.event_note_rounded, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Leave Details',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                      IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)),
                    ],
                  ),
                ),
                Flexible(
                  child: processedDetails.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(40),
                          child: Text(
                            'No leaves on ${DateFormat('dd MMM yyyy').format(selectedDay)}',
                            style: TextStyle(color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary, fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          padding: const EdgeInsets.all(16),
                          itemCount: processedDetails.length,
                          itemBuilder: (context, index) {
                            final leave = processedDetails[index];
                            final type = leave['type'];
                            final details = leave['details'];
                            final isAnnual = type == 'annual';

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: (isAnnual ? AppColors.gradientBlue : [Colors.red.shade400, Colors.red.shade600])
                                      .map((c) => c.withOpacity(0.1))
                                      .toList(),
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: isAnnual ? Colors.blue.shade300 : Colors.red.shade300, width: 1.5),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(isAnnual ? Icons.calendar_today_rounded : Icons.medical_services_outlined,
                                          color: isAnnual ? Colors.blue.shade700 : Colors.red.shade700, size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        isAnnual ? 'Annual Leave' : 'Medical Leave',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: isAnnual ? Colors.blue.shade700 : Colors.red.shade700,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text('User: ${isAnnual ? (details['username'] ?? 'Loading...') : (details['full_name'] ?? 'N/A')}',
                                      style: const TextStyle(fontSize: 14)),
                                  Text('Leave ID: ${isAnnual ? (details['annual_leave_id'] ?? 'N/A') : (details['id'] ?? 'N/A')}',
                                      style: const TextStyle(fontSize: 14)),
                                ],
                              ),
                            );
                          },
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ModernGradientButton(text: 'Close', onPressed: () => Navigator.pop(context), gradientColors: AppColors.gradientBlue),
                ),
              ],
            ),
          ),
        ).animate().scale(duration: 300.ms),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ModernPageTemplate(
      title: 'Leave Calendar',
      gradientColors: AppColors.gradientBlue,
      showBackButton: true,
      children: [
        const SizedBox(height: 20),
        ModernGlassCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(Colors.blue, 'Annual Leave', isDark),
              const SizedBox(width: 24),
              _buildLegendItem(Colors.red, 'Medical Leave', isDark),
            ],
          ),
        ).animate(delay: 100.ms).fadeIn().slideY(begin: -0.2, end: 0),
        const SizedBox(height: 20),
        ModernElevatedCard(
          padding: const EdgeInsets.all(16),
          child: TableCalendar(
            firstDay: DateTime.utc(2021, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              _showLeaveDetailsDialog(selectedDay);
            },
            onFormatChanged: (format) => setState(() => _calendarFormat = format),
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
              _fetchAllApprovedLeaves();
            },
            eventLoader: (day) => _events[_normalizeDate(day)] ?? [],
            headerStyle: HeaderStyle(
              titleCentered: true,
              formatButtonVisible: false,
              titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
            ),
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(color: (isDark ? AppColors.darkPrimary : AppColors.primary).withOpacity(0.3), shape: BoxShape.circle),
              selectedDecoration: const BoxDecoration(gradient: LinearGradient(colors: AppColors.gradientBlue), shape: BoxShape.circle),
              weekendTextStyle: TextStyle(color: AppColors.error),
            ),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (events.isEmpty) return const SizedBox.shrink();
                return Positioned(
                  right: 4,
                  bottom: 4,
                  child: Row(
                    children: events.map((event) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: event == 'annual' ? Colors.blue : Colors.red),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        ).animate(delay: 200.ms).fadeIn().scale(),
        const SizedBox(height: 20),
        ModernGlassCard(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLeaveCountWidget(
                  icon: Icons.calendar_month_outlined, label: 'Annual', count: _monthlyAnnualLeaves, color: Colors.blue.shade700, isDark: isDark),
              Container(height: 40, width: 1, color: (isDark ? AppColors.darkBorder : AppColors.border).withOpacity(0.5)),
              _buildLeaveCountWidget(
                  icon: Icons.medical_services_outlined, label: 'Medical', count: _monthlyMcLeaves, color: Colors.red.shade700, isDark: isDark),
            ],
          ),
        ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.2, end: 0),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String text, bool isDark) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
      ],
    );
  }

  Widget _buildLeaveCountWidget({required IconData icon, required String label, required int count, required Color color, required bool isDark}) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary, fontSize: 14)),
            Text('$count', style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }
}
