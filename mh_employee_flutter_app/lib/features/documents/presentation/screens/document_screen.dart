import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path/path.dart' as path;
// import 'package:mh_employee_app/core/network/api_client.dart'; // TODO: Migrate to ApiClient
import 'package:mh_employee_app/services/api_service.dart';
import 'package:mh_employee_app/features/documents/data/models/document_model.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:mh_employee_app/features/documents/presentation/widgets/cards/document_card.dart';
import 'package:mh_employee_app/features/documents/presentation/screens/document_detail_screen.dart';
import 'package:mh_employee_app/core/widgets/loading/modern_loading.dart';
import 'package:mh_employee_app/core/widgets/states/empty_state.dart';

class DocumentScreen extends StatefulWidget {
  final String? initialType; // Optional initial type
  final String? title; // Optional custom title

  const DocumentScreen({
    Key? key,
    this.initialType,
    this.title,
  }) : super(key: key);

  @override
  _DocumentScreenState createState() => _DocumentScreenState();
}

class _DocumentScreenState extends State<DocumentScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Enhanced color palette
  final _colorScheme = {
    'primary': Color(0xFF30B381),
    'secondary': Color(0xFF000000),
    'background': Color(0xFFF5F7FA),
    'card': Colors.white,
    'accent': Color(0xFFFF6B6B),
  };

  Map<String, int> _unreadCounts = {
    'MEMO': 0,
    'SOP': 0,
    'POLICY': 0,
    'UserGuide': 0,
    'UPDATES': 0,
  };
  final Map<String, List<Document>> _documents = {
    'MEMO': [],
    'SOP': [],
    'POLICY': [],
    'UserGuide': [],
    'UPDATES': [],
  };
  final Map<String, bool> _isLoadingMore = {
    'MEMO': false,
    'SOP': false,
    'POLICY': false,
    'UserGuide': false,
    'UPDATES': false,
  };
  final Map<String, int> _currentPage = {
    'MEMO': 1,
    'SOP': 1,
    'POLICY': 1,
    'UserGuide': 1,
    'UPDATES': 1,
  };
  final Map<String, bool> _hasMorePages = {
    'MEMO': true,
    'SOP': true,
    'POLICY': true,
    'UserGuide': true,
    'UPDATES': true,
  };
  bool _isLoading = true;
  String? _error;
  int? _UserguidetotalPages; // Total number of pages in the PDF
  int? _UserguidecurrentPage; // Current page being viewed
  PDFViewController? _pdfViewController; // PDF view controller

  @override
  void initState() {
    super.initState();
    _loadUnreadCounts();

    // Determine the initial tab based on the initialType
    int initialIndex = 0;
    if (widget.initialType != null) {
      switch (widget.initialType) {
        case 'SOP':
          initialIndex = 1;
          break;
        case 'POLICY':
          initialIndex = 2;
          break;
        case 'UserGuide':
          initialIndex = 3;
          break;
        default:
          initialIndex = 0;
      }
    }

    _tabController = TabController(length: 4, vsync: this, initialIndex: initialIndex);
    _tabController.addListener(_handleTabChange);
    _loadInitialData();
  }

  Future<void> _loadUnreadCounts() async {
    try {
      // TODO: Migrate to ApiClient
      final counts = await ApiService.getDocumentUnreadCounts();
      setState(() {
        _unreadCounts = counts;
      });
    } catch (e) {
      print('Error loading unread counts: $e');
    }
  }

  Future<void> _markDocumentAsRead(int documentId, String type) async {
    try {
      // TODO: Migrate to ApiClient
      await ApiService.markDocumentAsRead(documentId);
      setState(() {
        // Update unread count
        if (_unreadCounts[type]! > 0) {
          _unreadCounts[type] = _unreadCounts[type]! - 1;
        }

        // Update document in list
        final index = _documents[type]!.indexWhere((doc) => doc.id == documentId);
        if (index != -1) {
          _documents[type]![index] = _documents[type]![index].copyWith(isRead: true);
        }
      });
    } catch (e) {
      print('Error marking document as read: $e');
    }
  }

  Future<void> _refreshDocuments() async {
    try {
      // Get the current document type
      final type = _getCurrentType();

      // Reset pagination
      _currentPage[type] = 1;
      _hasMorePages[type] = true;

      // Clear existing documents
      setState(() {
        _documents[type]!.clear();
        _isLoading = true;
        _error = null;
      });

      // Load documents for the current type
      await _loadDocumentsForType(type);

      // Update state
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      final type = _getCurrentType();
      if (_documents[type]!.isEmpty && _hasMorePages[type]!) {
        _loadDocumentsForType(type);
      }
    }
  }

  Future<void> _loadInitialData() async {
    try {
      setState(() => _isLoading = true);
      await _loadDocumentsForType(_getCurrentType());
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  String _getCurrentType() {
    // If widget has initialType set, determine which type it is
    if (widget.initialType != null) {
      switch (widget.initialType) {
        case 'UPDATES':
          return 'UPDATES';
        case 'UserGuide':
          return 'UserGuide';
        case 'POLICY':
          return 'POLICY';
        case 'SOP':
          return 'SOP';
        case 'MEMO':
          return 'MEMO';
        default:
          return widget.initialType!;
      }
    }

    // Otherwise use tab controller
    switch (_tabController.index) {
      case 0:
        return 'MEMO';
      case 1:
        return 'SOP';
      case 2:
        return 'POLICY';
      case 3:
        return 'UserGuide';
      default:
        return 'MEMO';
    }
  }

  Future<void> _loadDocumentsForType(String type) async {
    if (_isLoadingMore[type]! || !_hasMorePages[type]!) return;

    try {
      setState(() => _isLoadingMore[type] = true);

      print('Loading documents for type: $type, page: ${_currentPage[type]}');

      // TODO: Migrate to ApiClient - 

      // TODO: Migrate to ApiClient
      final response = await ApiService.getDocuments(
        type: type,
        page: _currentPage[type]!,
      );

      print('Response type: ${response.runtimeType}');
      print('Documents count: ${response.items.length}');
      print('Current Page: ${response.currentPage}');
      print('Total Pages: ${response.totalPages}');
      print('Total Count: ${response.totalCount}');

      setState(() {
        if (_currentPage[type] == 1) {
          _documents[type] = response.items;
        } else {
          _documents[type]!.addAll(response.items);
        }

        _hasMorePages[type] = _currentPage[type]! < response.totalPages;
        if (_hasMorePages[type]!) {
          _currentPage[type] = _currentPage[type]! + 1;
        }
        _isLoadingMore[type] = false;
      });
    } catch (e, stackTrace) {
      print('Error loading documents: $e');
      print('Stack trace: $stackTrace');

      setState(() {
        _error = e.toString();
        _isLoadingMore[type] = false;
      });
    }
  }

  Future<void> _launchURL(String urlPath, String action) async {
    try {
      final url = Uri.parse('http://localhost:5000$urlPath');
      if (!await launchUrl(
        url,
        mode: LaunchMode.platformDefault,
        webViewConfiguration: const WebViewConfiguration(
          enableJavaScript: true,
          enableDomStorage: true,
        ),
      )) {
        throw 'Could not launch $url';
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar(
            'Error ${action.toLowerCase()} document: ${e.toString()}');
      }
    }
  }

  void _showErrorSnackbar(String message,
      {Color backgroundColor = Colors.red}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: backgroundColor,
        duration: Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  //TODO
  Future<void> previewDocument(Document doc) async {
    try {
      // Validate document
      if (doc.documentUpload == null) {
        _showErrorSnackbar('No document available for preview');
        return;
      }

      // Decode document content
      Uint8List? fileBytes = await _decodeDocumentContent(doc.documentUpload!);

      if (fileBytes == null) {
        _showErrorSnackbar('Failed to decode document');
        return;
      }

      // if (doc.fileType?.toLowerCase() == 'pdf' && doc.type == 'UserGuide') {
      //   try {
      //     // Fetch PDF data specifically for user guide
      //     Uint8List pdfData = // TODO: Migrate to ApiClient -  await ApiService.fetchUserGuidePDF();

      //     // Save PDF to a temporary file
      //     final tempDir = await getTemporaryDirectory();
      //     final tempFile = File('${tempDir.path}/user_guide.pdf');
      //     await tempFile.writeAsBytes(pdfData);

      //     // Open the PDF file
      //     final result = await OpenFile.open(tempFile.path);

      //     if (result.type != ResultType.done) {
      //       _showErrorSnackbar('Could not open PDF: ${result.message}');
      //     }
      //   } catch (e) {
      //     _showErrorSnackbar('Error fetching user guide PDF: $e');
      //   }
      //   return;
      // }

      // Determine file extension
      String fileExtension = _getFileExtension(doc.fileType);

      // Save temporary file
      final tempFile = await _saveTempFile(fileBytes, fileExtension);

      // Open file
      await _openFile(tempFile, fileExtension);
    } catch (e) {
      _showErrorSnackbar('Error previewing document: $e');
    }
  }

  /// Decode document content from various sources
  Future<Uint8List?> _decodeDocumentContent(String documentContent) async {
    try {
      // Base64 with MIME type
      if (documentContent.contains('base64,')) {
        final base64Data = documentContent.split(',').last;
        return base64Decode(base64Data);
      }

      // Plain Base64
      if (_isBase64(documentContent)) {
        return base64Decode(documentContent);
      }

      // URL-based document
      if (documentContent.startsWith('http')) {
        final response = await http.get(Uri.parse(documentContent));
        return response.statusCode == 200 ? response.bodyBytes : null;
      }

      return null;
    } catch (e) {
      print('Decoding error: $e');
      return null;
    }
  }

  /// Check if string is valid Base64
  bool _isBase64(String str) {
    try {
      base64Decode(str);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Save temporary file
  Future<File> _saveTempFile(Uint8List fileBytes, String extension) async {
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/preview_document.$extension');
    await tempFile.writeAsBytes(fileBytes);
    return tempFile;
  }

  /// Open file using appropriate method
  Future<void> _openFile(File file, String extension) async {
    try {
      final result = await OpenFile.open(file.path);

      if (result.type != ResultType.done) {
        _showErrorSnackbar('Could not open file: ${result.message}');
      }
    } catch (e) {
      _showErrorSnackbar('File opening error: $e');
    }
  }

  /// Shows an error snackbar
  // void _showErrorSnackbar(String message) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text(message),
  //       backgroundColor: Colors.red,
  //     ),
  //   );
  // }

  Future<void> _downloadDocument(Document doc) async {
    try {
      print('Document ID: ${doc.id}');
      print('Document Title: ${doc.title}');
      print('Original Document File Type: ${doc.fileType}');

      // Ensure file type is not null or empty
      String fileType = doc.fileType?.trim() ?? 'txt';
      if (fileType.isEmpty) {
        _showErrorSnackbar('Unable to determine file type');
        return;
      }

      String fileExtension = _getFileExtension(fileType);
      print('Determined File Extension: $fileExtension');

      // Rest of the method remains the same...
      String sanitizedTitle = doc.title
          .replaceAll(RegExp(r'[^\w\s-]'), '') // Remove special characters
          .trim()
          .replaceAll(' ', '_'); // Replace spaces with underscores
      final fileName = '${sanitizedTitle}$fileExtension';

      // Get the appropriate directory for downloads
      Directory? downloadDir;
      if (Platform.isAndroid) {
        // For Android, use the Downloads directory
        downloadDir = Directory('/storage/emulated/0/Download');

        // Ensure the directory exists
        if (!await downloadDir.exists()) {
          downloadDir.createSync(recursive: true);
        }
      } else if (Platform.isIOS) {
        downloadDir = await getApplicationDocumentsDirectory();
      } else {
        downloadDir = await getDownloadsDirectory();
      }

      if (downloadDir == null) {
        throw Exception('Could not find download directory');
      }

      final savePath = '${downloadDir.path}/$fileName';

      print('Attempting to download to: $savePath'); // Debug print

      // Show download progress dialog
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => _DownloadProgressDialog(
          fileName: fileName,
          onDownload: (progress) async {
            // TODO: Migrate to ApiClient -
            // TODO: Migrate to ApiClient
            // await ApiService.downloadToCustomLocation(
            //   doc.id,
            //   savePath,
            //   (received, total) {
            //     print('Download progress: $received / $total'); // Debug print
            //     if (total > 0) {
            //       progress(received / total);
            //     }
            //   },
            // );
          },
        ),
      );

      // Verify file exists
      final downloadedFile = File(savePath);
      if (await downloadedFile.exists()) {
        print('File successfully downloaded to: $savePath'); // Debug print

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Download Complete'),
                      Text(
                        'File saved: $fileName',
                        style: TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        throw Exception('File was not saved successfully');
      }
    } catch (e) {
      print('Download error: $e'); // Debug print

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 8),
              Expanded(child: Text('Download failed: $e')),
            ],
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  static String _getFileExtension(String? fileType) {
    if (fileType == null) return '.txt';

    // Mapping consistent with the provided JavaScript function
    final extensionMap = {
      'application/pdf': '.pdf',
      'application/msword': '.doc',
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document':
          '.docx',
      'application/vnd.ms-excel': '.xls',
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet':
          '.xlsx',
      'application/vnd.ms-powerpoint': '.ppt',
      'application/vnd.openxmlformats-officedocument.presentationml.presentation':
          '.pptx',
      'image/jpeg': '.jpg',
      'image/png': '.png',
      'text/plain': '.txt',
      'application/zip': '.zip',
      'application/x-zip-compressed': '.zip'
    };

    // Return the mapped extension or fallback to .bin
    return extensionMap[fileType] ?? '.bin';
  }

  @override
  PreferredSizeWidget _buildCustomAppBar() {
    return PreferredSize(
      preferredSize: Size.fromHeight(100),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _colorScheme['primary']!,
              _colorScheme['primary']!.withOpacity(0.6),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Stack(
              children: [
                // Back Button
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),

                // Title
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    widget.title ?? 'Documents',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getFileTypeIcon(String? fileType) {
    if (fileType == null) {
      return Icons
          .description; // Default icon for documents without a specific type
    }

    switch (fileType.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _colorScheme['background'],
      appBar: _buildCustomAppBar(),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingIndicator();
    }

    if (_error != null) {
      return _buildErrorView();
    }

    // If initialType is UPDATES, show only UPDATES content without tabs
    if (widget.initialType == 'UPDATES') {
      return _buildTabContent('UPDATES');
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Modern Tab Bar
        Container(
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          padding: EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isDark ? Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              gradient: LinearGradient(
                colors: _colorScheme['primary']!.withOpacity(0.9) == _colorScheme['primary']
                    ? [_colorScheme['primary']!, _colorScheme['primary']!.withOpacity(0.8)]
                    : [_colorScheme['primary']!, Color(0xFF27AE60)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: _colorScheme['primary']!.withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            labelColor: Colors.white,
            unselectedLabelColor: isDark ? Color(0xFF94A3B8) : Color(0xFF64748B),
            labelStyle: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
            unselectedLabelStyle: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.article_outlined, size: 16),
                    SizedBox(width: 6),
                    Text('Memo'),
                    if (_unreadCounts['MEMO']! > 0) ...[
                      SizedBox(width: 4),
                      _buildUnreadBadge(_unreadCounts['MEMO']!),
                    ],
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.description_outlined, size: 16),
                    SizedBox(width: 6),
                    Text('SOP'),
                    if (_unreadCounts['SOP']! > 0) ...[
                      SizedBox(width: 4),
                      _buildUnreadBadge(_unreadCounts['SOP']!),
                    ],
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.policy_outlined, size: 16),
                    SizedBox(width: 6),
                    Text('Policy'),
                    if (_unreadCounts['POLICY']! > 0) ...[
                      SizedBox(width: 4),
                      _buildUnreadBadge(_unreadCounts['POLICY']!),
                    ],
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.menu_book_outlined, size: 16),
                    SizedBox(width: 6),
                    Text('Guide'),
                    if (_unreadCounts['UserGuide']! > 0) ...[
                      SizedBox(width: 4),
                      _buildUnreadBadge(_unreadCounts['UserGuide']!),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),

        // Tab Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            physics: NeverScrollableScrollPhysics(), // Disable swipe
            children: [
              _buildTabContent('MEMO'),
              _buildTabContent('SOP'),
              _buildTabContent('POLICY'),
              _buildUserGuideTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUnreadBadge(int count) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _colorScheme['accent'],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        count > 9 ? '9+' : '$count',
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildTabContent(String type) {
    return RefreshIndicator(
      color: _colorScheme['primary'],
      onRefresh: _refreshDocuments,
      child: _buildDocumentListView(_documents[type]!, type),
    );
  }

//19/12/2024
  Widget _buildUserGuideTab() {
    return FutureBuilder<Uint8List?>(
      // TODO: Migrate to ApiClient
      // future: ApiService.fetchUserGuidePDF(),
      future: Future.value(null), // Placeholder until API is migrated
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Downloading User Guide...'),
              ],
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Failed to load User Guide',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  '${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => setState(() {}),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (snapshot.hasData) {
          return FutureBuilder<File>(
            future: _savePdfToFile(snapshot.data!),
            builder: (context, fileSnapshot) {
              if (fileSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Preparing PDF viewer...'),
                    ],
                  ),
                );
              }

              if (fileSnapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        'Error preparing PDF',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${fileSnapshot.error}',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => setState(() {}),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              if (fileSnapshot.hasData) {
                return EnhancedPDFViewer(filePath: fileSnapshot.data!.path);
              }

              return const Center(
                child: Text('No User Guide available'),
              );
            },
          );
        }

        return const Center(
          child: Text('No User Guide available'),
        );
      },
    );
  }

  Future<File> _savePdfToFile(Uint8List pdfData) async {
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/user_guide.pdf');
    await tempFile.writeAsBytes(pdfData);

    // Add a small delay to ensure the file is fully written
    await Future.delayed(Duration(milliseconds: 200));

    return tempFile;
  }

  Widget _buildDocumentListView(List<Document> documents, String type) {
    if (documents.isEmpty) {
      // Show placeholder when there are no items
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No $type Documents Available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        // Infinite scroll logic
        if (scrollInfo is ScrollEndNotification &&
            scrollInfo.metrics.extentAfter == 0 &&
            _hasMorePages[type]!) {
          _loadDocumentsForType(type);
        }
        return false;
      },
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(bottom: 20, top: 8), // Add bottom padding to prevent overflow
        itemCount: documents.length + (_hasMorePages[type]! ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < documents.length) {
            return _buildAnimatedDocumentCard(
                documents[index], type, AlwaysStoppedAnimation(1.0));
          }
          // Loading indicator for pagination
          return _buildLoadingIndicator();
        },
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: ModernLoading(size: 32),
      ),
    );
  }

  Widget _buildErrorView() {
    return ErrorState(
      title: 'Oops! Something went wrong',
      message: _error ?? 'Unknown error occurred',
      onRetry: _loadInitialData,
    );
  }

  Widget _buildAnimatedDocumentCard(Document doc, String type, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: DocumentCard(
        title: doc.title,
        content: doc.content ?? 'No description available',
        author: doc.posterName,
        datePosted: doc.postDate,
        type: type,
        isRead: doc.isRead,
        onTap: () {
          if (!doc.isRead) {
            _markDocumentAsRead(doc.id, type);
          }
          // Navigate to detail screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DocumentDetailScreen(
                document: doc,
                onDownload: doc.documentUpload != null
                    ? () {
                        Navigator.pop(context);
                        _downloadDocument(doc);
                      }
                    : null,
                onPreview: () {
                  Navigator.pop(context);
                  previewDocument(doc);
                },
              ),
            ),
          );
        },
        onDownload: doc.documentUpload != null
            ? () => _downloadDocument(doc)
            : null,
      ),
    );
  }


  Widget _buildDocumentContent(
      Document doc, ValueNotifier<bool> isExpandedNotifier) {
    // If no content, return empty container
    if (doc.content == null || doc.content!.isEmpty) {
      return SizedBox.shrink();
    }

    return ValueListenableBuilder<bool>(
      valueListenable: isExpandedNotifier,
      builder: (context, isExpanded, child) {
        return AnimatedCrossFade(
          firstChild: SizedBox.shrink(),
          secondChild: Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              doc.content ?? 'No description available',
              style: TextStyle(
                color: _colorScheme['secondary'],
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ),
          crossFadeState:
              isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: Duration(milliseconds: 300),
        );
      },
    );
  }

