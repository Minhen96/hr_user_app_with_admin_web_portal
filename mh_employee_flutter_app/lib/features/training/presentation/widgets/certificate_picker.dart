import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

// Wrapper class to handle both File and web bytes
class FileWrapper {
  final File? file;
  final PlatformFile? platformFile;
  final String name;

  FileWrapper({this.file, this.platformFile, required this.name});

  bool get isWeb => kIsWeb;

  int get size {
    if (file != null) return file!.lengthSync();
    if (platformFile != null) return platformFile!.size;
    return 0;
  }
}

class CertificatePicker extends StatelessWidget {
  final List<FileWrapper> selectedFiles;
  final Function(List<FileWrapper>) onFilesSelected;

  const CertificatePicker({
    Key? key,
    required this.selectedFiles,
    required this.onFilesSelected,
  }) : super(key: key);

  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'jpg', 'jpeg', 'png', 'gif', 'bmp',
          'pdf', 'doc', 'docx',
        ],
        allowMultiple: true,
        withData: kIsWeb, // Load bytes on web
      );

      if (result != null) {
        final files = result.files.map((platformFile) {
          if (kIsWeb) {
            // On web, use bytes instead of path
            return FileWrapper(
              platformFile: platformFile,
              name: platformFile.name,
            );
          } else {
            // On mobile/desktop, use file path
            if (platformFile.path != null) {
              return FileWrapper(
                file: File(platformFile.path!),
                name: platformFile.name,
              );
            }
            return null;
          }
        }).whereType<FileWrapper>().toList();

        final newFiles = List<FileWrapper>.from(selectedFiles);
        newFiles.addAll(files);
        onFilesSelected(newFiles);
      }
    } catch (e) {
      print('Error picking files: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: _pickFiles,
          icon: Icon(Icons.upload_file),
          label: Text('Upload Certificates'),
          style: ElevatedButton.styleFrom(
            minimumSize: Size.fromHeight(40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        ),
        if (selectedFiles.isNotEmpty) ...[
          SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: selectedFiles.length,
            itemBuilder: (context, index) {
              final fileWrapper = selectedFiles[index];
              final fileName = fileWrapper.name;
              final extension = fileName.split('.').last.toLowerCase();
              final fileSize = fileWrapper.size;

              return ListTile(
                leading: _getFileIcon(extension),
                title: Text(fileName),
                subtitle: Text(_formatFileSize(fileSize)),
                trailing: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    final newFiles = List<FileWrapper>.from(selectedFiles);
                    newFiles.removeAt(index);
                    onFilesSelected(newFiles);
                  },
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _getFileIcon(String extension) {
    IconData iconData;
    Color color;

    if (['jpg', 'jpeg', 'png', 'gif', 'bmp'].contains(extension)) {
      iconData = Icons.image;
      color = Colors.blue;
    } else if (extension == 'pdf') {
      iconData = Icons.picture_as_pdf;
      color = Colors.red;
    } else if (['doc', 'docx'].contains(extension)) {
      iconData = Icons.description;
      color = Colors.blue;
    } else {
      iconData = Icons.insert_drive_file;
      color = Colors.grey;
    }

    return Icon(iconData, color: color);
  }

  String _formatFileSize(int size) {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
