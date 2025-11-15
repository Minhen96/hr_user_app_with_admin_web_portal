class AppConstants {
  // App Info
  static const String appName = 'MH Employee App';
  static const String appVersion = '1.0.0';

  // File Upload
  static const int maxFileSize = 10 * 1024 * 1024; // 10 MB
  static const List<String> allowedImageExtensions = ['jpg', 'jpeg', 'png', 'gif'];
  static const List<String> allowedDocumentExtensions = ['pdf', 'doc', 'docx'];

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Cache Duration
  static const Duration cacheShortDuration = Duration(minutes: 5);
  static const Duration cacheMediumDuration = Duration(hours: 1);
  static const Duration cacheLongDuration = Duration(days: 1);

  // Animation Duration
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Equipment Categories
  static const String fixedAssetCategory = 'Fixed Asset';

  // Document Types
  static const String memoType = 'MEMO';
  static const String policyType = 'POLICY';
  static const String sopType = 'SOP';
  static const String updatesType = 'UPDATES';
  static const String handbookType = 'Handbook';

  // Leave Types
  static const String annualLeaveType = 'Annual Leave';
  static const String medicalLeaveType = 'Medical Leave';
  static const String emergencyLeaveType = 'Emergency Leave';

  // Date Formats
  static const String displayDateFormat = 'dd MMM yyyy';
  static const String displayDateTimeFormat = 'dd MMM yyyy, hh:mm a';
  static const String apiDateFormat = 'yyyy-MM-dd';
  static const String apiDateTimeFormat = "yyyy-MM-dd'T'HH:mm:ss";

  // Validation
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 50;
  static const int minNameLength = 2;
  static const int maxNameLength = 100;

  // Splash Screen
  static const Duration splashDuration = Duration(seconds: 3);

  // Token Refresh Interval
  static const Duration tokenRefreshInterval = Duration(minutes: 15);
}

