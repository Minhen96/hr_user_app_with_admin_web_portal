class ChangeRequest {
  final int id;
  final int requesterId;
  final DateTime dateRequested;
  final String status;
  final String? reason;
  final String? description;
  final String? risk;
  final String? instruction;
  final DateTime? completeDate;
  final String? postReview;
  final int signatureId;
  final int? approverId;
  final DateTime? dateApproved;
  final int? approvalSignatureId;
  final String? receivedDetails;
  final String? returnStatus;
  final int? fixedAssetTypeId;

  ChangeRequest({
    required this.id,
    required this.requesterId,
    required this.dateRequested,
    required this.status,
    this.reason,
    this.description,
    this.risk,
    this.instruction,
    this.completeDate,
    this.postReview,
    required this.signatureId,
    this.approverId,
    this.dateApproved,
    this.approvalSignatureId,
    this.receivedDetails,
    this.returnStatus,
    this.fixedAssetTypeId,
  });

  factory ChangeRequest.fromJson(Map<String, dynamic> json) {
    return ChangeRequest(
      id: json['id'],
      requesterId: json['requester_id'],
      dateRequested: DateTime.parse(json['date_requested']),
      status: json['status'],
      reason: json['reason'],
      description: json['description'],
      risk: json['risk'],
      instruction: json['instruction'],
      completeDate: json['complete_date'] != null
          ? DateTime.parse(json['complete_date'])
          : null,
      postReview: json['post_review'],
      signatureId: json['signature_id'],
      approverId: json['approver_id'],
      dateApproved: json['date_approved'] != null
          ? DateTime.parse(json['date_approved'])
          : null,
      approvalSignatureId: json['approval_signature_id'],
      receivedDetails: json['received_details'],
      returnStatus: json['return_status'],
      fixedAssetTypeId: json['fixed_asset_type_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'requester_id': requesterId,
      'date_requested': dateRequested.toIso8601String(),
      'status': status,
      'reason': reason,
      'description': description,
      'risk': risk,
      'instruction': instruction,
      'complete_date': completeDate?.toIso8601String(),
      'post_review': postReview,
      'signature_id': signatureId,
      'approver_id': approverId,
      'date_approved': dateApproved?.toIso8601String(),
      'approval_signature_id': approvalSignatureId,
      'received_details': receivedDetails,
      'return_status': returnStatus,
      'fixed_asset_type_id': fixedAssetTypeId,
    };
  }
}
