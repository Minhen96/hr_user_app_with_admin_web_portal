import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mh_employee_app/core/theme/app_colors.dart';
import 'package:mh_employee_app/core/widgets/loading/modern_loading.dart';
import 'package:mh_employee_app/shared/widgets/modern_glass_card.dart';
// import 'package:mh_employee_app/core/network/api_client.dart'; // TODO: Migrate to ApiClient
import 'package:mh_employee_app/services/api_service.dart';
import 'package:mh_employee_app/features/equipment/data/models/equipment_request_model.dart';
import 'package:mh_employee_app/features/auth/data/models/user_model.dart';

class HistoryScreen extends StatefulWidget {
  final User userData;
  const HistoryScreen({Key? key, required this.userData}) : super(key: key);

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<EquipmentRequest> _requests = [];
  bool _isLoading = false;
  String? _error;
  String _selectedStatus = 'all';

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() => _isLoading = true);
    try {
      final status = _selectedStatus == 'all' ? null : _selectedStatus;
      // TODO: Migrate to ApiClient
      final requests = await ApiService.getEquipmentRequests(status: status);

      // Sort requests by dateRequested (latest first)
      requests.sort((a, b) => b.dateRequested.compareTo(a.dateRequested));

      setState(() => _requests = requests);
    } catch (e) {
      setState(() => _error = 'Failed to load requests: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Color _getStatusColor(RequestStatus status) {
    switch (status) {
      case RequestStatus.pending:
        return const Color(0xFFF59E0B);
      case RequestStatus.approved:
        return const Color(0xFF10B981);
      case RequestStatus.rejected:
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6B7280);
    }
  }

  List<Color> _getStatusGradient(RequestStatus status) {
    switch (status) {
      case RequestStatus.pending:
        return [const Color(0xFFF59E0B), const Color(0xFFD97706)];
      case RequestStatus.approved:
        return [const Color(0xFF10B981), const Color(0xFF059669)];
      case RequestStatus.rejected:
        return [const Color(0xFFEF4444), const Color(0xFFDC2626)];
      default:
        return [const Color(0xFF6B7280), const Color(0xFF4B5563)];
    }
  }

  IconData _getStatusIcon(RequestStatus status) {
    switch (status) {
      case RequestStatus.pending:
        return Icons.pending_actions_rounded;
      case RequestStatus.approved:
        return Icons.check_circle_rounded;
      case RequestStatus.rejected:
        return Icons.cancel_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  void _showRequestDetails(BuildContext context, EquipmentRequest request) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final status = request.status ?? RequestStatus.pending;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.8,
        minChildSize: 0.5,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: ListView(
            controller: controller,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Drag handle
                    Center(
                      child: Container(
                        width: 60,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isDark ? Color(0xFF475569) : Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Header with request ID and status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Request #${request.id}',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today_rounded,
                                  size: 16,
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  request.dateRequested.toString().split(' ')[0],
                                  style: TextStyle(
                                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: _getStatusGradient(status)),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: _getStatusColor(status).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          child: Row(
                            children: [
                              Icon(_getStatusIcon(status), color: Colors.white, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                status.toString().split('.').last.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Detailed Information Sections
                    _buildInfoSection(
                      isDark: isDark,
                      title: 'Requester Details',
                      children: [
                        _buildDetailRow('Requested By', request.requestedBy, isDark),
                        _buildDetailRow('Requested Date', request.dateRequested.toString().split(' ')[0], isDark),
                      ],
                    ),

                    const SizedBox(height: 16),

                    _buildInfoSection(
                      isDark: isDark,
                      title: 'Requested Items',
                      children: request.items.map((item) =>
                          Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: isDark ? Color(0xFF1E293B) : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isDark ? Color(0xFF334155) : Color(0xFFE2E8F0),
                                width: 1,
                              ),
                            ),
                            child: Theme(
                              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                              child: ExpansionTile(
                                tilePadding: const EdgeInsets.all(14),
                                childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                                leading: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(colors: _getStatusGradient(status)),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.inventory_2_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                title: Text(
                                  item.title!,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    'Quantity: ${item.quantity}',
                                    style: TextStyle(
                                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Color(0xFF0F172A).withOpacity(0.5)
                                          : Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Description',
                                          style: TextStyle(
                                            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          item.description!,
                                          style: TextStyle(
                                            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          'Justification',
                                          style: TextStyle(
                                            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          item.justification!,
                                          style: TextStyle(
                                            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          'Received Details',
                                          style: TextStyle(
                                            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          request.receivedDetails ?? 'N/A',
                                          style: TextStyle(
                                            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                      ).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection({
    required bool isDark,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Color(0xFF334155) : Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: Column(
        children: [
          // Modern Filter Section
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: ModernGlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              gradient: AppColors.gradientPurple.map((c) => c.withOpacity(0.05)).toList(),
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.filter_list_rounded,
                    color: AppColors.gradientPurple.first,
                  ),
                  hintText: 'Filter Requests',
                  hintStyle: TextStyle(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.transparent,
                ),
                value: _selectedStatus,
                isExpanded: true,
                dropdownColor: isDark ? AppColors.darkSurface : Colors.white,
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.gradientPurple.first,
                ),
                style: TextStyle(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
                items: [
                  DropdownMenuItem(
                    value: 'all',
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: AppColors.gradientPurple),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.all_inclusive_rounded, color: Colors.white, size: 16),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'All Requests',
                          style: TextStyle(
                            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'pending',
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFD97706)]),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.pending_actions_rounded, color: Colors.white, size: 16),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Pending',
                          style: TextStyle(
                            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'approved',
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 16),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Approved',
                          style: TextStyle(
                            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'rejected',
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFFEF4444), Color(0xFFDC2626)]),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.cancel_rounded, color: Colors.white, size: 16),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Rejected',
                          style: TextStyle(
                            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() => _selectedStatus = newValue);
                    _loadRequests();
                  }
                },
              ),
            ).animate().fadeIn().slideY(begin: -0.1, end: 0),
          ),

          // Request List Section
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadRequests,
              color: AppColors.gradientPurple.first,
              child: _isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ModernLoading(size: 48),
                          const SizedBox(height: 16),
                          Text(
                            'Loading request history...',
                            style: TextStyle(
                              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : _error != null
                      ? ListView(
                          children: [
                            const SizedBox(height: 100),
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline_rounded,
                                    size: 80,
                                    color: AppColors.error,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Oops! Something went wrong',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 40),
                                    child: Text(
                                      _error!,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  ElevatedButton.icon(
                                    onPressed: _loadRequests,
                                    icon: const Icon(Icons.refresh_rounded),
                                    label: const Text('Retry'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : _requests.isEmpty
                          ? ListView(
                              children: [
                                const SizedBox(height: 100),
                                Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.inbox_rounded,
                                        size: 80,
                                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No Requests Found',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Request history will appear here',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.only(top: 8, bottom: 20),
                              itemCount: _requests.length,
                              itemBuilder: (context, index) {
                                final request = _requests[index];
                                final status = request.status ?? RequestStatus.pending;
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                  child: ModernGlassCard(
                                    padding: EdgeInsets.zero,
                                    gradient: _getStatusGradient(status).map((c) => c.withOpacity(0.05)).toList(),
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      leading: Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(colors: _getStatusGradient(status)),
                                          borderRadius: BorderRadius.circular(10),
                                          boxShadow: [
                                            BoxShadow(
                                              color: _getStatusColor(status).withOpacity(0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Icon(_getStatusIcon(status), color: Colors.white, size: 22),
                                      ),
                                      title: Row(
                                        children: [
                                          Text(
                                            'Request #${request.id}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(colors: _getStatusGradient(status)),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              status.toString().split('.').last.toUpperCase(),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      subtitle: Padding(
                                        padding: const EdgeInsets.only(top: 6),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.calendar_today_rounded,
                                              size: 14,
                                              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              request.dateRequested.toString().split(' ')[0],
                                              style: TextStyle(
                                                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      trailing: Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        size: 16,
                                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                      ),
                                      onTap: () => _showRequestDetails(context, request),
                                    ),
                                  ).animate(delay: (index * 50).ms).fadeIn().slideY(begin: 0.1, end: 0),
                                );
                              },
                            ),
            ),
          ),
        ],
      ),
    );
  }

}


