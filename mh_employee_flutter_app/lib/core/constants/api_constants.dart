class ApiConstants {
  // Base URLs
  static const String baseUrl = 'http://localhost:5000/api';
  static const String baseAdminUrl = 'http://localhost:5000/admin/api';

  // Timeout
  static const Duration timeout = Duration(seconds: 10);

  // Authentication Endpoints
  static const String login = '/Auth/login';
  static const String logout = '/logout';
  static const String refreshToken = '/refresh-token';
  static const String profile = '/Auth/profile';
  static const String changePassword = '/Auth/change-password';
  static const String updateNickname = '/Auth/update-nickname';
  static const String uploadProfilePicture = '/Auth/upload-profile-picture';
  static const String requestPasswordChange = '/Auth/request-password-change';
  static const String register = '/Auth/register';
  static const String userStatus = '/Auth/status';
  static const String nickname = '/Auth/nickname';

  // Attendance Endpoints (Admin)
  static const String attendanceTimeIn = '/Attendance/TimeIn';
  static const String attendanceTimeOut = '/Attendance/TimeOut';
  static const String attendanceCurrentDay = '/Attendance/CurrentDaySubmissions';
  static const String attendanceMonthly = '/Attendance/MonthlyAttendance';

  // Equipment Endpoints (Admin)
  static const String equipmentRequests = '/EquipmentRequests';
  static const String equipmentReceived = '/EquipmentRequests';

  // Training Endpoints (Admin)
  static const String trainings = '/Trainings';
  static const String trainingCertificate = '/Trainings/certificate';

  // Handbook Endpoints (Admin)
  static const String handbookUserGuide = '/Handbook/userguide';
  static const String handbookSections = '/Handbook';
  static const String handbookSection = '/Handbook';

  // Calendar & Events Endpoints (Admin)
  static const String birthday = '/Birthday';
  static const String holiday = '/Holiday';

  // Events Endpoints (User)
  static const String events = '/Events';
  static const String eventsAll = '/Events/all';
  static const String eventsMonth = '/Events/month';
  static const String eventMarkRead = '/Events';
  static const String eventReadStatus = '/Events';

  // Leave Endpoints (User)
  static const String leave = '/Leave';
  static const String leaveSubmit = '/Leave/submit';
  static const String leaveEntitlement = '/Leave/entitlement';
  static const String leavePending = '/Leave/ANLpending-leaves';
  static const String leaveApproved = '/Leave/ANLapprove-leaves';
  static const String leaveUpdate = '/Leave/update';
  static const String leaveDelete = '/Leave/delete';
  static const String leaveCalendar = '/LeaveCalendar';

  // Medical Certificate Leave Endpoints (User)
  static const String mcPendingLeaves = '/Mc_Pending_/pending-leaves';
  static const String mcApprovedLeaves = '/Mc_Pending_/approved-leaves';

  // Change Requests Endpoints (User)
  static const String changeRequests = '/ChangeRequests';
  static const String changeRequestSignature = '/ChangeRequests/signature';
  static const String changeRequestReturn = '/ChangeRequests/return';
  static const String changeRequestUser = '/ChangeRequests/user';

  // Moments Endpoints (User)
  static const String moments = '/moments';
  static const String momentsReactions = '/moments';
  static const String momentsReports = '/moments';
  static const String momentsUploadImage = '/moments/upload-moment-image';

  // Quote Endpoints (User)
  static const String quote = '/Quote';
  static const String quoteCarousel = '/Quote/carousel-content';
  static const String quoteViews = '/Quote';
  static const String quoteReactions = '/Quote';
  static const String quoteView = '/Quote';
  static const String quoteAutoView = '/Quote';
  static const String quoteReaction = '/Quote';

  // Documents Endpoints (User)
  static const String documents = '/Document';
  static const String documentsUpdates = '/Document/updates';
  static const String documentsUnreadCount = '/Document/updates/unread-count';
  static const String documentsMarkRead = '/Document/updates';
  static const String documentMarkRead = '/Document';
  static const String documentDownload = '/Document';
  static const String documentUnreadCounts = '/Document/unread-counts';

  // Notifications
  static const String registerFcmToken = '/notifications/register-token';
}

