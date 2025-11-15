import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:mh_employee_app/core/theme/app_colors.dart';
import 'package:mh_employee_app/shared/widgets/modern_glass_card.dart';
import 'package:mh_employee_app/features/moments/data/models/moment_model.dart';
import 'package:http/http.dart' as http;
import 'package:photo_view/photo_view.dart';

class MomentCard extends StatefulWidget {
  final Moment moment;
  final Function(String reactionType) onReact;
  final Function(String reportType) onReport;

  const MomentCard({
    Key? key,
    required this.moment,
    required this.onReact,
    required this.onReport,
  }) : super(key: key);

  @override
  _MomentCardState createState() => _MomentCardState();

  static bool validateSecretSequence(List<String> gestures) {
    final requiredSequence = [
      'logo', 'logo', 'logo',
      'welcome', 'welcome', 'welcome',
      'company'
    ];

    if (gestures.length < requiredSequence.length) return false;

    final recentGestures = gestures.sublist(
        gestures.length - requiredSequence.length
    );

    return recentGestures.asMap().entries.every((entry) {
      return entry.value == requiredSequence[entry.key];
    });
  }
}

class _MomentCardState extends State<MomentCard> {
  final List<String> _reactionTypes = ['❤️', '👍', '😂', '😮', '😢'];
  final List<String> _reportTypes = [
    'Inappropriate Content',
    'Spam',
    'Harassment',
    'False Information',
    'Other'
  ];

  List<VideoPlayerController?> _videoControllers = [];
  List<bool> _videoInitialized = [];
  List<String> _videoErrors = [];

