import 'dart:convert';
import 'dart:typed_data';
import '../../../../shared/models/department.dart';
import '../../domain/entities/user.dart' as entity;

export '../../../../shared/models/department.dart';

enum Status { pending, approved, rejected, active }

enum ActiveStatus { active, inactive }

class UserModel {
  final String id;
  final String fullName;
  final String nickName;
  final String nickname;
  final String email;
  final Status status;
  final ActiveStatus activeStatus;
  final String nric;
  final String? tin;
  final String? epf;
  final String role;
  final Department department;
  final DateTime birthday;
  final DateTime dateJoined;
  final DateTime? changePasswordDate;
  Uint8List? profilePicture;
  final String? token;

  UserModel({
    required this.id,
    required this.fullName,
    required this.nickName,
    required this.nickname,
    required this.email,
    required this.status,
    required this.activeStatus,
    required this.nric,
    this.tin,
    this.epf,
    required this.role,
    required this.department,
    required this.birthday,
    required this.dateJoined,
    this.changePasswordDate,
    this.profilePicture,
    this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id']?.toString() ?? json['Id']?.toString() ?? '').isNotEmpty
          ? (json['id']?.toString() ?? json['Id']?.toString() ?? '')
          : '',
      fullName: json['fullName'] ?? json['FullName'] ?? json['full_name'] ?? '',
      nickname: json['nickname'] ?? json['Nickname'] ?? '',
      nickName: json['nickName'] ??
          json['NickName'] ??
          json['nick_name'] ??
          (json['fullName']?.split(' ').first ?? json['FullName']?.split(' ').first ?? ''),
      email: json['email'] ?? json['Email'] ?? '',
      status: _parseStatus(json['status'] ?? json['Status']),
      activeStatus:
      _parseActiveStatus(json['activeStatus'] ?? json['ActiveStatus'] ?? json['active_status']),
      nric: json['nric'] ?? json['NRIC'] ?? '',
      tin: json['tin'] ?? json['TIN'],
      epf: json['epf'] ?? json['EPF'] ?? json['epf_no'],
      role: json['role'] ?? json['Role'] ?? 'user',
      department: (json['department'] ?? json['Department']) != null
          ? Department.fromJson(json['department'] ?? json['Department'])
          : Department(id: '', name: 'Unknown'),
      birthday: _parseDateTime(json['birthday'] ?? json['Birthday']),
      dateJoined: _parseDateTime(json['dateJoined'] ??
          json['DateJoined'] ??
          json['date_joined'] ??
          DateTime.now().toIso8601String()),
      changePasswordDate: (json['changePasswordDate'] ?? json['ChangePasswordDate']) != null
          ? _parseDateTime(json['changePasswordDate'] ?? json['ChangePasswordDate'])
          : null,
      profilePicture: (json['profilePicture'] ?? json['ProfilePicture']) != null
          ? base64Decode(json['profilePicture'] ?? json['ProfilePicture'])
          : null,
      token: json['token'] ?? json['Token'],
    );
  }

  static DateTime _parseDateTime(dynamic dateTime) {
    try {
      if (dateTime == null) return DateTime.now();

      if (dateTime is String) {
        return DateTime.parse(dateTime);
      }

      if (dateTime is DateTime) {
        return dateTime;
      }

      return DateTime.now();
    } catch (e) {
      print('Error parsing date: $dateTime');
      return DateTime.now();
    }
  }

  static Status _parseStatus(dynamic statusValue) {
    if (statusValue == null) return Status.pending;

    // Handle both enum string representations
    if (statusValue is String) {
      return Status.values.firstWhere(
            (e) =>
        e.toString().split('.').last.toLowerCase() ==
            statusValue.toLowerCase(),
        orElse: () => Status.pending,
      );
    }

    return Status.pending;
  }

  static ActiveStatus _parseActiveStatus(dynamic activeStatusValue) {
    if (activeStatusValue == null) return ActiveStatus.inactive;

    // Handle both enum string representations
    if (activeStatusValue is String) {
      return ActiveStatus.values.firstWhere(
            (e) =>
        e.toString().split('.').last.toLowerCase() ==
            activeStatusValue.toLowerCase(),
        orElse: () => ActiveStatus.inactive,
      );
    }

    return ActiveStatus.inactive;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'nickName': nickName,
      'nickname': nickname,
      'email': email,
      'status': status.toString().split('.').last,
      'activeStatus': activeStatus.toString().split('.').last,
      'nric': nric,
      'tin': tin,
      'epf': epf,
      'role': role,
      'department': department.toJson(),
      'birthday': birthday.toIso8601String(),
      'dateJoined': dateJoined.toIso8601String(),
      'changePasswordDate': changePasswordDate?.toIso8601String(),
      'profilePicture':
          profilePicture != null ? base64Encode(profilePicture!) : null,
      'token': token,
    };
  }

  // Convert model to entity
  entity.User toEntity() {
    return entity.User(
      id: int.tryParse(id) ?? 0,
      name: fullName,
      email: email,
      role: role,
      department: department.name,
      departmentId: int.tryParse(department.id) ?? 0,
    );
  }

  // Create model from entity
  factory UserModel.fromEntity(entity.User user) {
    return UserModel(
      id: user.id.toString(),
      fullName: user.name,
      nickName: user.name.split(' ').first,
      nickname: user.name.split(' ').first,
      email: user.email,
      status: Status.active,
      activeStatus: ActiveStatus.active,
      nric: '',
      role: user.role ?? 'user',
      department: Department(
        id: user.departmentId?.toString() ?? '',
        name: user.department ?? 'Unknown',
      ),
      birthday: DateTime.now(),
      dateJoined: DateTime.now(),
    );
  }
}

// Type alias for backward compatibility
typedef User = UserModel;
