# MH HR Employee Mobile App

A modern Flutter mobile application for employees to manage HR tasks, documents, leave, equipment, training, and more.

## Tech Stack

- **Flutter**: 3.5.4+
- **State Management**: Provider + MobX
- **Storage**: flutter_secure_storage (JWT), shared_preferences (user data)
- **HTTP**: http package with Bearer token authentication
- **Notifications**: Firebase Cloud Messaging
- **UI Libraries**: flutter_animate, table_calendar, syncfusion_flutter_pdfviewer

## Quick Start

```bash
# Install dependencies
flutter pub get

# Run on connected device/emulator
flutter run

# Static analysis
flutter analyze

# Build for production
flutter build apk                        # Android
flutter build ios                        # iOS (macOS only)
```

## Project Structure

```
lib/
├── core/
│   ├── theme/                          # AppColors, design tokens
│   ├── widgets/                        # Shared widgets (ModernGlassCard, ModernLoading, etc.)
│   └── services/                       # Core services
├── features/
│   ├── auth/                           # Authentication
│   ├── home/                           # Dashboard
│   ├── documents/                      # Documents (Memos, Policies, SOPs, Updates)
│   ├── equipment/                      # Equipment requests
│   ├── leave/                          # Leave applications
│   ├── training/                       # Training records
│   ├── moments/                        # Social feed
│   ├── profile/                        # User profile
│   └── handbook/                       # Employee handbook
├── shared/
│   ├── screens/                        # Shared screens
│   └── widgets/                        # Shared widgets
└── services/
    └── api_service.dart                # Backend API integration
```

## Design System

### Modern Purple Gradient Theme

The app features a modern, cohesive design with:

**Color Scheme:**
- **Primary**: Purple gradient (`AppColors.gradientPurple`)
- **Success**: Green gradient `[Color(0xFF10B981), Color(0xFF059669)]`
- **Warning**: Orange gradient `[Color(0xFFF59E0B), Color(0xFFD97706)]`
- **Error**: Red gradient `[Color(0xFFEF4444), Color(0xFFDC2626)]`
- **Dark/Light Mode**: Full theme-aware support

**Components:**
- `ModernGlassCard` - Glassmorphism cards with subtle gradients
- `ModernLoading` - Animated loading indicator
- `ModernGradientButton` - Gradient buttons with shadows
- Entrance animations using flutter_animate

**Conventions:**
- Always check theme: `final isDark = Theme.of(context).brightness == Brightness.dark;`
- Use theme-aware colors: `isDark ? AppColors.darkTextPrimary : AppColors.textPrimary`
- Add animations to list items: `.animate(delay: (index * 50).ms).fadeIn().slideY(begin: 0.1, end: 0)`
- Use gradients for primary actions and status indicators

## Key Features

### Authentication
- JWT token-based authentication
- Secure token storage via flutter_secure_storage
- Auto-refresh every 15 minutes
- Auto-logout on token expiry

### Documents
- View and download company documents (Memos, Policies, SOPs, Updates)
- Company updates with pagination
- PDF viewer with syncfusion_flutter_pdfviewer
- Read tracking

### Equipment Management
- Request equipment with digital signature
- View approved requests
- Request history with filters (All, Pending, Approved, Rejected)
- Mark items as received

### Leave Management
- Apply for annual leave and medical leave
- View leave balance and calendar
- Leave application history
- Attachment support for medical certificates

### Training
- View training courses
- Upload certificates
- Training history

### Other Features
- Employee handbook (company info + documents)
- Social moments feed
- Birthday calendar
- Event calendar
- Attendance tracking
- Profile management
- Push notifications via FCM

## API Integration

The app connects to the .NET backend API:

```dart
// lib/services/api_service.dart
static const String baseUrl = 'YOUR_API_URL';

// Example API call
static Future<List<Document>> getDocuments({
  required String type,
  int page = 1,
}) async {
  final token = await _getToken();
  final response = await http.get(
    Uri.parse('$baseUrl/api/Documents?type=$type&page=$page'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  ).timeout(const Duration(seconds: 10));

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return PaginatedResponse<Document>.fromJson(
      data,
      (json) => Document.fromJson(json),
    );
  } else {
    throw Exception('Failed to load documents');
  }
}
```

## Firebase Setup

### Android
1. Add `google-services.json` to `android/app/`
2. Update `android/app/build.gradle` with applicationId
3. Enable Firebase Cloud Messaging in Firebase Console

### iOS
1. Add `GoogleService-Info.plist` to `ios/Runner/`
2. Update `ios/Runner/Info.plist` with required permissions
3. Enable Push Notifications in Xcode

## Building for Production

### Android
```bash
flutter build apk --release              # APK
flutter build appbundle --release        # App Bundle (for Play Store)
```

### iOS
```bash
flutter build ios --release
# Then open ios/Runner.xcworkspace in Xcode to archive
```

## Development Guidelines

### Adding a New Screen

1. Create screen in appropriate feature folder:
   ```dart
   // lib/features/my_feature/presentation/screens/my_screen.dart
   class MyScreen extends StatefulWidget {
     const MyScreen({Key? key}) : super(key: key);
   }
   ```

2. Use modern design patterns:
   - `ModernGlassCard` for containers
   - Purple gradient for primary actions
   - Theme-aware colors throughout
   - Entrance animations for list items

3. Add to navigation in `home_screen_new.dart`

### API Service Pattern

```dart
// Add new method to lib/services/api_service.dart
static Future<MyModel> getMyData() async {
  final token = await _getToken();
  final response = await http.get(
    Uri.parse('$baseUrl/api/MyEndpoint'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  ).timeout(const Duration(seconds: 10));

  if (response.statusCode == 200) {
    return MyModel.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to load data');
  }
}
```

## Testing

```bash
# Run tests
flutter test

# Static analysis
flutter analyze

# Check for issues
flutter doctor
```

## Common Issues

### iOS Build Errors
- Run `pod install` in `ios/` directory
- Clean build: `flutter clean && flutter pub get`
- Update CocoaPods: `sudo gem install cocoapods`

### Android Build Errors
- Update `android/app/build.gradle` minSdkVersion to 21+
- Clean Gradle cache: `cd android && ./gradlew clean`

### Firebase Not Working
- Verify `google-services.json` (Android) or `GoogleService-Info.plist` (iOS) is in correct location
- Check package name matches Firebase project
- Enable required Firebase services in console

## License

Proprietary - MH HR Employee Management System
