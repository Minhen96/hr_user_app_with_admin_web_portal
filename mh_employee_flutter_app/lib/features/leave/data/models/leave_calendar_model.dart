class LeaveCalendar {
  final int id;
  final DateTime leaveDate;
  final String employeeName;
  final String reason;
  final int numberOfDays;
  final String status;
  final int? approvedBy;
  final String leaveType;  // "Annual" or "MC"

  LeaveCalendar({
    required this.id,
    required this.leaveDate,
    required this.employeeName,
    required this.reason,
    required this.numberOfDays,
    required this.status,
    this.approvedBy,
    required this.leaveType,
  });

  factory LeaveCalendar.fromJson(Map<String, dynamic> json) {
    return LeaveCalendar(
      id: json['id'],
      leaveDate: DateTime.parse(json['leaveDate']),
      employeeName: json['employeeName'],
      reason: json['reason'],
      numberOfDays: json['numberOfDays'],
      status: json['status'],
      approvedBy: json['approvedBy'],
      leaveType: json['leaveType'],
    );
  }
}
