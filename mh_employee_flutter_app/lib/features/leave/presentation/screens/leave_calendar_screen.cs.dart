import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
// import 'package:mh_employee_app/core/network/api_client.dart'; // TODO: Migrate to ApiClient
import 'package:mh_employee_app/services/api_service.dart';

class LeaveCalendarScreen extends StatefulWidget {
  const LeaveCalendarScreen({Key? key}) : super(key: key);

  @override
  _LeaveCalendarScreenState createState() => _LeaveCalendarScreenState();
}

class _LeaveCalendarScreenState extends State<LeaveCalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<dynamic>> _events = {};
  List<dynamic> _selectedEvents = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadLeaveData();
  }

  Future<void> _loadLeaveData() async {
    setState(() => _isLoading = true);
    try {
      // TODO: Migrate to ApiClient
      final leaves = await ApiService.getLeaveCalendar(
        _focusedDay.year,
        _focusedDay.month,
      );

      final events = <DateTime, List<dynamic>>{};
      for (var leave in leaves) {
        final date = DateTime(
          leave.leaveDate.year,
          leave.leaveDate.month,
          leave.leaveDate.day,
        );
        if (events[date] == null) events[date] = [];
        events[date]!.add(leave);
      }

      setState(() {
        _events = events;
        if (_selectedDay != null) {
          _selectedEvents = _getEventsForDay(_selectedDay!);
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading leave data: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    return _events[day] ?? [];
  }

  Color _getLeaveTypeColor(String leaveType) {
    return leaveType == 'Annual' ? Colors.blue : Colors.red;
  }

  Widget _buildEventMarker(List events, DateTime day) {
    return Positioned(
      bottom: 1,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: events.take(3).map((event) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 1),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _getLeaveTypeColor(event.leaveType),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave Calendar'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            eventLoader: _getEventsForDay,
            calendarStyle: const CalendarStyle(
              markersMaxCount: 3,
              markerSize: 6,
            ),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
                _selectedEvents = _getEventsForDay(selectedDay);
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
              _loadLeaveData();
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, day, events) {
                if (events.isNotEmpty) {
                  return _buildEventMarker(events, day);
                }
                return null;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem('Annual Leave', Colors.blue),
                const SizedBox(width: 20),
                _buildLegendItem('MC Leave', Colors.red),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: _selectedEvents.length,
              itemBuilder: (context, index) {
                final event = _selectedEvents[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getLeaveTypeColor(event.leaveType),
                      child: Text(
                        event.leaveType[0],
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(event.employeeName),
                    subtitle: Text(
                      '${event.reason}\n${DateFormat('dd/MM/yyyy').format(event.leaveDate)}',
                    ),
                    trailing: Text(
                      '${event.numberOfDays} day(s)',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }
}



