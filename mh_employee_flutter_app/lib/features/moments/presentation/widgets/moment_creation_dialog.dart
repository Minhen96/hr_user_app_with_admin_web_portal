import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_thumbnail_video/index.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';

class MediaItem {
  final XFile file;
  final bool isVideo;

  MediaItem({
    required this.file,
    required this.isVideo,
  });
}

class MomentCreationDialog extends StatefulWidget {
  @override
  _MomentCreationDialogState createState() => _MomentCreationDialogState();
}

class _MomentCreationDialogState extends State<MomentCreationDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  List<MediaItem> _selectedMedia = [];
  final ImagePicker _picker = ImagePicker();

  final Map<String, Uint8List> _videoThumbnails = {};


  Future<void> _pickMedia() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.media,
        allowMultiple: true,
        allowCompression: true,
        withData: true,
      );

      if (result != null) {
        for (var file in result.files) {
          // Check if file is video based on extension
          final isVideo = [
            'mp4', 'mov', 'avi', '3gp', 'mkv'
          ].contains(file.extension?.toLowerCase());

          // Convert PlatformFile to XFile
          // On web, path is always null, use bytes instead
          final xFile = kIsWeb
              ? XFile.fromData(
                  file.bytes!,
                  name: file.name,
                  mimeType: file.extension != null
                    ? (isVideo ? 'video/${file.extension}' : 'image/${file.extension}')
                    : null,
                )
              : XFile(
                  file.path!,
                  name: file.name,
                  bytes: file.bytes,
                );

          // If it's a video and not on web, generate thumbnail
          if (isVideo && file.path != null && !kIsWeb) {
            try {
              final uint8list = await _generateThumbnail(file.path!);
              if (uint8list != null) {
                _videoThumbnails[xFile.path] = uint8list;
              }
            } catch (e) {
              print('Error generating thumbnail: $e');
            }
          }

          final mediaItem = MediaItem(
            file: xFile,
            isVideo: isVideo,
          );

          setState(() {
            _selectedMedia.add(mediaItem);
          });
        }
      }
    } catch (e) {
      print('Error picking media: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick media. On web, path is always null - you should access bytes property instead.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<Uint8List?> _generateThumbnail(String videoPath) async {
    try {
      final uint8list = await VideoThumbnail.thumbnailData(
        video: videoPath,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 130,
        quality: 75,
      );
      return uint8list;
    } catch (e) {
      print('Error generating thumbnail: $e');
      return null;
    }
  }


  Widget _buildMediaPreview(bool isDark) {
    return Container(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _selectedMedia.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Container(
              width: 130,
              height: 130,
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFEC4899).withOpacity(0.1), Color(0xFFF97316).withOpacity(0.1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? Color(0xFF475569) : Color(0xFFE2E8F0),
                  width: 2,
                  style: BorderStyle.solid,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: _pickMedia,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFFEC4899), Color(0xFFF97316)],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.add_photo_alternate_rounded, size: 28, color: Colors.white),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Add Media',
                        style: TextStyle(
                          color: isDark ? Color(0xFFF1F5F9) : Color(0xFF0F172A),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          final mediaIndex = index - 1;
          final media = _selectedMedia[mediaIndex];

          // For videos, use the stored thumbnail if available
          if (media.isVideo && _videoThumbnails.containsKey(media.file.path)) {
            return _buildMediaPreviewItem(
              thumbnailData: _videoThumbnails[media.file.path]!,
              isVideo: true,
              onRemove: () {
                setState(() {
                  _videoThumbnails.remove(media.file.path);
                  _selectedMedia.removeAt(mediaIndex);
                });
              },
            );
          }

          // For images or if video thumbnail is not yet generated
          return FutureBuilder<Uint8List>(
            future: media.file.readAsBytes(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container(
                  width: 130,
                  height: 130,
                  margin: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey.shade200,
                  ),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              return _buildMediaPreviewItem(
                thumbnailData: snapshot.data!,
                isVideo: media.isVideo,
                onRemove: () {
                  setState(() {
                    if (media.isVideo) {
                      _videoThumbnails.remove(media.file.path);
                    }
                    _selectedMedia.removeAt(mediaIndex);
                  });
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildMediaPreviewItem({
    required Uint8List thumbnailData,
    required bool isVideo,
    required VoidCallback onRemove,
  }) {
    return Stack(
      children: [
        Container(
          width: 130,
          height: 130,
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            image: DecorationImage(
              image: MemoryImage(thumbnailData),
              fit: BoxFit.cover,
            ),
          ),
        ),
        if (isVideo)
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.play_circle_fill, color: Colors.white, size: 16),
                  SizedBox(width: 4),
                  Text(
                    'Video',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.close, color: Colors.white, size: 20),
              onPressed: onRemove,
              padding: EdgeInsets.all(4),
              constraints: BoxConstraints(),
              iconSize: 20,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [Color(0xFF1E293B), Color(0xFF334155)]
                : [Colors.white, Color(0xFFF8FAFC)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 30,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Modern Header with Gradient
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFEC4899), Color(0xFFF97316)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.photo_library_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Create a Moment',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTextField(
                      controller: _titleController,
                      label: 'Title',
                      icon: Icons.title_rounded,
                      isDark: isDark,
                    ),
                    SizedBox(height: 16),

                    _buildTextField(
                      controller: _descriptionController,
                      label: 'Description',
                      icon: Icons.description_rounded,
                      maxLines: 3,
                      isDark: isDark,
                    ),
                    SizedBox(height: 20),

                    _buildMediaPreview(isDark),
                  ],
                ),
              ),
            ),

            // Action Buttons
            Container(
              padding: EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      text: 'Cancel',
                      onPressed: () => Navigator.of(context).pop(),
                      isPrimary: false,
                      isDark: isDark,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      text: 'Create',
                      onPressed: () {
                        if (_validateInput()) {
                          Navigator.of(context).pop({
                            'title': _titleController.text,
                            'description': _descriptionController.text,
                            'media': _selectedMedia,
                          });
                        }
                      },
                      isPrimary: true,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: TextStyle(
          color: isDark ? Color(0xFFF1F5F9) : Color(0xFF0F172A),
          fontSize: 15,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: isDark ? Color(0xFF94A3B8) : Color(0xFF64748B),
          ),
          prefixIcon: Icon(
            icon,
            color: isDark ? Color(0xFFEC4899) : Color(0xFFEC4899),
            size: 22,
          ),
          filled: true,
          fillColor: isDark ? Color(0xFF334155) : Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: isDark ? Color(0xFF475569) : Color(0xFFE2E8F0),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Color(0xFFEC4899),
              width: 2,
            ),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String text,
    required VoidCallback onPressed,
    required bool isDark,
    bool isPrimary = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: isPrimary
            ? LinearGradient(
                colors: [Color(0xFFEC4899), Color(0xFFF97316)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : null,
        boxShadow: isPrimary
            ? [
                BoxShadow(
                  color: Color(0xFFEC4899).withOpacity(0.4),
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? Colors.transparent : (isDark ? Color(0xFF334155) : Colors.white),
          foregroundColor: isPrimary ? Colors.white : (isDark ? Color(0xFFF1F5F9) : Color(0xFF0F172A)),
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: !isPrimary
                ? BorderSide(
                    color: isDark ? Color(0xFF475569) : Color(0xFFE2E8F0),
                    width: 1.5,
                  )
                : BorderSide.none,
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  bool _validateInput() {
    if (_titleController.text.isEmpty || _selectedMedia.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please add a title and at least one media item'),
          backgroundColor: Colors.red.shade400,
        ),
      );
      return false;
    }
    return true;
  }
}