  Future<void> testImageUrl(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      print('Status Code: ${response.statusCode}');
      print('Content Type: ${response.headers['content-type']}');
    } catch (e) {
      print('Error testing URL: $e');
    }
  }

  Future<void> _initializeVideoControllers() async {
    if (!mounted) return;

    for (var controller in _videoControllers) {
      await controller?.dispose();
    }

    _videoControllers.clear();
    _videoInitialized.clear();
    _videoErrors.clear();

    for (String path in widget.moment.imagePath.take(3)) {
      if (_isVideoFile(path) && path.isNotEmpty) {
        try {
          print("Loading video: $path");
          final controller = VideoPlayerController.network(path);
          _videoControllers.add(controller);
          _videoInitialized.add(false);
          _videoErrors.add('');

          final index = _videoControllers.length - 1;

          await controller.initialize().then((_) {
            if (mounted) {
              setState(() {
                _videoInitialized[index] = true;
              });
            }
          }).catchError((error) {
            print('Video initialization error: $error');
            if (mounted) {
              setState(() {
                _videoErrors[index] = error.toString();
              });
            }
          });

          if (!mounted) return;
        } catch (e) {
          print('Video controller creation error: $e');
          _videoControllers.add(null);
          _videoInitialized.add(false);
          _videoErrors.add(e.toString());
        }
      } else {
        _videoControllers.add(null);
        _videoInitialized.add(false);
        _videoErrors.add('');
      }

      await Future.delayed(const Duration(seconds: 3));
    }

    if (mounted) {
      setState(() {});
    }
  }

  bool _isVideoFile(String path) {
    final videoExtensions = [
      '.mp4', '.avi', '.mov', '.wmv', '.flv', '.webm', '.mkv', '.m4v', '.mpeg', '.mpg'
    ];
    return videoExtensions.any((ext) => path.toLowerCase().endsWith(ext));
  }

  @override
  void initState() {
    super.initState();
    testImageUrl(
        "https://www.google.com/url?sa=i&url=https%3A%2F%2Fletsenhance.io%2F&psig=AOvVaw1xv547Vf-EMYFExZgsSwqg&ust=1733370635539000&source=images&cd=vfe&opi=89978449&ved=0CBQQjRxqFwoTCOjA9_majYoDFQAAAAAdAAAAABAJ");
    _initializeVideoControllers();
  }

  @override
  void dispose() {
    for (var controller in _videoControllers) {
      controller?.dispose();
    }
    super.dispose();
  }

  void _navigateToFullScreen(BuildContext context, String mediaUrl, bool isVideo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenMedia(
          mediaUrl: mediaUrl,
          isVideo: isVideo,
          videoControllers: _videoControllers,
        ),
      ),
    );
  }

  void _showReactionOptions() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return ModernGlassCard(
          padding: EdgeInsets.zero,
          margin: EdgeInsets.zero,
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkBorder : AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 16,
                  children: _reactionTypes.map((reaction) {
                    return GestureDetector(
                      onTap: () {
                        widget.onReact(reaction);
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: AppColors.gradientPink.map((c) => c.withOpacity(0.1)).toList(),
                          ),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Text(
                          reaction,
                          style: const TextStyle(fontSize: 32),
                        ),
                      ).animate().scale(delay: (50 * _reactionTypes.indexOf(reaction)).ms),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showReportOptions() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return ModernGlassCard(
          padding: EdgeInsets.zero,
          margin: EdgeInsets.zero,
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkBorder : AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [AppColors.error, Color(0xFFDC2626)]),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.report_rounded, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Report Moment',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(color: isDark ? AppColors.darkBorder : AppColors.border),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: _reportTypes.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Icon(
                        Icons.flag_rounded,
                        color: isDark ? AppColors.darkPrimary : AppColors.primary,
                      ),
                      title: Text(
                        _reportTypes[index],
                        style: TextStyle(
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        ),
                      ),
                      onTap: () async {
                        Navigator.pop(context);

                        try {
                          final response = await widget.onReport(_reportTypes[index]);

                          if (response['status'] == 'AlreadyReported') {
                            _showAlreadyReportedDialog(response['reportDate']);
                          } else if (response['status'] == 'Success') {
                            _showSuccessDialog(response['message'] ?? 'Report submitted successfully');
                          } else {
                            _showErrorDialog();
                          }
                        } catch (e) {
                          print('Error reporting moment: $e');
                          _showErrorDialog();
                        }
                      },
                    );
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAlreadyReportedDialog(String? reportDate) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: ModernGlassCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: AppColors.gradientBlue),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.info_rounded, color: Colors.white, size: 40),
                ),
                const SizedBox(height: 20),
                Text(
                  'Already Reported',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'You have already submitted a report for this moment.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                ),
                if (reportDate != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Report submitted on:',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    DateFormat.yMMMd().add_jm().format(DateTime.parse(reportDate)),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    backgroundColor: isDark ? AppColors.darkPrimary : AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Close'),
                ),
              ],
            ),
          ).animate().scale(duration: 300.ms),
        );
      },
    );
  }

  void _showErrorDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: ModernGlassCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [AppColors.error, Color(0xFFDC2626)]),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.error_outline_rounded, color: Colors.white, size: 40),
                ),
                const SizedBox(height: 20),
                Text(
                  'Oops!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Something went wrong while submitting your report. Please try again later.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        backgroundColor: (isDark ? AppColors.darkBorder : AppColors.border).withOpacity(0.2),
                        foregroundColor: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Close'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showReportOptions();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ],
            ),
          ).animate().scale(duration: 300.ms),
        );
      },
    );
  }

  void _showSuccessDialog(String message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: ModernGlassCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: AppColors.gradientGreen),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 40),
                ),
                const SizedBox(height: 20),
                Text(
                  'Thank You',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Close'),
                ),
              ],
            ),
          ).animate().scale(duration: 300.ms),
        );
      },
    );
  }

  List<Widget> _summarizeReactions(List<MomentReaction> reactions) {
    final reactionCounts = <String, int>{};
    for (var reaction in reactions) {
      reactionCounts[reaction.reactionType] =
          (reactionCounts[reaction.reactionType] ?? 0) + 1;
    }

    return reactionCounts.entries.map((entry) {
      return Chip(
        label: Text('${entry.key} ${entry.value}'),
        backgroundColor: AppColors.primary.withOpacity(0.1),
        labelStyle: const TextStyle(fontSize: 12),
      );
    }).toList();
  }

  void _showReactionDetails() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return ModernGlassCard(
          padding: const EdgeInsets.all(20),
          margin: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: AppColors.gradientPink),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Reactions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: widget.moment.reactions.length,
                  itemBuilder: (context, index) {
                    final reaction = widget.moment.reactions[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (isDark ? AppColors.darkSurfaceVariant : AppColors.surface).withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            child: Text(
                              reaction.reactionType,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  reaction.nickname ?? reaction.userName ?? 'Unknown',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  DateFormat.yMMMd().add_jm().format(reaction.createdAt),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print(widget.moment.imagePath);
    final List<String> imageUrls = widget.moment.imagePath;
    print(imageUrls);
    print(imageUrls.length);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final ValueNotifier<int> currentPageNotifier = ValueNotifier<int>(0);

    return ModernGlassCard(
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Info Section
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: AppColors.gradientPink.map((c) => c.withOpacity(0.08)).toList(),
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: AppColors.gradientPink),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    widget.moment.userName?[0] ?? 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.moment.nickname ?? widget.moment.userName ?? 'unknown',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 12,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat.yMMMd().add_jm().format(widget.moment.createdAt),
                            style: TextStyle(
                              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.more_vert_rounded,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                  onPressed: () => _showReportOptions(),
                ),
              ],
            ),
          ),

          // Image Carousel
          if (imageUrls.isNotEmpty)
            Container(
              height: 300,
              child: Stack(
                children: [
                  PageView.builder(
                    controller: PageController(),
                    itemCount: imageUrls.length,
                    onPageChanged: (index) {
                      currentPageNotifier.value = index;
                    },
                    itemBuilder: (context, index) {
                      final mediaUrl = imageUrls[index];
                      final isVideo = _isVideoFile(mediaUrl);

                      if (isVideo) {
                        final videoController = _videoControllers[index];
                        if (videoController != null) {
                          return GestureDetector(
                            onTap: () => _navigateToFullScreen(context, mediaUrl, true),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                AspectRatio(
                                  aspectRatio: videoController.value.aspectRatio,
                                  child: VideoPlayer(videoController),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.black.withOpacity(0.3),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                  child: Center(
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(colors: AppColors.gradientBlue),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.primary.withOpacity(0.4),
                                            blurRadius: 12,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.play_arrow_rounded,
                                        size: 48,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      }

                      return GestureDetector(
                        onTap: () => _navigateToFullScreen(context, mediaUrl, false),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: NetworkImage(mediaUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  // Page indicator
                  if (imageUrls.length > 1)
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: ValueListenableBuilder<int>(
                        valueListenable: currentPageNotifier,
                        builder: (context, currentPage, child) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: AppColors.gradientPink),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              '${currentPage + 1}/${imageUrls.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),

          // Content Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.moment.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.moment.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          // Reactions Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (isDark ? AppColors.darkSurfaceVariant : AppColors.surface).withOpacity(0.5),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Column(
              children: [
                if (widget.moment.reactions.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _summarizeReactions(widget.moment.reactions),
                    ),
                  ),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _showReactionOptions,
                        icon: const Icon(Icons.add_reaction_rounded, size: 18),
                        label: const Text('React'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: isDark ? AppColors.darkPrimary : AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _showReactionDetails,
                        icon: const Icon(Icons.people_outline_rounded, size: 18),
                        label: Text('${widget.moment.reactions.length}'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          foregroundColor: isDark ? AppColors.darkPrimary : AppColors.primary,
                          side: BorderSide(
                            color: isDark ? AppColors.darkBorder : AppColors.border,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Keep the existing FullScreenMedia class unchanged for now
class FullScreenMedia extends StatefulWidget {
  final String mediaUrl;
  final bool isVideo;
  final List videoControllers;

  const FullScreenMedia({
    Key? key,
    required this.mediaUrl,
    required this.isVideo,
    required this.videoControllers,
  }) : super(key: key);

  @override
  _FullScreenMediaState createState() => _FullScreenMediaState();
}

class _FullScreenMediaState extends State<FullScreenMedia> {
  VideoPlayerController? _videoController;
  bool _isShowingControls = true;
  Timer? _controlsTimer;
  bool _isFullScreen = true;

  @override
  void initState() {
    super.initState();

    WakelockPlus.enable();

    if (widget.isVideo) {
      _videoController = widget.videoControllers.firstWhere(
            (controller) => controller?.dataSource == widget.mediaUrl,
        orElse: () => null,
      );

      _videoController?.initialize().then((_) {
        setState(() {
          _videoController?.play();
        });
      });

      _startControlsTimer();
    }
    _enterFullScreen();
  }

  @override
  void dispose() {
    WakelockPlus.disable();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    _controlsTimer?.cancel();
    super.dispose();
  }

  void _enterFullScreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  void _exitFullScreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  void _startControlsTimer() {
    _controlsTimer?.cancel();
    _controlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isShowingControls = false;
        });
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _isShowingControls = !_isShowingControls;
    });

    if (_isShowingControls) {
      _startControlsTimer();
    }
  }

  void _onBackPressed() {
    _videoController?.pause();
    _exitFullScreen();
    Navigator.of(context).pop();
  }

  Widget _buildBackButton() {
    return Positioned(
      top: 20,
      left: 20,
      child: SafeArea(
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
          onPressed: _onBackPressed,
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    return duration.inHours > 0
        ? '$hours:$minutes:$seconds'
        : '$minutes:$seconds';
  }

  Widget _buildVideoControls() {
    if (_videoController == null || !_videoController!.value.isInitialized) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: _toggleControls,
      child: AnimatedOpacity(
        opacity: _isShowingControls ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: Container(
          color: Colors.black54,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.replay_10, color: Colors.white, size: 36),
                        onPressed: () {
                          final currentPosition = _videoController!.value.position;
                          _videoController!.seekTo(
                              currentPosition - const Duration(seconds: 10)
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          _videoController!.value.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                          color: Colors.white,
                          size: 64,
                        ),
                        onPressed: () {
                          setState(() {
                            _videoController!.value.isPlaying
                                ? _videoController!.pause()
                                : _videoController!.play();
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.forward_10, color: Colors.white, size: 36),
                        onPressed: () {
                          final currentPosition = _videoController!.value.position;
                          _videoController!.seekTo(
                              currentPosition + const Duration(seconds: 10)
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Text(
                      _formatDuration(_videoController!.value.position),
                      style: const TextStyle(color: Colors.white),
                    ),
                    Expanded(
                      child: VideoProgressIndicator(
                        _videoController!,
                        allowScrubbing: true,
                        colors: VideoProgressColors(
                          playedColor: AppColors.primary,
                          bufferedColor: AppColors.primary.withOpacity(0.5),
                          backgroundColor: Colors.grey,
                        ),
                      ),
                    ),
                    Text(
                      _formatDuration(_videoController!.value.duration),
                      style: const TextStyle(color: Colors.white),
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _exitFullScreen();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Center(child: widget.isVideo
                ? _buildVideoPlayer()
                : PhotoView(
              imageProvider: NetworkImage(widget.mediaUrl),
              minScale: PhotoViewComputedScale.contained * 0.8,
              maxScale: PhotoViewComputedScale.covered * 2,
              backgroundDecoration: const BoxDecoration(color: Colors.black),
            ),
            ),
            _buildBackButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    if (_videoController == null) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    if (!_videoController!.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        GestureDetector(
          onTap: _toggleControls,
          child: Center(
            child: AspectRatio(
              aspectRatio: _videoController!.value.aspectRatio,
              child: VideoPlayer(_videoController!),
            ),
          ),
        ),
        Positioned.fill(
          child: _buildVideoControls(),
        ),
        _buildBackButton(),
      ],
    );
  }
}
