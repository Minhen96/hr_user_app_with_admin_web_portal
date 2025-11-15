// equipment_request.dart
import 'package:flutter/material.dart';
// import '../baseClasses/base_equipment_item.dart'; // TODO: Create base class or remove inheritance
import 'package:mh_employee_app/shared/models/signature_data.dart';

enum RequestStatus {
  pending,
  approved,
  rejected
}

class EquipmentRequest {
  final int id;
  final String requesterId;
  final String requesterName;
  final DateTime dateRequested;
  final RequestStatus status;
  final List<EquipmentItem> items;
  final SignatureData? signature;
  final String? receivedDetails;
  final DateTime? dateReceived;
  final DateTime createdAt;
  final DateTime updatedAt;

  EquipmentRequest({
    required this.id,
    required this.requesterId,
    required this.requesterName,
    required this.dateRequested,
    required this.status,
    required this.items,
    this.signature,
    this.receivedDetails,
    this.dateReceived,
    required this.createdAt,
    required this.updatedAt,
  });

  String get requestedBy => requesterName;

  List<Offset> get signaturePoints => signature?.points ?? [];

  factory EquipmentRequest.fromJson(Map<String, dynamic> json) {
    // Handle nested requester object
    final requester = json['requester'] as Map<String, dynamic>?;

    return EquipmentRequest(
      id: json['id'],
      requesterId: (json['requesterId'] ?? requester?['id'])?.toString() ?? '',
      requesterName: requester?['fullName'] ?? '',
      dateRequested: DateTime.parse(json['dateRequested']),
      status: RequestStatus.values.firstWhere(
            (e) => e.toString().split('.').last == json['status'],
        orElse: () => RequestStatus.pending,
      ),
      items: ((json['items'] ?? []) as List)
          .map((item) => EquipmentItem.fromJson(item))
          .toList(),
      signature: json['signature'] != null
          ? SignatureData.fromJson(json['signature'])
          : null,
      receivedDetails: json['receivedDetails'],
      dateReceived: json['dateReceived'] != null
          ? DateTime.parse(json['dateReceived'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'requesterId': requesterId,
      'requesterName': requesterName,
      'dateRequested': dateRequested.toIso8601String(),
      'status': status.toString().split('.').last,
      'items': items.map((item) => item.toJson()).toList(),
      'signature': signature?.toJson(),
      'receivedDetails': receivedDetails,
      'dateReceived': dateReceived?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

// TODO: Create base class or flatten model
class EquipmentItem { // extends BaseEquipmentItem
  String? title;
  String? description;
  int quantity;
  String? justification;

  EquipmentItem({
    this.title,
    this.description,
    this.quantity = 1,
    this.justification = 'New',
  });

  factory EquipmentItem.fromJson(Map<String, dynamic> json) {
    return EquipmentItem(
      title: json['title'] ?? '',
      description: json['description'],
      quantity: json['quantity'] is int ? json['quantity'] : int.tryParse(json['quantity'].toString()) ?? 1,
      justification: json['justification'] ?? 'New',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'quantity': quantity,
      'justification': justification,
    };
  }
}

