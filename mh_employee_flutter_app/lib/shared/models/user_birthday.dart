class UserBirthday {
  final String fullName;
  final DateTime birthDate;
  final String department;

  UserBirthday({
    required this.fullName,
    required this.birthDate,
    required this.department,
  });

  factory UserBirthday.fromJson(Map<String, dynamic> json) {
    return UserBirthday(
      fullName: json['fullName'] as String,
      birthDate: DateTime.parse(json['birthDate'] as String),
      department: json['department'] as String,
    );
  }
}
