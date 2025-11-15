import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
// import 'package:mh_employee_app/core/network/api_client.dart'; // TODO: Migrate to ApiClient
import 'package:mh_employee_app/services/api_service.dart';

// Wrapper class to handle both File and web bytes
class _FileWrapper {
  final File? file;
  final PlatformFile? platformFile;
  final String name;

  _FileWrapper({this.file, this.platformFile, required this.name});

  Future<Uint8List> readAsBytes() async {
    if (file != null) {
      return await file!.readAsBytes();
    } else if (platformFile != null && platformFile!.bytes != null) {
      return platformFile!.bytes!;
    }
    throw Exception('No file data available');
  }
}

class AddTrainingScreen extends StatefulWidget {
  @override
  _AddTrainingScreenState createState() => _AddTrainingScreenState();
}

class _AddTrainingScreenState extends State<AddTrainingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  List<_FileWrapper> _selectedFiles = [];
  bool _isSubmitting = false;


  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: Colors.deepPurple,
              onPrimary: Colors.white,
              surface: Colors.deepPurple.shade800,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: Colors.black87,
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white, // This makes the button text white
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
        allowMultiple: true,
        withData: kIsWeb, // Load bytes on web
      );

      if (result != null) {
        setState(() {
          _selectedFiles.addAll(
            result.files.map((platformFile) {
              if (kIsWeb) {
                // On web, use bytes instead of path
                return _FileWrapper(
                  platformFile: platformFile,
                  name: platformFile.name,
                );
              } else {
                // On mobile/desktop, use file path
                if (platformFile.path != null) {
                  return _FileWrapper(
                    file: File(platformFile.path!),
                    name: platformFile.name,
                  );
                }
                return null;
              }
            }).whereType<_FileWrapper>(),
          );
        });
      }
    } catch (e) {
      _showErrorSnackbar('Error picking files: ${e.toString()}');
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }


  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      _showErrorSnackbar('Please select a course date');
      return;
    }
    if (_selectedFiles.isEmpty) {
      _showErrorSnackbar('Please upload at least one certificate');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final certificates = <Uint8List>[];
      final fileNames = <String>[];

      for (var fileWrapper in _selectedFiles) {
        final fileBytes = await fileWrapper.readAsBytes();
        certificates.add(fileBytes);
        fileNames.add(fileWrapper.name);
      }

      // TODO: Migrate to ApiClient - 

      // TODO: Migrate to ApiClient
      await ApiService.createTrainingCourse(
        title: _titleController.text,
        description: _descriptionController.text,
        date: _selectedDate!,
        certificates: certificates,
        fileNames: fileNames,
      );

      Navigator.pop(context, true);
    } catch (e) {
      _showErrorSnackbar('Error: ${e.toString()}');
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Color(0xFF0F172A) : Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // Modern Gradient Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [Color(0xFF667EEA), Color(0xFF764BA2)]
                    : [Color(0xFF667EEA), Color(0xFF764BA2)],
                stops: [0.3, 1.0],
              ),
            ),
          ),

          // Content
          SafeArea(
            child: CustomScrollView(
              slivers: [
                // Modern App Bar
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  expandedHeight: 120,
                  floating: false,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      'Add Training Course',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    centerTitle: true,
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? [Color(0xFF667EEA), Color(0xFF764BA2)]
                              : [Color(0xFF667EEA), Color(0xFF764BA2)],
                        ),
                      ),
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 60, right: 20),
                          child: Align(
                            alignment: Alignment.topRight,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.school_rounded,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                // Form Content
                SliverPadding(
                  padding: EdgeInsets.all(20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _buildModernTextField(
                              controller: _titleController,
                              labelText: 'Course Title',
                              icon: Icons.title_rounded,
                              isDark: isDark,
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return 'Please enter course title';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 20),
                            _buildModernTextField(
                              controller: _descriptionController,
                              labelText: 'Description',
                              icon: Icons.description_rounded,
                              isDark: isDark,
                              maxLines: 4,
                            ),
                            SizedBox(height: 20),
                            _buildModernDatePicker(isDark),
                            SizedBox(height: 20),
                            _buildModernFileUploadSection(isDark),
                            SizedBox(height: 40),
                            _buildModernSubmitButton(isDark),
                            SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    required bool isDark,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDark ? Color(0xFF1E293B) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        style: TextStyle(
          color: isDark ? Color(0xFFF1F5F9) : Color(0xFF0F172A),
          fontSize: 15,
        ),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(
            color: isDark ? Color(0xFF94A3B8) : Color(0xFF64748B),
          ),
          prefixIcon: Icon(
            icon,
            color: Color(0xFF667EEA),
            size: 22,
          ),
          filled: true,
          fillColor: isDark ? Color(0xFF1E293B) : Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: isDark ? Color(0xFF334155) : Color(0xFFE2E8F0),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Color(0xFF667EEA),
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Color(0xFFEF4444),
              width: 1,
            ),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildModernDatePicker(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDark ? Color(0xFF1E293B) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _selectDate(context),
          child: Container(
            padding: EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.calendar_today_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    _selectedDate != null
                        ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                        : 'Select Course Date',
                    style: TextStyle(
                      color: _selectedDate == null
                          ? (isDark ? Color(0xFF94A3B8) : Color(0xFF64748B))
                          : (isDark ? Color(0xFFF1F5F9) : Color(0xFF0F172A)),
                      fontSize: 15,
                      fontWeight: _selectedDate != null ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: isDark ? Color(0xFF64748B) : Color(0xFF94A3B8),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernFileUploadSection(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDark ? Color(0xFF1E293B) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomLeft: _selectedFiles.isEmpty ? Radius.circular(16) : Radius.zero,
              bottomRight: _selectedFiles.isEmpty ? Radius.circular(16) : Radius.zero,
            ),
            onTap: _pickFiles,
            child: Container(
              padding: EdgeInsets.all(18),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.upload_file_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Upload Certificates',
                      style: TextStyle(
                        color: isDark ? Color(0xFFF1F5F9) : Color(0xFF0F172A),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.add_circle_outline_rounded,
                    color: Color(0xFF667EEA),
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
          if (_selectedFiles.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: isDark ? Color(0xFF334155) : Color(0xFFE2E8F0),
                    width: 1,
                  ),
                ),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _selectedFiles.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  color: isDark ? Color(0xFF334155) : Color(0xFFE2E8F0),
                ),
                itemBuilder: (context, index) {
                  final fileWrapper = _selectedFiles[index];
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    child: Row(
                      children: [
                        Icon(
                          Icons.insert_drive_file_rounded,
                          color: Color(0xFF667EEA),
                          size: 20,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            fileWrapper.name,
                            style: TextStyle(
                              color: isDark ? Color(0xFFF1F5F9) : Color(0xFF0F172A),
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444)),
                          onPressed: () {
                            setState(() {
                              _selectedFiles.removeAt(index);
                            });
                          },
                          iconSize: 20,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildModernSubmitButton(bool isDark) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF667EEA).withOpacity(0.4),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isSubmitting
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_rounded, color: Colors.white, size: 22),
                  SizedBox(width: 12),
                  Text(
                    'Submit Course',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}



