import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:mh_employee_app/core/theme/app_colors.dart';
import 'package:mh_employee_app/shared/widgets/modern_glass_card.dart';
import 'package:mh_employee_app/shared/widgets/modern_buttons.dart';
import 'package:mh_employee_app/core/constants/api_constants.dart';

class McLeaveScreenNew extends StatefulWidget {
  final String username;
  final String email;
  final int userid;

  const McLeaveScreenNew({
    super.key,
    required this.username,
    required this.email,
    required this.userid,
  });

  @override
  _McLeaveScreenNewState createState() => _McLeaveScreenNewState();
}

class _McLeaveScreenNewState extends State<McLeaveScreenNew> {
  final TextEditingController _reasonController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  File? _selectedFile;
  PlatformFile? _selectedPlatformFile;
  int _totaldays = 0;
  final String _status = "Pending";
  final DateTime _submissionDate = DateTime.now();
  bool _isSubmitting = false;

  String baseurl = ApiConstants.baseUrl;

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: isDark ? AppColors.darkPrimary : AppColors.primary,
              onPrimary: Colors.white,
              surface: isDark ? AppColors.darkSurface : Colors.white,
              onSurface: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
        if (_endDate != null && _startDate != null) {
          _totaldays = _endDate!.difference(_startDate!).inDays + 1;
        } else {
          _totaldays = 0;
        }
      });
    }
  }

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      withData: kIsWeb,
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      if (kIsWeb) {
        setState(() {
          _selectedFile = null;
          _selectedPlatformFile = result.files.single;
        });
      } else {
        setState(() {
          _selectedFile = File(result.files.single.path!);
          _selectedPlatformFile = null;
        });
      }
    }
  }

  Future<void> _submitLeaveRequest() async {
    if (_startDate == null ||
        _endDate == null ||
        _reasonController.text.isEmpty ||
        (_selectedFile == null && _selectedPlatformFile == null)) {
      _showErrorDialog('Please fill all fields and attach medical certificate (PDF).');
      return;
    }

    setState(() => _isSubmitting = true);

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseurl/Mc/submit'),
    );

    request.fields['Userid'] = widget.userid.toString();
    request.fields['FullName'] = widget.username;
    request.fields['date_submission'] = DateFormat('dd/MM/yyyy hh:mm:ss tt').format(_submissionDate);
    request.fields['StartDate'] = DateFormat('yyyy-MM-dd').format(_startDate!);
    request.fields['EndDate'] = DateFormat('yyyy-MM-dd').format(_endDate!);
    request.fields['Reason'] = _reasonController.text;
    request.fields['total_day'] = _totaldays.toString();
    request.fields['status'] = _status;

    if (kIsWeb && _selectedPlatformFile != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'PdfFile',
          _selectedPlatformFile!.bytes!,
          filename: _selectedPlatformFile!.name,
        ),
      );
    } else if (_selectedFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath('PdfFile', _selectedFile!.path),
      );
    }

    try {
      final response = await request.send();

      setState(() => _isSubmitting = false);

      if (response.statusCode == 200) {
        _showSuccessDialog('Medical leave submitted successfully.');
        _clearForm();
      } else {
        _showErrorDialog('Failed to submit leave.');
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      _showErrorDialog('An error occurred: $e');
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ModernElevatedCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: AppColors.gradientGreen),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 48),
              ),
              const SizedBox(height: 20),
              const Text(
                'Success',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ModernGradientButton(
                text: 'OK',
                onPressed: () => Navigator.of(context).pop(),
                gradientColors: AppColors.gradientGreen,
                width: double.infinity,
              ),
            ],
          ),
        ).animate().scale(duration: 300.ms),
      ),
    );
  }

  void _clearForm() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _reasonController.clear();
      _selectedFile = null;
      _selectedPlatformFile = null;
      _totaldays = 0;
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ModernElevatedCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [AppColors.error, Color(0xFFDC2626)]),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.error_outline_rounded, color: Colors.white, size: 48),
              ),
              const SizedBox(height: 20),
              const Text(
                'Error',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ModernGradientButton(
                text: 'OK',
                onPressed: () => Navigator.of(context).pop(),
                gradientColors: AppColors.primaryGradient,
                width: double.infinity,
              ),
            ],
          ),
        ).animate().scale(duration: 300.ms),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Content
          SliverToBoxAdapter(
            child: _isSubmitting
                ? Padding(
                    padding: const EdgeInsets.all(100),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: isDark ? AppColors.darkPrimary : AppColors.primary,
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(20),
                    child: ModernGlassCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(colors: AppColors.gradientPink),
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                ),
                                child: const Icon(Icons.edit_calendar_rounded, color: Colors.white, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Medical Leave Request',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Start Date
                          _buildDateField(
                            label: 'Start Date',
                            date: _startDate,
                            onTap: () => _selectDate(context, true),
                            isDark: isDark,
                          ),
                          const SizedBox(height: 16),

                          // End Date
                          _buildDateField(
                            label: 'End Date',
                            date: _endDate,
                            onTap: () => _selectDate(context, false),
                            isDark: isDark,
                          ),

                          if (_totaldays > 0) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: (isDark ? AppColors.darkPrimary : AppColors.primary).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDark ? AppColors.darkPrimary : AppColors.primary,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.info_outline_rounded,
                                    color: isDark ? AppColors.darkPrimary : AppColors.primary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Total Days: $_totaldays',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 16),

                          // Reason Field
                          TextFormField(
                            controller: _reasonController,
                            maxLines: 3,
                            style: TextStyle(
                              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Reason',
                              labelStyle: TextStyle(
                                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                              ),
                              hintText: 'Enter reason for medical leave...',
                              hintStyle: TextStyle(
                                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                              ),
                              prefixIcon: Icon(
                                Icons.notes_rounded,
                                color: isDark ? AppColors.darkPrimary : AppColors.primary,
                              ),
                              filled: true,
                              fillColor: isDark ? AppColors.darkSurfaceVariant : AppColors.surface,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: isDark ? AppColors.darkBorder : AppColors.border,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: isDark ? AppColors.darkBorder : AppColors.border,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: isDark ? AppColors.darkPrimary : AppColors.primary,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // File Picker
                          ModernOutlineButton(
                            text: _selectedFile != null || _selectedPlatformFile != null
                                ? 'Certificate: ${_selectedPlatformFile?.name ?? _selectedFile?.path.split('/').last}'
                                : 'Attach Medical Certificate (PDF)',
                            icon: Icons.attach_file_rounded,
                            onPressed: pickFile,
                            borderColor: isDark ? AppColors.darkPrimary : AppColors.primary,
                            textColor: isDark ? AppColors.darkPrimary : AppColors.primary,
                          ),

                          const SizedBox(height: 24),

                          // Submit Button
                          ModernGradientButton(
                            text: 'Submit Leave Request',
                            icon: Icons.send_rounded,
                            onPressed: _submitLeaveRequest,
                            gradientColors: AppColors.gradientGreen,
                            width: double.infinity,
                          ),
                        ],
                      ),
                    ).animate(delay: 100.ms).fadeIn().slideX(begin: 0.2, end: 0),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurfaceVariant : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              color: isDark ? AppColors.darkPrimary : AppColors.primary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date != null ? DateFormat('MMM dd, yyyy').format(date) : 'Select date',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: date != null
                          ? (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)
                          : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }
}
