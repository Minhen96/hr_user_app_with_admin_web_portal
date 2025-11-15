import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:mh_employee_app/core/theme/app_colors.dart';
import 'package:mh_employee_app/shared/widgets/modern_glass_card.dart';
import 'package:mh_employee_app/shared/widgets/modern_buttons.dart';

class AnnualLeaveScreenNew extends StatefulWidget {
  final int userid;

  const AnnualLeaveScreenNew({super.key, required this.userid});

  @override
  _AnnualLeaveScreenNewState createState() => _AnnualLeaveScreenNewState();
}

enum LeaveType { fullDay, firstHalfDay, secondHalfDay }

class _AnnualLeaveScreenNewState extends State<AnnualLeaveScreenNew> {
  final TextEditingController _description = TextEditingController();
  double _totalDays = 0;
  int _entitlement = 0;
  int _anlid = 0;
  final DateTime _submissionDate = DateTime.now();

  Map<DateTime, LeaveType> _dateLeaveTypes = {};
  List<DateTime> _selectedDates = [];

  double ttDaysAnl = 0.0;
  double totalbalance = 0.0;
  bool isLoading = false;
  String? error;

  String baseurl = "http://localhost:5000/api";

  @override
  void initState() {
    super.initState();
    _fetchEntitlementandId();
  }

  Future<void> _fetchEntitlementandId() async {
    try {
      final response = await http.get(Uri.parse('$baseurl/Leave/entitlement/${widget.userid}'));
      if (response.statusCode == 200) {
        final annualleavedata = jsonDecode(response.body);
        setState(() {
          _entitlement = annualleavedata['entitlement'];
          _anlid = annualleavedata['annualLeaveId'];
        });
        await fetchAndCalculateLeaveBalance();
      }
    } catch (e) {
      print('Error fetching entitlement: $e');
    }
  }

