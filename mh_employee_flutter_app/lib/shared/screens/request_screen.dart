import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:mh_employee_app/core/theme/app_colors.dart';
import 'package:mh_employee_app/shared/widgets/modern_glass_card.dart';
import '../../services/api_service.dart';
import 'package:mh_employee_app/features/equipment/data/models/equipment_request_model.dart';
import '../models/signature_data.dart';
import 'package:mh_employee_app/features/auth/data/models/user_model.dart';
import 'package:mh_employee_app/features/equipment/presentation/widgets/equipment_item_form.dart';
import '../widgets/signature_pad.dart';

class RequestScreen extends StatefulWidget {
  final User userData;
  const RequestScreen({Key? key, required this.userData}) : super(key: key);

  @override
  _RequestScreenState createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen> {
  final List<EquipmentItem> equipmentList = [];
  SignatureData? signatureData;
  bool _isLoading = false;
  String? _error;
  static const double SIGNATURE_HEIGHT = 150.0;
  static const double PREVIEW_HEIGHT = 80.0;


  void _showSignaturePad(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Add Your Signature',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              SignatureFrame(
                width: MediaQuery.of(context).size.width * 0.7,
                height: SIGNATURE_HEIGHT,
                initialData: signatureData,
                onSign: (data) {
                  setState(() => signatureData = data);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }


  Future<void> _submitRequest() async {
    // Keep existing submission logic
    if (equipmentList.isEmpty) {
      setState(() => _error = 'Please add at least one item');
      return;
    }

    if (signatureData == null || signatureData!.points.isEmpty) {
      setState(() => _error = 'Please provide your signature');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // TODO: Migrate to ApiClient
      await ApiService.createEquipmentRequest(
        items: equipmentList,
        signatureData: signatureData!,
      );


      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request submitted successfully')),
      );

      setState(() {
        equipmentList.clear();
        signatureData = null;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: Stack(
        // child: Stack(
          children: [
            // Main Content
            CustomScrollView(
              slivers: [
                // Error Message
                if (_error != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.error.withOpacity(0.1), AppColors.error.withOpacity(0.05)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.error.withOpacity(0.3), width: 1),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.error.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.error_rounded, color: AppColors.error, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _error!,
                                style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.close_rounded, color: AppColors.error),
                              onPressed: () => setState(() => _error = null),
                            ),
                          ],
                        ),
                      ).animate().shake(),
                    ),
                  ),

                // User Information Card
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: ModernGlassCard(
                      padding: const EdgeInsets.all(18),
                      gradient: AppColors.gradientPurple.map((c) => c.withOpacity(0.05)).toList(),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: AppColors.gradientPurple),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.gradientPurple.first.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.person_rounded,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Requestor',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.userData.fullName,
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.calendar_today_rounded, size: 14,
                                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                                    SizedBox(width: 6),
                                    Text(
                                      DateFormat('MMM dd, yyyy').format(DateTime.now()),
                                      style: TextStyle(
                                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn().slideY(begin: -0.1, end: 0),
                  ),
                ),

                // Equipment List
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) => EquipmentItemForm<EquipmentItem>(
                        item: equipmentList[index],
                        itemNumber: index + 1,
                        onRemove: () => setState(() => equipmentList.removeAt(index)),
                      ),
                      childCount: equipmentList.length,
                    ),
                  ),
                ),

                // Add Equipment Button
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                    child: Container(
                      height: 54,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: AppColors.gradientPurple),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.gradientPurple.first.withOpacity(0.4),
                            blurRadius: 12,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () => setState(() => equipmentList.add(EquipmentItem())),
                        icon: Icon(Icons.add_circle_rounded, color: Colors.white, size: 22),
                        label: Text(
                          'Add Equipment',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ).animate().fadeIn().scale(),
                  ),
                ),

                // Signature Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                    child: ModernGlassCard(
                      padding: const EdgeInsets.all(20),
                      gradient: [Colors.purple.shade50.withOpacity(0.3), Colors.blue.shade50.withOpacity(0.3)],
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: AppColors.gradientPurple),
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.gradientPurple.first.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Icon(Icons.draw_rounded, color: Colors.white, size: 20),
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
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: () => _showSignaturePad(context),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final double width = constraints.maxWidth;
                                final double height = width / 2.5;

                                return Container(
                                  width: double.infinity,
                                  height: height,
                                  decoration: BoxDecoration(
                                    color: isDark ? AppColors.darkSurface : Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: signatureData != null
                                          ? AppColors.gradientPurple.first.withOpacity(0.5)
                                          : (isDark ? Color(0xFF475569) : Color(0xFFE2E8F0)),
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: signatureData != null
                                      ? ClipRRect(
                                    borderRadius: BorderRadius.circular(14),
                                    child: CustomPaint(
                                      painter: SignaturePainter(
                                        points: signatureData!.points,
                                        boundarySize: signatureData!.boundarySize,
                                        scale: true,
                                        targetSize: Size(width, height),
                                      ),
                                    ),
                                  )
                                      : Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.gesture_rounded,
                                          color: isDark ? Color(0xFF94A3B8) : Color(0xFF94A3B8),
                                          size: 40,
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          'Tap to add signature',
                                          style: TextStyle(
                                            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn().slideY(begin: 0.1, end: 0),
                  ),
                ),

                // Submit Button
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: _isLoading
                            ? null
                            : LinearGradient(
                                colors: [Color(0xFF10B981), Color(0xFF059669)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: _isLoading
                            ? null
                            : [
                                BoxShadow(
                                  color: Color(0xFF10B981).withOpacity(0.4),
                                  blurRadius: 12,
                                  offset: Offset(0, 6),
                                ),
                              ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitRequest,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isLoading ? (isDark ? Color(0xFF334155) : Color(0xFFE2E8F0)) : Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isLoading
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: isDark ? Colors.white70 : Color(0xFF64748B),
                                      strokeWidth: 2.5,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Submitting...',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white70 : Color(0xFF64748B),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.check_circle_rounded, color: Colors.white, size: 22),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Submit Request',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ).animate().fadeIn().scale(delay: 100.ms),
                  ),
                ),

                // Bottom Padding
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ),

            // Loading Overlay
            if (_isLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
          ],
        // ),
      ),
    );
  }
}

