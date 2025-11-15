import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mh_employee_app/core/theme/app_colors.dart';
import 'package:mh_employee_app/core/widgets/loading/modern_loading.dart';
import 'package:mh_employee_app/features/documents/data/models/document_model.dart';
import 'package:mh_employee_app/features/documents/presentation/widgets/cards/document_card.dart';
import 'package:mh_employee_app/features/documents/presentation/screens/document_detail_screen.dart';
import 'package:mh_employee_app/services/api_service.dart';

class CompanyUpdatesScreen extends StatefulWidget {
  const CompanyUpdatesScreen({Key? key}) : super(key: key);

  @override
  State<CompanyUpdatesScreen> createState() => _CompanyUpdatesScreenState();
}

class _CompanyUpdatesScreenState extends State<CompanyUpdatesScreen> {
  List<Document> _updates = [];
  bool _isLoading = true;
  String? _error;
  int _currentPage = 1;
  bool _hasMorePages = true;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _loadUpdates();
  }

  Future<void> _loadUpdates() async {
    if (_isLoadingMore || !_hasMorePages) return;

    setState(() {
      if (_currentPage == 1) {
        _isLoading = true;
      } else {
        _isLoadingMore = true;
      }
      _error = null;
    });

    try {
      final response = await ApiService.getDocuments(
        type: 'UPDATES',
        page: _currentPage,
      );

      setState(() {
        if (_currentPage == 1) {
          _updates = response.items;
        } else {
          _updates.addAll(response.items);
        }
        _hasMorePages = response.currentPage < response.totalPages;
        _currentPage++;
        _isLoading = false;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _markAsRead(int documentId) async {
    try {
      await ApiService.markDocumentAsRead(documentId);
      setState(() {
        final index = _updates.indexWhere((doc) => doc.id == documentId);
        if (index != -1) {
          _updates[index] = Document(
            id: _updates[index].id,
            title: _updates[index].title,
            content: _updates[index].content,
            documentUpload: _updates[index].documentUpload,
            fileType: _updates[index].fileType,
            postDate: _updates[index].postDate,
            departmentName: _updates[index].departmentName,
            posterName: _updates[index].posterName,
            type: _updates[index].type,
            isRead: true,
            uid: _updates[index].uid,
            nickname: _updates[index].nickname,
          );
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to mark as read: $e')),
      );
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _currentPage = 1;
      _hasMorePages = true;
      _updates.clear();
    });
    await _loadUpdates();
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
            expandedHeight: 160,
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.update_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                'Company Updates',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Content
          if (_isLoading)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ModernLoading(size: 48),
                    SizedBox(height: 16),
                    Text(
                      'Loading updates...',
                      style: TextStyle(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (_error != null)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 80,
                      color: AppColors.error,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Oops! Something went wrong',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 8),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _refresh,
                      icon: Icon(Icons.refresh_rounded),
                      label: Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (_updates.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inbox_rounded,
                      size: 80,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No Updates Available',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Check back later for new updates',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: EdgeInsets.only(top: 8, bottom: 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index < _updates.length) {
                      final update = _updates[index];
                      return DocumentCard(
                        title: update.title,
                        content: update.content ?? 'No description available',
                        author: update.posterName,
                        datePosted: update.postDate,
                        type: 'UPDATES',
                        isRead: update.isRead,
                        onTap: () {
                          if (!update.isRead) {
                            _markAsRead(update.id);
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DocumentDetailScreen(
                                document: update,
                                onDownload: update.documentUpload != null
                                    ? () {
                                        Navigator.pop(context);
                                        // TODO: Implement download
                                      }
                                    : null,
                                onPreview: update.documentUpload != null
                                    ? () {
                                        Navigator.pop(context);
                                        // TODO: Implement preview
                                      }
                                    : null,
                              ),
                            ),
                          );
                        },
                        onDownload: update.documentUpload != null
                            ? () {
                                // TODO: Implement download
                              }
                            : null,
                      ).animate(delay: (index * 50).ms).fadeIn().slideY(begin: 0.1, end: 0);
                    } else {
                      // Loading more indicator
                      return Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: ModernLoading(size: 32)),
                      );
                    }
                  },
                  childCount: _updates.length + (_hasMorePages && _isLoadingMore ? 1 : 0),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
