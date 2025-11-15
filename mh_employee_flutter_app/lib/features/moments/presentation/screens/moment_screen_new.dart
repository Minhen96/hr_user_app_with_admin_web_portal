import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mh_employee_app/core/theme/app_colors.dart';
import 'package:mh_employee_app/services/api_service.dart';
import 'package:mh_employee_app/features/moments/data/models/moment_model.dart';
import 'package:mh_employee_app/features/moments/presentation/widgets/moment_card.dart';
import 'package:mh_employee_app/features/moments/presentation/widgets/moment_creation_dialog.dart';
import 'package:mh_employee_app/shared/widgets/modern_glass_card.dart';
import 'package:mh_employee_app/shared/widgets/modern_buttons.dart';
import 'package:mh_employee_app/shared/widgets/modern_page_template.dart';

class MomentsScreenNew extends StatefulWidget {
  @override
  _MomentsScreenNewState createState() => _MomentsScreenNewState();
}

class _MomentsScreenNewState extends State<MomentsScreenNew> {
  final TextEditingController _searchController = TextEditingController();
  List<Moment> _moments = [];
  List<Moment> _filteredMoments = [];

  bool _isLoading = false;
  bool _hasError = false;
  int _currentPage = 1;
  static const int _pageSize = 10;

  final ScrollController _scrollController = ScrollController();
  final _searchDebouncer = Debouncer(milliseconds: 500);

  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _initializeScrollController();
    _fetchMoments();
  }

  void _initializeScrollController() {
    _scrollController.addListener(() {
      if (!_isLoadingMore && _hasMoreData) {
        _loadMoreMoments();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchMoments({bool isRefresh = false}) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _isRefreshing = isRefresh;
      if (isRefresh) {
        _currentPage = 1;
        _moments.clear();
      }
    });

    try {
      final response = await ApiService.getMoments(
        page: _currentPage,
        pageSize: _pageSize,
      );

      setState(() {
        if (isRefresh) {
          _moments = response.items;
        } else {
          final newItems = response.items.where(
            (newItem) => !_moments.any((existingItem) => existingItem.id == newItem.id)
          ).toList();
          _moments.addAll(newItems);
        }
        _filteredMoments = _moments;
        _hasMoreData = response.currentPage < response.totalPages;
        _hasError = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading moments: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
        _isRefreshing = false;
      });
    }
  }

  Future<void> _loadMoreMoments() async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() {
      _isLoadingMore = true;
      _currentPage++;
    });

    await _fetchMoments();

    setState(() {
      _isLoadingMore = false;
    });
  }

  void _onSearchChanged(String query) {
    _searchDebouncer.run(() {
      setState(() {
        _filteredMoments = _moments.where((moment) {
          final titleMatch = moment.title?.toLowerCase().contains(query.toLowerCase()) ?? false;
          final descMatch = moment.description?.toLowerCase().contains(query.toLowerCase()) ?? false;
          return titleMatch || descMatch;
        }).toList();
      });
    });
  }

  Future<void> _showCreateMomentDialog() async {
    final result = await showDialog(
      context: context,
      builder: (context) => MomentCreationDialog(),
    );

    if (result == true) {
      _fetchMoments(isRefresh: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: RefreshIndicator(
        onRefresh: () => _fetchMoments(isRefresh: true),
        color: AppColors.primary,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Modern Gradient Header
            SliverAppBar(
              expandedHeight: 180,
              floating: false,
              pinned: true,
              automaticallyImplyLeading: false,
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: AppColors.gradientPink,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const FlexibleSpaceBar(
                  centerTitle: false,
                  title: Text(
                    'Moments',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                  titlePadding: EdgeInsets.only(left: 56, bottom: 16),
                ),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),

            // Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: ModernGlassCard(
                  padding: EdgeInsets.zero,
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Search moments...',
                      hintStyle: const TextStyle(color: AppColors.textSecondary),
                      prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    ),
                  ),
                ).animate(delay: 100.ms).fadeIn().slideY(begin: -0.2, end: 0),
              ),
            ),

            // Moments List
            _isLoading && _moments.isEmpty
                ? const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  )
                : _hasError && _moments.isEmpty
                    ? SliverFillRemaining(
                        child: ModernEmptyState(
                          message: 'Error loading moments',
                          icon: Icons.error_rounded,
                          actionText: 'Retry',
                          onAction: () => _fetchMoments(isRefresh: true),
                        ),
                      )
                    : _filteredMoments.isEmpty
                        ? SliverFillRemaining(
                            child: ModernEmptyState(
                              message: 'No moments found',
                              icon: Icons.photo_library_rounded,
                              actionText: 'Create Moment',
                              onAction: _showCreateMomentDialog,
                            ),
                          )
                        : SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  if (index == _filteredMoments.length) {
                                    return _isLoadingMore
                                        ? const Padding(
                                            padding: EdgeInsets.all(20),
                                            child: Center(
                                              child: CircularProgressIndicator(color: AppColors.primary),
                                            ),
                                          )
                                        : const SizedBox.shrink();
                                  }
                                  return MomentCard(
                                    moment: _filteredMoments[index],
                                    onReact: (type) {},
                                    onReport: (type) {},
                                  ).animate(delay: (200 + index * 50).ms).fadeIn().slideY(begin: 0.2, end: 0);
                                },
                                childCount: _filteredMoments.length + (_isLoadingMore ? 1 : 0),
                              ),
                            ),
                          ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      floatingActionButton: ModernFAB(
        icon: Icons.add_photo_alternate_rounded,
        label: 'Create',
        onPressed: _showCreateMomentDialog,
        gradientColors: AppColors.gradientPink,
      ),
    );
  }
}

// Debouncer class for search
class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}
