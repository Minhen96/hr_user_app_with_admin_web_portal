import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:mh_employee_app/core/theme/app_colors.dart';
import 'package:mh_employee_app/core/constants/api_constants.dart';
import 'package:mh_employee_app/shared/widgets/modern_glass_card.dart';
import 'package:mh_employee_app/shared/widgets/modern_buttons.dart';

// Attendance Record Model
class AttendanceRecord {
  final DateTime date;
  final String timeIn;
  final String timeOut;
  final String status;
  final String? placename;

  AttendanceRecord({
    required this.date,
    required this.timeIn,
    required this.timeOut,
    required this.status,
    required this.placename,
  });
}

class AttendanceProfileScreenNew extends StatefulWidget {
  final String username;
  final int userid;

  const AttendanceProfileScreenNew({
    super.key,
    required this.username,
    required this.userid,
  });

  @override
  _AttendanceProfileScreenNewState createState() =>
      _AttendanceProfileScreenNewState();
}

class _AttendanceProfileScreenNewState
    extends State<AttendanceProfileScreenNew> {
  bool _isLoading = true;
  bool _hasTimedInToday = false;
  late Timer _timer;
  DateTime _currentDateTime = DateTime.now();
  List<AttendanceRecord> attendanceHistory = [];

  @override
  void initState() {
    super.initState();
    _fetchCurrentDaySubmissions();
    // Update time every second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentDateTime = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _fetchCurrentDaySubmissions() async {
    setState(() => _isLoading = true);

    try {
      final response = await http.get(
        Uri.parse(
            '${ApiConstants.baseAdminUrl}${ApiConstants.attendanceCurrentDay}/${widget.userid}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        setState(() {
          attendanceHistory = data.map((item) {
            DateTime? timeIn = item['timeIn'] != null ? DateTime.parse(item['timeIn']) : null;
            DateTime today = DateTime.now();
            DateTime nineAM = DateTime(today.year, today.month, today.day, 9, 15);
            String place = item['placeName'] ?? '';

            String status = 'Incomplete';
            if (item['timeOut'] != null) {
              status = (place == 'Block A' || place == 'Block B') && (timeIn?.isAfter(nineAM) ?? false)
                  ? 'Late'
                  : 'Completed';
            } else {
              status = 'Pending';
            }

            return AttendanceRecord(
              date: item['dateSubmission'] != null ? DateTime.parse(item['dateSubmission']) : DateTime.now(),
              timeIn: timeIn != null ? DateFormat('hh:mm a').format(timeIn) : 'N/A',
              timeOut: item['timeOut'] != null
                  ? DateFormat('hh:mm a').format(DateTime.parse(item['timeOut']))
                  : 'Not Clocked Out',
              status: status,
              placename: item['placeName'],
            );
          }).toList();

          attendanceHistory.sort((a, b) => a.timeIn.compareTo(b.timeIn));

          _hasTimedInToday = attendanceHistory.any((record) {
            return _isSameDay(record.date, DateTime.now()) &&
                record.timeOut == 'Not Clocked Out';
          });

          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to load attendance history'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  List<Color> _getStatusGradient(String status) {
    switch (status) {
      case 'Completed':
        return AppColors.gradientGreen;
      case 'Pending':
        return AppColors.gradientOrange;
      case 'Late':
        return [AppColors.error, const Color(0xFFDC2626)];
      default:
        return AppColors.primaryGradient;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Completed':
        return Icons.check_circle_rounded;
      case 'Pending':
        return Icons.pending_rounded;
      case 'Late':
        return Icons.warning_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  void _showAttendanceDetailsModal(BuildContext context, AttendanceRecord record) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          children: [
            // Drag Handle
            Container(
              width: 50,
              height: 5,
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBorder : AppColors.border,
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _getStatusGradient(record.status),
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
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
                      _getStatusIcon(record.status),
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Attendance Details',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          record.status,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    _buildDetailRow(
                      Icons.location_on_rounded,
                      'Location',
                      record.placename ?? 'N/A',
                      isDark,
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      Icons.calendar_today_rounded,
                      'Date',
                      DateFormat('EEEE, MMMM d, yyyy').format(record.date),
                      isDark,
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      Icons.login_rounded,
                      'Time In',
                      record.timeIn,
                      isDark,
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      Icons.logout_rounded,
                      'Time Out',
                      record.timeOut,
                      isDark,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
      IconData icon, String title, String value, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceVariant
            : AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: AppColors.primaryGradient,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: RefreshIndicator(
        color: isDark ? AppColors.darkPrimary : AppColors.primary,
        onRefresh: _fetchCurrentDaySubmissions,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Modern Gradient App Bar
            SliverAppBar(
              expandedHeight: 200,
              floating: false,
              pinned: true,
              automaticallyImplyLeading: false,
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: AppColors.gradientBlue,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: FlexibleSpaceBar(
                  title: const Text(
                    'Attendance',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  centerTitle: false,
                  titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
                  background: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          CircleAvatar(
                            radius: 35,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            child: Text(
                              widget.username.substring(0, 2).toUpperCase(),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.username,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),

            // Stats Cards
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: ModernGlassCard(
                        padding: const EdgeInsets.all(16),
                        gradient: AppColors.gradientBlue
                            .map((c) => c.withOpacity(0.1))
                            .toList(),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: AppColors.gradientBlue,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.calendar_today_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              DateFormat('d MMM').format(_currentDateTime),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              DateFormat('EEEE').format(_currentDateTime),
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ).animate(delay: 100.ms).fadeIn().scale(),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ModernGlassCard(
                        padding: const EdgeInsets.all(16),
                        gradient: AppColors.gradientGreen
                            .map((c) => c.withOpacity(0.1))
                            .toList(),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: AppColors.gradientGreen,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.access_time_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              DateFormat('hh:mm a').format(_currentDateTime),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              'Malaysia Time',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ).animate(delay: 200.ms).fadeIn().scale(),
                    ),
                  ],
                ),
              ),
            ),

            // Clock In/Out Button
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ModernGradientButton(
                  text: _hasTimedInToday ? 'Clock Out' : 'Clock In',
                  icon: _hasTimedInToday
                      ? Icons.logout_rounded
                      : Icons.login_rounded,
                  onPressed: () {
                    // Navigate to camera screen
                    // TODO: Implement navigation to AttendanceScreen
                  },
                  gradientColors:
                      _hasTimedInToday ? AppColors.gradientOrange : AppColors.gradientGreen,
                  height: 56,
                ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.2, end: 0),
              ),
            ),

            // Attendance History Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
                child: Row(
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
                        Icons.history_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "Today's Records",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Attendance History List
            _isLoading
                ? SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(60),
                        child: CircularProgressIndicator(
                          color: isDark
                              ? AppColors.darkPrimary
                              : AppColors.primary,
                        ),
                      ),
                    ),
                  )
                : attendanceHistory.isEmpty
                    ? SliverToBoxAdapter(
                        child: Center(
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
                                    Icons.event_busy_rounded,
                                    size: 48,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  'No records today',
                                  style: TextStyle(
                                    color: isDark
                                        ? AppColors.darkTextPrimary
                                        : AppColors.textPrimary,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Please clock in to start tracking',
                                  style: TextStyle(
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.textSecondary,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final record = attendanceHistory[index];
                              return ModernElevatedCard(
                                margin: const EdgeInsets.only(bottom: 16),
                                padding: EdgeInsets.zero,
                                onTap: () =>
                                    _showAttendanceDetailsModal(context, record),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: _getStatusGradient(record.status)
                                          .map((c) => c.withOpacity(0.05))
                                          .toList(),
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: _getStatusGradient(
                                                record.status),
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          _getStatusIcon(record.status),
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.login_rounded,
                                                  size: 16,
                                                  color: isDark
                                                      ? AppColors
                                                          .darkTextSecondary
                                                      : AppColors.textSecondary,
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  record.timeIn,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: isDark
                                                        ? AppColors
                                                            .darkTextPrimary
                                                        : AppColors.textPrimary,
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                Icon(
                                                  Icons.logout_rounded,
                                                  size: 16,
                                                  color: isDark
                                                      ? AppColors
                                                          .darkTextSecondary
                                                      : AppColors.textSecondary,
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  record.timeOut,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: isDark
                                                        ? AppColors
                                                            .darkTextPrimary
                                                        : AppColors.textPrimary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.location_on_rounded,
                                                  size: 14,
                                                  color: isDark
                                                      ? AppColors
                                                          .darkTextSecondary
                                                      : AppColors.textSecondary,
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  record.placename ?? 'N/A',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: isDark
                                                        ? AppColors
                                                            .darkTextSecondary
                                                        : AppColors
                                                            .textSecondary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: _getStatusGradient(
                                                record.status),
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          record.status,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                                  .animate(delay: (100 * index).ms)
                                  .fadeIn()
                                  .slideX(begin: 0.2, end: 0);
                            },
                            childCount: attendanceHistory.length,
                          ),
                        ),
                      ),

            // Bottom spacing
            const SliverToBoxAdapter(
              child: SizedBox(height: 20),
            ),
          ],
        ),
      ),
    );
  }
}