// Modify the _buildDocumentHeader method to include the expand/collapse button
  Widget _buildDocumentHeader(
      Document doc, ValueNotifier<bool> isExpandedNotifier) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _colorScheme['primary']!.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getFileTypeIcon(doc.fileType),
            color: _colorScheme['primary'],
            size: 30,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doc.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _colorScheme['secondary'],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      doc.departmentName,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              // Add expand/collapse button only if the document has content
              if (doc.content != null && doc.content!.isNotEmpty)
                ValueListenableBuilder<bool>(
                  valueListenable: isExpandedNotifier,
                  builder: (context, isExpanded, child) {
                    return IconButton(
                      icon: Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: _colorScheme['secondary'],
                      ),
                      onPressed: () {
                        isExpandedNotifier.value = !isExpanded;
                      },
                    );
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentActions(Document doc) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Icon(Icons.person_outline, color: Colors.grey, size: 18),
              SizedBox(width: 4),
              Text(
                doc.posterName,
                style: TextStyle(color: Colors.grey),
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(width: 16),
              Icon(Icons.calendar_today, color: Colors.grey, size: 18),
              SizedBox(width: 4),
              Text(
                _formatDate(doc.postDate),
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
        Row(
          children: [
            // Only show download button if documentUpload is not null
            if (doc.documentUpload != null)
              IconButton(
                icon: Icon(Icons.download_outlined,
                    color: Color(0xD94260D0)),
                onPressed: () => _downloadDocument(doc),
                tooltip: 'Download',
              ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

class _DownloadProgressDialog extends StatefulWidget {
  final String fileName;
  final Future<void> Function(void Function(double) progressCallback)
      onDownload;

  const _DownloadProgressDialog({
    required this.fileName,
    required this.onDownload,
  });

  @override
  _DownloadProgressDialogState createState() => _DownloadProgressDialogState();
}

class _DownloadProgressDialogState extends State<_DownloadProgressDialog> {
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _startDownload();
  }

  Future<void> _startDownload() async {
    try {
      await widget.onDownload((progress) {
        setState(() => _progress = progress);
      });
      Navigator.of(context).pop();
    } catch (e) {
      Navigator.of(context).pop(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Downloading ${widget.fileName}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 16),
            LinearProgressIndicator(value: _progress),
            SizedBox(height: 8),
            Text('${(_progress * 100).toInt()}%'),
          ],
        ),
      ),
    );
  }
}

//26/12/2024 slide left
class EnhancedPDFViewer extends StatefulWidget {
  final String filePath;

  const EnhancedPDFViewer({
    Key? key,
    required this.filePath,
  }) : super(key: key);

  @override
  State<EnhancedPDFViewer> createState() => _EnhancedPDFViewerState();
}

class _EnhancedPDFViewerState extends State<EnhancedPDFViewer> {
  int _currentPage = 0;
  int _totalPages = 0;
  bool _isLoading = true;
  double _loadingProgress = 0;
  PDFViewController? _controller;
  bool _isPageCountReady = false;

  void _showErrorSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PDFView(
            filePath: widget.filePath,
            enableSwipe: true,
            swipeHorizontal: true, // Changed to true for horizontal swiping
            autoSpacing: true,
            pageFling: true,
            pageSnap: true,
            defaultPage: _currentPage,
            onRender: (_pages) {
              setState(() {
                _isLoading = false;
                _isPageCountReady = true;
              });
            },
            onPageChanged: (page, total) {
              setState(() {
                _currentPage = page!;
                _totalPages = total!;
              });
            },
            onViewCreated: (PDFViewController controller) {
              _controller = controller;
            },
            onError: (error) {
              setState(() => _isLoading = false);
              _showErrorSnackbar('Error loading PDF: $error');
            },
            onPageError: (page, error) {
              _showErrorSnackbar('Error loading page $page: $error');
            },
          ),
          if (_isLoading)
            Container(
              color: Colors.white,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      'Loading PDF...',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ),
          if (_isPageCountReady && !_isLoading)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Page navigation buttons
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon:
                              const Icon(Icons.first_page, color: Colors.grey),
                          onPressed: _currentPage == 0
                              ? null
                              : () => _controller?.setPage(0),
                        ),
                        IconButton(
                          icon: const Icon(Icons.navigate_before,
                              color: Colors.grey),
                          onPressed: _currentPage == 0
                              ? null
                              : () => _controller?.setPage(_currentPage - 1),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Page ${_currentPage + 1} of $_totalPages',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.navigate_next,
                              color: Colors.grey),
                          onPressed: _currentPage >= _totalPages - 1
                              ? null
                              : () => _controller?.setPage(_currentPage + 1),
                        ),
                        IconButton(
                          icon: const Icon(Icons.last_page, color: Colors.grey),
                          onPressed: _currentPage >= _totalPages - 1
                              ? null
                              : () => _controller?.setPage(_totalPages - 1),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}




