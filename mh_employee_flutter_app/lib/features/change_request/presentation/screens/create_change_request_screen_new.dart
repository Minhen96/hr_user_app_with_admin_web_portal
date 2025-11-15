import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:mh_employee_app/core/theme/app_colors.dart';
import 'package:mh_employee_app/shared/widgets/modern_glass_card.dart';
import 'package:mh_employee_app/shared/widgets/modern_buttons.dart';
import 'package:mh_employee_app/services/api_service.dart';
import 'package:mh_employee_app/features/auth/data/models/user_model.dart';
import 'package:mh_employee_app/shared/models/signature_data.dart';
import 'package:mh_employee_app/shared/widgets/signature_pad.dart';

class CreateChangeRequestScreenNew extends StatefulWidget {
  final User userData;

  const CreateChangeRequestScreenNew({Key? key, required this.userData}) : super(key: key);

  @override
  _CreateChangeRequestScreenNewState createState() => _CreateChangeRequestScreenNewState();
}

class _CreateChangeRequestScreenNewState extends State<CreateChangeRequestScreenNew> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _riskController = TextEditingController();
  final TextEditingController _instructionController = TextEditingController();
  final TextEditingController _postReviewController = TextEditingController();
  final TextEditingController _completeDateController = TextEditingController();

  SignatureData? _signatureData;
  bool _isLoading = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
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
        _completeDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _showSignaturePad(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ModernElevatedCard(
          padding: EdgeInsets.zero,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Gradient Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: AppColors.gradientTeal,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.edit_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'Add Your Signature',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Signature Pad
              Padding(
                padding: const EdgeInsets.all(24),
                child: SignatureFrame(
                  width: MediaQuery.of(context).size.width * 0.7,
                  height: 150,
                  initialData: _signatureData,
                  onSign: (data) {
                    setState(() => _signatureData = data);
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ).animate().scale(duration: 300.ms),
      ),
    );
  }

  Future<void> _submitChangeRequest() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_signatureData == null || _signatureData!.points.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please provide your signature'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final signatureId = await ApiService.createSignature(_signatureData!);

      await ApiService.createChangeRequest(
        requesterId: int.parse(widget.userData.id),
        reason: _reasonController.text,
        description: _descriptionController.text,
        risk: _riskController.text,
        instruction: _instructionController.text,
        postReview: _postReviewController.text,
        signatureId: signatureId,
        completeDate: _completeDateController.text.isNotEmpty
            ? DateTime.parse(_completeDateController.text)
            : null,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Change Request Submitted Successfully')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting change request: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildDateField(BuildContext context, bool isDark) {
    return TextFormField(
      controller: _completeDateController,
      readOnly: true,
      style: TextStyle(
        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        labelText: 'Completion Date',
        labelStyle: TextStyle(
          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
        ),
        prefixIcon: Icon(
          Icons.calendar_today_rounded,
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
      onTap: () => _selectDate(context),
    );
  }

  Widget _buildSignatureDisplay(BuildContext context, bool isDark) {
    return ModernGlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: AppColors.gradientTeal),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.draw_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Signature',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              if (_signatureData != null)
                ModernIconButton(
                  icon: Icons.delete_rounded,
                  onPressed: () {
                    setState(() {
                      _signatureData = null;
                    });
                  },
                  backgroundColor: AppColors.error.withOpacity(0.1),
                  iconColor: AppColors.error,
                  size: 36,
                ),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => _showSignaturePad(context),
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _signatureData != null
                      ? (isDark ? AppColors.darkPrimary : AppColors.primary)
                      : (isDark ? AppColors.darkBorder : AppColors.border),
                  width: _signatureData != null ? 2 : 1,
                ),
              ),
              child: _signatureData != null
                  ? CustomPaint(
                      painter: SignaturePainter(
                        points: _signatureData!.points,
                        boundarySize: _signatureData!.boundarySize,
                        scale: true,
                        targetSize: Size(
                          MediaQuery.of(context).size.width - 120,
                          120,
                        ),
                      ),
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.edit_rounded,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap to Add Signature',
                            style: TextStyle(
                              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    ).animate(delay: 500.ms).fadeIn().scale();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Modern Gradient App Bar
          SliverAppBar(
            expandedHeight: 150,
            floating: false,
            pinned: true,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: AppColors.gradientTeal,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const FlexibleSpaceBar(
                title: Text(
                  'Create Change Request',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                centerTitle: false,
                titlePadding: EdgeInsets.only(left: 56, bottom: 16),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: _isLoading
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
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Form Fields Card
                          ModernGlassCard(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                _buildCustomTextField(
                                  controller: _reasonController,
                                  label: 'Reason',
                                  icon: Icons.text_fields_rounded,
                                  isDark: isDark,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a reason';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                _buildCustomTextField(
                                  controller: _descriptionController,
                                  label: 'Description',
                                  icon: Icons.description_rounded,
                                  maxLines: 3,
                                  isDark: isDark,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a description';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                _buildCustomTextField(
                                  controller: _riskController,
                                  label: 'Risk',
                                  icon: Icons.warning_rounded,
                                  isDark: isDark,
                                ),
                                const SizedBox(height: 16),
                                _buildCustomTextField(
                                  controller: _instructionController,
                                  label: 'Instruction',
                                  icon: Icons.list_rounded,
                                  isDark: isDark,
                                ),
                                const SizedBox(height: 16),
                                _buildCustomTextField(
                                  controller: _postReviewController,
                                  label: 'Post Implementation Review',
                                  icon: Icons.rate_review_rounded,
                                  isDark: isDark,
                                ),
                                const SizedBox(height: 16),
                                _buildDateField(context, isDark),
                              ],
                            ),
                          ).animate(delay: 100.ms).fadeIn().slideX(begin: 0.2, end: 0),

                          const SizedBox(height: 20),

                          // Signature Section
                          _buildSignatureDisplay(context, isDark),

                          const SizedBox(height: 30),

                          // Submit Button
                          ModernGradientButton(
                            text: 'Submit Change Request',
                            icon: Icons.check_rounded,
                            onPressed: _submitChangeRequest,
                            gradientColors: AppColors.gradientGreen,
                            height: 56,
                          ).animate(delay: 600.ms).fadeIn().slideY(begin: 0.2, end: 0),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(
        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
        ),
        prefixIcon: Icon(
          icon,
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
      ),
      validator: validator,
    );
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _descriptionController.dispose();
    _riskController.dispose();
    _instructionController.dispose();
    _postReviewController.dispose();
    _completeDateController.dispose();
    super.dispose();
  }
}