  Future<void> fetchAndCalculateLeaveBalance() async {
    try {
      final response = await http.get(
        Uri.parse('$baseurl/Leave/ANLapprove-leaves/$_anlid'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> leaveData = json.decode(response.body);
        double totalanldays = 0.0;
        for (var leave in leaveData) {
          totalanldays += (leave['no_of_days'] ?? 0).toDouble();
        }

        setState(() {
          ttDaysAnl = totalanldays;
          totalbalance = _entitlement - totalanldays;
        });
      }
    } catch (e) {
      print('Error fetching leave data: $e');
    }
  }

  Future<void> _showMultipleDatePicker() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<DateTime>? picked = await showDialog<List<DateTime>>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: ModernElevatedCard(
            padding: EdgeInsets.zero,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Gradient Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: AppColors.gradientBlue,
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
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.calendar_month_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Select Multiple Dates',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Calendar
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: CalendarDatePicker2(
                      config: CalendarDatePicker2Config(
                        calendarType: CalendarDatePicker2Type.multi,
                        selectedDayHighlightColor: isDark ? AppColors.darkPrimary : AppColors.primary,
                      ),
                      value: _selectedDates,
                      onValueChanged: (dates) {
                        setState(() {
                          _selectedDates = dates.cast<DateTime>();
                          for (var date in _selectedDates) {
                            if (!_dateLeaveTypes.containsKey(date)) {
                              _dateLeaveTypes[date] = LeaveType.fullDay;
                            }
                          }
                          _dateLeaveTypes.removeWhere((date, _) => !_selectedDates.contains(date));
                          _updateTotalDays();
                        });
                      },
                    ),
                  ),
                ),
                // Actions
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ModernOutlineButton(
                        text: 'Cancel',
                        onPressed: () => Navigator.pop(context),
                        borderColor: isDark ? AppColors.darkBorder : AppColors.border,
                        textColor: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 12),
                      ModernGradientButton(
                        text: 'OK',
                        onPressed: () => Navigator.pop(context, _selectedDates),
                        gradientColors: AppColors.gradientBlue,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().scale(duration: 300.ms),
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDates = picked;
        _updateTotalDays();
      });
    }
  }

  void _updateTotalDays() {
    double total = 0;
    for (var date in _selectedDates) {
      switch (_dateLeaveTypes[date]) {
        case LeaveType.fullDay:
          total += 1.0;
          break;
        case LeaveType.firstHalfDay:
        case LeaveType.secondHalfDay:
          total += 0.5;
          break;
        default:
          total += 1.0;
      }
    }
    setState(() {
      _totalDays = total;
    });
  }

  Future<void> _submitLeave() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_selectedDates.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: ModernElevatedCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(colors: [AppColors.error, Color(0xFFDC2626)]),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.error_outline_rounded, color: Colors.white, size: 48),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Error',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text('Please select dates before submitting.'),
                  const SizedBox(height: 24),
                  ModernGradientButton(
                    text: 'OK',
                    onPressed: () => Navigator.of(context).pop(),
                    gradientColors: AppColors.primaryGradient,
                    width: double.infinity,
                  ),
                ],
              ),
            ),
          );
        },
      );
      return;
    }

    setState(() => isLoading = true);

    List<Map<String, dynamic>> leaveSubmissions = _selectedDates.map((date) {
      String leaveTypeDescription;
      double leaveDays;

      switch (_dateLeaveTypes[date]) {
        case LeaveType.fullDay:
          leaveTypeDescription = 'Full Day';
          leaveDays = 1.0;
          break;
        case LeaveType.firstHalfDay:
          leaveTypeDescription = 'Morning Half Day';
          leaveDays = 0.5;
          break;
        case LeaveType.secondHalfDay:
          leaveTypeDescription = 'Evening Half Day';
          leaveDays = 0.5;
          break;
        default:
          leaveTypeDescription = 'Full Day';
          leaveDays = 1.0;
      }

      return {
        'leave_date': date.toIso8601String(),
        'leave_end_date': date.toIso8601String(),
        'reason': _description.text.isEmpty
            ? '$leaveTypeDescription Leave'
            : '${_description.text} ($leaveTypeDescription)',
        'status': 'Pending',
        'approved_by': null,
        'approve_signature_id': null,
        'annual_leave_id': _anlid,
        'no_of_days': leaveDays,
        'date_submission': _submissionDate.toIso8601String()
      };
    }).toList();

    bool hasError = false;
    for (var submission in leaveSubmissions) {
      final response = await http.post(
        Uri.parse('$baseurl/leave/submit'),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(submission),
      );

      if (response.statusCode != 201) {
        hasError = true;
        break;
      }
    }

    setState(() => isLoading = false);

    if (!hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Leave submitted successfully')),
      );
      _clearForm();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to submit some leave requests')),
      );
    }
  }

  void _clearForm() {
    setState(() {
      _selectedDates = [];
      _dateLeaveTypes.clear();
      _description.clear();
      _totalDays = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: RefreshIndicator(
        color: isDark ? AppColors.darkPrimary : AppColors.primary,
        onRefresh: fetchAndCalculateLeaveBalance,
        child: CustomScrollView(
          slivers: [
            // Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Form Card
                    ModernGlassCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(colors: AppColors.gradientBlue),
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                ),
                                child: const Icon(Icons.edit_calendar_rounded, color: Colors.white, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Leave Request',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Date Selection Button
                          ModernOutlineButton(
                            text: _selectedDates.isEmpty
                                ? 'Select Dates'
                                : '${_selectedDates.length} date(s) selected',
                            icon: Icons.calendar_month_rounded,
                            onPressed: _showMultipleDatePicker,
                            borderColor: isDark ? AppColors.darkPrimary : AppColors.primary,
                            textColor: isDark ? AppColors.darkPrimary : AppColors.primary,
                          ),

                          if (_selectedDates.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: (isDark ? AppColors.darkPrimary : AppColors.primary).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDark ? AppColors.darkPrimary : AppColors.primary,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.info_outline_rounded,
                                    color: isDark ? AppColors.darkPrimary : AppColors.primary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Total Days: ${_totalDays.toStringAsFixed(1)}',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 16),

                          // Description Field
                          TextFormField(
                            controller: _description,
                            maxLines: 3,
                            style: TextStyle(
                              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Reason (Optional)',
                              labelStyle: TextStyle(
                                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                              ),
                              hintText: 'Enter reason for leave...',
                              hintStyle: TextStyle(
                                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                              ),
                              prefixIcon: Icon(
                                Icons.notes_rounded,
                                color: isDark ? AppColors.darkPrimary : AppColors.primary,
                              ),
                              filled: true,
                              fillColor: isDark ? AppColors.darkSurfaceVariant : AppColors.surface,
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
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Submit Button
                          ModernGradientButton(
                            text: 'Submit Leave Request',
                            icon: Icons.send_rounded,
                            onPressed: isLoading ? null : _submitLeave,
                            gradientColors: AppColors.gradientGreen,
                            width: double.infinity,
                          ),
                        ],
                      ),
                    ).animate(delay: 200.ms).fadeIn().slideX(begin: 0.2, end: 0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, bool isDark) {
    return Column(
      children: [
        Icon(icon, color: isDark ? AppColors.darkPrimary : AppColors.primary, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _description.dispose();
    super.dispose();
  }
}
