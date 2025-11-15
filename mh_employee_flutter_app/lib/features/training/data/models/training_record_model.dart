class TrainingCourse {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final TrainingStatus status;
  final DateTime createdAt;
  final List<Certificate> certificates;

  TrainingCourse({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.status,
    required this.createdAt,
    required this.certificates,
  });

  factory TrainingCourse.fromJson(Map<String, dynamic> json) {
    return TrainingCourse(
      id: json['id'].toString(),
      title: json['title'],
      description: json['description'] ?? '',
      date: DateTime.parse(json['courseDate']),
      status: _parseStatus(json['status']),
      createdAt: DateTime.parse(json['createdAt']),
      certificates: (json['certificates'] as List?)
          ?.map((cert) => Certificate.fromJson(cert))
          .toList() ?? [],
    );
  }
}

class Certificate {
  final int id;
  final String fileName;
  final String fileType;
  final int fileSize;
  final DateTime uploadedAt;

  Certificate({
    required this.id,
    required this.fileName,
    required this.fileType,
    required this.fileSize,
    required this.uploadedAt,
  });

  String get fileExtension => fileName.split('.').last.toLowerCase();

  factory Certificate.fromJson(Map<String, dynamic> json) {
    return Certificate(
      id: json['id'],
      fileName: json['fileName'],
      fileType: json['fileType'],
      fileSize: json['fileSize'],
      uploadedAt: DateTime.parse(json['uploadedAt']),
    );
  }
}

enum TrainingStatus {
  pending,
  approved,
  rejected
}

TrainingStatus _parseStatus(String status) {
  switch (status.toLowerCase()) {
    case 'approved':
      return TrainingStatus.approved;
    case 'rejected':
      return TrainingStatus.rejected;
    default:
      return TrainingStatus.pending;
  }
}
