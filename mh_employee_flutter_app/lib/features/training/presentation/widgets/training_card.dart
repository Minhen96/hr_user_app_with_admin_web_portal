import 'package:flutter/material.dart';
// import 'package:mh_employee_app/core/network/api_client.dart'; // TODO: Migrate to ApiClient
import 'package:mh_employee_app/services/api_service.dart';
import 'package:mh_employee_app/features/training/data/models/training_record_model.dart';
class TrainingCard extends StatelessWidget {
  final TrainingCourse training;

  const TrainingCard({
    Key? key,
    required this.training,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.withOpacity(0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        training.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          SizedBox(width: 4),
                          Text(
                            training.date.toString().split(' ')[0],
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(training.status),
              ],
            ),
            if (training.description.isNotEmpty) ...[
              SizedBox(height: 12),
              Text(
                training.description,
                style: TextStyle(
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
            ],
            if (training.certificates.isNotEmpty) ...[
              SizedBox(height: 16),
              Text(
                'Certificates',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: training.certificates.map((cert) => _buildCertificateChip(context, cert)).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCertificateChip(BuildContext context, Certificate cert) {
    return InkWell(
      onTap: () => _viewCertificate(context, cert),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(context).primaryColor.withOpacity(0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getFileIcon(cert.fileType),
              size: 16,
              color: Theme.of(context).primaryColor,
            ),
            SizedBox(width: 6),
            Text(
              cert.fileName,
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(TrainingStatus status) {
    Color color;
    String label;
    IconData icon;

    switch (status) {
      case TrainingStatus.approved:
        color = Colors.green;
        label = 'Approved';
        icon = Icons.check_circle;
        break;
      case TrainingStatus.rejected:
        color = Colors.red;
        label = 'Rejected';
        icon = Icons.cancel;
        break;
      case TrainingStatus.pending:
        color = Colors.orange;
        label = 'Pending';
        icon = Icons.access_time;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _viewCertificate(BuildContext context, Certificate cert) async {
    try {
      // TODO: Migrate to ApiClient
      final bytes = await ApiService.downloadCertificate(cert.id);
      if (!context.mounted) return;

      await showDialog(
        context: context,
        builder: (context) => Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBar(
                title: Text(cert.fileName),
                automaticallyImplyLeading: false,
                actions: [
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              if (cert.fileType.startsWith('image/'))
                Image.memory(bytes)
              else
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('PDF document available for download'),
                ),
            ],
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error viewing certificate: ${e.toString()}')),
      );
    }
  }

  IconData _getFileIcon(String extension) {
    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      case 'pdf':
        return Icons.picture_as_pdf;
      default:
        return Icons.insert_drive_file;
    }
  }

}


