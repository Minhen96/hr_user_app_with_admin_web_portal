class Holiday {
  final DateTime holidayDate;
  final String holidayName;

  Holiday({
    required this.holidayDate,
    required this.holidayName,
  });

  factory Holiday.fromJson(Map<String, dynamic> json) {
    return Holiday(
      holidayDate: DateTime.parse(json['holidayDate']),
      holidayName: json['holidayName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'holidayDate': holidayDate.toIso8601String(),
      'holidayName': holidayName,
    };
  }
}
