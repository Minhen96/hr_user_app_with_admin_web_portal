import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String name;
  final String email;
  final String? role;
  final String? department;
  final int? departmentId;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.role,
    this.department,
    this.departmentId,
  });

  @override
  List<Object?> get props => [id, name, email, role, department, departmentId];
}


