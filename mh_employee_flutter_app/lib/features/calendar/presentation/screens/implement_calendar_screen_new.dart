import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:mh_employee_app/core/theme/app_colors.dart';
import 'package:mh_employee_app/shared/widgets/modern_glass_card.dart';
import 'package:mh_employee_app/shared/widgets/modern_buttons.dart';
import 'package:mh_employee_app/services/api_service.dart';
import 'package:mh_employee_app/features/calendar/data/models/event_model.dart';

class ImplementCalendarScreenNew extends StatefulWidget {
  final int userid;

  const ImplementCalendarScreenNew({super.key, required this.userid});

  @override
  _ImplementCalendarScreenNewState createState() =>
      _ImplementCalendarScreenNewState();
}

class _ImplementCalendarScreenNewState
    extends State<ImplementCalendarScreenNew> {
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDate = DateTime.now();
  List<Event> _dayEvents = [];
  List<Event> _monthEvents = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() => _isLoading = true);
    try {
      final dayEvents = await ApiService.getEvents(_selectedDate);
      final monthEvents = await ApiService.getMonthEvents(
        _selectedDate.year,
        _selectedDate.month,
      );

      monthEvents.sort((a, b) => a.date.compareTo(b.date));

      setState(() {
        _dayEvents = dayEvents;
        _monthEvents = monthEvents;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _dayEvents = [];
        _monthEvents = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    await _loadEvents();
  }

  void _selectDate(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDate = selectedDay;
      _focusedDate = focusedDay;
    });
    _loadEvents();
  }

  void _showEventDialog(Event event) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ModernElevatedCard(
          padding: EdgeInsets.zero,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Gradient Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: AppColors.gradientGreen,
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
                        Icons.event_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            DateFormat('EEEE, MMM d, yyyy').format(event.date),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
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

              // Content
              if (event.description != null && event.description!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    event.description!,
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                      height: 1.6,
                    ),
                  ),
                ),

              // Actions
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: ModernOutlineButton(
                        text: 'Edit',
                        icon: Icons.edit_rounded,
                        onPressed: () {
                          Navigator.pop(context);
                          _showEditEventDialog(event);
                        },
                        borderColor: isDark
                            ? AppColors.darkPrimary
                            : AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ModernGradientButton(
                        text: 'Delete',
                        icon: Icons.delete_rounded,
                        onPressed: () {
                          Navigator.pop(context);
                          _showDeleteConfirmation(event);
                        },
                        gradientColors: [
                          AppColors.error,
                          const Color(0xFFDC2626)
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).animate().scale(duration: 300.ms),
      ),
    );
  }

  void _showAddEventDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 20,
          left: 20,
          right: 20,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 50,
              height: 5,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBorder : AppColors.border,
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            // Title
            Text(
              'Add New Event',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color:
                    isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),

            // Form fields
            TextField(
              controller: titleController,
              style: TextStyle(
                color:
                    isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                labelText: 'Event Title',
                labelStyle: TextStyle(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                ),
                prefixIcon: Icon(
                  Icons.title_rounded,
                  color: isDark ? AppColors.darkPrimary : AppColors.primary,
                ),
                filled: true,
                fillColor: isDark
                    ? AppColors.darkSurfaceVariant
                    : AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
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
            const SizedBox(height: 16),

            TextField(
              controller: descriptionController,
              maxLines: 3,
              style: TextStyle(
                color:
                    isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                labelText: 'Description',
                labelStyle: TextStyle(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                ),
                prefixIcon: Icon(
                  Icons.description_rounded,
                  color: isDark ? AppColors.darkPrimary : AppColors.primary,
                ),
                filled: true,
                fillColor: isDark
                    ? AppColors.darkSurfaceVariant
                    : AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
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

            // Submit button
            ModernGradientButton(
              text: 'Add Event',
              icon: Icons.add_rounded,
              onPressed: () async {
                if (titleController.text.isNotEmpty) {
                  try {
                    final newEvent = Event(
                      title: titleController.text.trim(),
                      description: descriptionController.text.trim(),
                      date: _selectedDate,
                      userId: widget.userid,
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                    );
                    await ApiService.createEvent(newEvent);
                    Navigator.pop(context);
                    _loadEvents();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Event added successfully'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to add event: $e'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  }
                }
              },
              gradientColors: AppColors.gradientGreen,
              width: double.infinity,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showEditEventDialog(Event event) {
    // Similar implementation to add dialog
    _showAddEventDialog(); // Simplified - implement full edit logic
  }

  void _showDeleteConfirmation(Event event) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        title: Text(
          'Delete Event',
          style: TextStyle(
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${event.title}"?',
          style: TextStyle(
            color:
                isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
          ),
        ),
        actions: [
          ModernOutlineButton(
            text: 'Cancel',
            onPressed: () => Navigator.pop(context),
          ),
          ModernGradientButton(
            text: 'Delete',
            onPressed: () async {
              try {
                if (event.id != null) {
                  await ApiService.deleteEvent(event.id!);
                  Navigator.pop(context);
                  _loadEvents();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Event deleted'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              } catch (e) {
                Navigator.pop(context);
              }
            },
            gradientColors: [AppColors.error, const Color(0xFFDC2626)],
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
        onRefresh: _onRefresh,
        child: CustomScrollView(
          slivers: [
            // Gradient App Bar
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: AppColors.gradientGreen,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const FlexibleSpaceBar(
                  title: Text(
                    'Calendar',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  centerTitle: false,
                  titlePadding: EdgeInsets.only(left: 56, bottom: 16),
                ),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),

            // Calendar Widget
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: ModernElevatedCard(
                  padding: const EdgeInsets.all(16),
                  child: TableCalendar(
                    firstDay: DateTime(2020),
                    lastDay: DateTime(2030),
                    focusedDay: _focusedDate,
                    selectedDayPredicate: (day) =>
                        isSameDay(_selectedDate, day),
                    onDaySelected: _selectDate,
                    onPageChanged: (focusedDay) {
                      setState(() => _focusedDate = focusedDay);
                      _loadEvents();
                    },
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: AppColors.gradientBlue,
                        ),
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: AppColors.gradientGreen,
                        ),
                        shape: BoxShape.circle,
                      ),
                      markerDecoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: AppColors.gradientOrange,
                        ),
                        shape: BoxShape.circle,
                      ),
                      defaultTextStyle: TextStyle(
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                      ),
                      weekendTextStyle: TextStyle(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                    ),
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                      ),
                      leftChevronIcon: Icon(
                        Icons.chevron_left,
                        color: isDark
                            ? AppColors.darkPrimary
                            : AppColors.primary,
                      ),
                      rightChevronIcon: Icon(
                        Icons.chevron_right,
                        color: isDark
                            ? AppColors.darkPrimary
                            : AppColors.primary,
                      ),
                    ),
                    eventLoader: (day) {
                      return _monthEvents
                          .where((event) => isSameDay(event.date, day))
                          .toList();
                    },
                  ),
                ).animate(delay: 100.ms).fadeIn().scale(),
              ),
            ),

            // Events for Selected Date
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: AppColors.gradientGreen,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.event_note_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Events',
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
                    ModernIconButton(
                      icon: Icons.add_rounded,
                      onPressed: _showAddEventDialog,
                      size: 40,
                      gradientColors: AppColors.gradientGreen,
                    ),
                  ],
                ),
              ),
            ),

            // Events List
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
                : _dayEvents.isEmpty
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
                                      colors: AppColors.gradientGreen,
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
                                  'No events for this date',
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
                                  'Tap + to add a new event',
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
                              final event = _dayEvents[index];
                              return ModernElevatedCard(
                                margin: const EdgeInsets.only(bottom: 16),
                                padding: EdgeInsets.zero,
                                onTap: () => _showEventDialog(event),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: AppColors.gradientGreen
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
                                          gradient: const LinearGradient(
                                            colors: AppColors.gradientGreen,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: const Icon(
                                          Icons.event_rounded,
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
                                            Text(
                                              event.title,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: isDark
                                                    ? AppColors.darkTextPrimary
                                                    : AppColors.textPrimary,
                                              ),
                                            ),
                                            if (event.description != null &&
                                                event.description!.isNotEmpty)
                                              Padding(
                                                padding:
                                                    const EdgeInsets.only(
                                                        top: 6),
                                                child: Text(
                                                  event.description!,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: isDark
                                                        ? AppColors
                                                            .darkTextSecondary
                                                        : AppColors
                                                            .textSecondary,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        size: 16,
                                        color: isDark
                                            ? AppColors.darkTextSecondary
                                            : AppColors.textSecondary,
                                      ),
                                    ],
                                  ),
                                ),
                              )
                                  .animate(delay: (100 * index).ms)
                                  .fadeIn()
                                  .slideX(begin: 0.2, end: 0);
                            },
                            childCount: _dayEvents.length,
                          ),
                        ),
                      ),

            // Bottom spacing
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
    );
  }
}
