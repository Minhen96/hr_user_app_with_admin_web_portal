import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:mh_employee_app/core/theme/app_colors.dart';
import 'package:mh_employee_app/shared/widgets/modern_glass_card.dart';
import 'package:mh_employee_app/shared/widgets/modern_buttons.dart';
import 'package:mh_employee_app/services/api_service.dart';
import 'package:mh_employee_app/features/auth/data/models/user_model.dart';
import 'create_change_request_screen_new.dart';

class ChangeRequestScreenNew extends StatefulWidget {
  final User userData;
  const ChangeRequestScreenNew({Key? key, required this.userData}) : super(key: key);

  @override
  _ChangeRequestScreenNewState createState() => _ChangeRequestScreenNewState();
}

class _ChangeRequestScreenNewState extends State<ChangeRequestScreenNew> {
  List<dynamic> _changeRequests = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchChangeRequests();
  }

  Future<void> _fetchChangeRequests() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final requests = await ApiService.getAllUserChangeRequests(int.parse(widget.userData.id));

      setState(() {
        _changeRequests = requests;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Color> _getStatusGradient(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return AppColors.gradientGreen;
      case 'pending':
        return AppColors.gradientOrange;
      case 'rejected':
        return [AppColors.error, const Color(0xFFDC2626)];
      default:
        return AppColors.primaryGradient;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Icons.check_circle_rounded;
      case 'pending':
        return Icons.pending_rounded;
      case 'rejected':
        return Icons.cancel_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  Future<void> _showChangeRequestDetails(dynamic changeRequest) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    try {
      final details = await ApiService.getChangeRequestDetails(changeRequest['id']);

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, controller) => ModernElevatedCard(
            padding: EdgeInsets.zero,
            child: CustomScrollView(
              controller: controller,
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      _buildModalHeader(context, changeRequest, isDark),
                      _buildModalBody(context, changeRequest, details, isDark),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching details: $e'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Widget _buildModalHeader(BuildContext context, dynamic changeRequest, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.gradientTeal,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          Container(
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.article_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Change Request',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '#${changeRequest['id']}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(changeRequest['status']),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: _getStatusGradient(status)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildModalBody(BuildContext context, dynamic changeRequest, dynamic details, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          _buildInfoSection(
            context,
            'Request Details',
            Icons.info_outline_rounded,
            isDark,
            [
              _buildDetailRow('Reason', changeRequest['reason'], isDark),
              _buildDetailRow('Description', changeRequest['description'], isDark),
              _buildDetailRow('Risk', changeRequest['risk'] ?? 'N/A', isDark),
              _buildDetailRow('Instruction', changeRequest['instruction'] ?? 'N/A', isDark),
              _buildDetailRow(
                'Completion Date',
                DateFormat('MMM dd, yyyy').format(DateTime.parse(changeRequest['completeDate'])),
                isDark,
              ),
              _buildDetailRow('Post Review', changeRequest['postReview'] ?? 'N/A', isDark),
              _buildDetailRow(
                'Date Requested',
                DateFormat('MMM dd, yyyy').format(DateTime.parse(changeRequest['dateRequested'])),
                isDark,
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoSection(
            context,
            'Status Information',
            Icons.track_changes_rounded,
            isDark,
            [
              _buildDetailRow('Return Status', changeRequest['returnStatus'], isDark),
              if (changeRequest['dateReturned'] != null)
                _buildDetailRow(
                  'Return Date',
                  DateFormat('MMM dd, yyyy').format(DateTime.parse(changeRequest['dateReturned'])),
                  isDark,
                ),
            ],
          ),
          if (changeRequest['status'] == 'approved' && details['fixedAssetProducts'] != null) ...[
            const SizedBox(height: 20),
            _buildInfoSection(
              context,
              'Product Information',
              Icons.inventory_2_rounded,
              isDark,
              [
                _buildDetailRow(
                  'Product Code',
                  details['fixedAssetProducts'][0]['productCode'] ?? 'N/A',
                  isDark,
                ),
              ],
            ),
          ],
          if (changeRequest['status'] == 'approved' && changeRequest['returnStatus'] == 'in_use') ...[
            const SizedBox(height: 30),
            ModernGradientButton(
              text: 'Request Return',
              icon: Icons.reply_rounded,
              onPressed: () => _requestReturn(changeRequest['id']),
              gradientColors: AppColors.gradientTeal,
              width: double.infinity,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, String title, IconData icon, bool isDark, List<Widget> children) {
    return ModernGlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: AppColors.gradientTeal),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Text(
              value ?? 'N/A',
              style: TextStyle(
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _requestReturn(int changeRequestId) async {
    try {
      // await ApiService.requestChangeRequestReturn(changeRequestId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Return request submitted')),
      );

      _fetchChangeRequests();
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error requesting return: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: RefreshIndicator(
        color: isDark ? AppColors.darkPrimary : AppColors.primary,
        onRefresh: _fetchChangeRequests,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Modern Gradient App Bar
            SliverAppBar(
              expandedHeight: 150,
              floating: false,
              pinned: true,
              automaticallyImplyLeading: false,
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: AppColors.gradientTeal,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: FlexibleSpaceBar(
                  title: const Text(
                    'Change Requests',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  centerTitle: false,
                  titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
                  background: SafeArea(
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
                          child: const Icon(
                            Icons.swap_horiz_rounded,
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
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),

            // Content
            if (_isLoading)
              SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(
                    color: isDark ? AppColors.darkPrimary : AppColors.primary,
                  ),
                ),
              )
            else if (_error != null)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.error, const Color(0xFFDC2626)],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.error_outline_rounded,
                          color: Colors.white,
                          size: 48,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Oops! Something went wrong',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          _error!,
                          style: TextStyle(
                            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else if (_changeRequests.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(colors: AppColors.gradientTeal),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.inbox_rounded,
                          color: Colors.white,
                          size: 48,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'No Change Requests',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Create a new request to get started',
                        style: TextStyle(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final request = _changeRequests[index];
                      return ModernElevatedCard(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        onTap: () => _showChangeRequestDetails(request),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: _getStatusGradient(request['status'])
                                  .map((c) => c.withOpacity(0.05))
                                  .toList(),
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: _getStatusGradient(request['status']),
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _getStatusIcon(request['status']),
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Request #${request['id']}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Status: ${request['status']} | Return: ${request['returnStatus']}',
                                      style: TextStyle(
                                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                size: 28,
                              ),
                            ],
                          ),
                        ),
                      ).animate(delay: (100 * index).ms).fadeIn().slideX(begin: 0.2, end: 0);
                    },
                    childCount: _changeRequests.length,
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: ModernFAB(
        icon: Icons.add_rounded,
        onPressed: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => CreateChangeRequestScreenNew(userData: widget.userData),
            ),
          );
          if (result == true) {
            _fetchChangeRequests();
          }
        },
        gradientColors: AppColors.gradientTeal,
        label: 'New Request',
      ),
    );
  }
}
