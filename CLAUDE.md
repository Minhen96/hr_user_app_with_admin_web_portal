# CLAUDE.md

This file provides guidance to Claude Code when working with the MH HR Employee Management System.

## Monorepo Overview

This monorepo contains three interconnected projects:

1. **mh_hr_employee_dotnet_backend/** - .NET 8.0 ASP.NET Core Web API backend
2. **mh_hr_employee_react_web/** - React web admin portal
3. **mh_employee_flutter_app/** - Flutter mobile application for employees

All three applications connect to the same .NET backend API.

## Quick Start Commands

### Backend (.NET API)
```bash
cd mh_hr_employee_dotnet_backend
dotnet restore
dotnet build React.sln
dotnet run --project React.csproj        # Runs on ports 5000/7106
```

### Web Admin Portal (React)
```bash
cd mh_hr_employee_react_web/my-react
npm install
npm run dev                              # Start Vite dev server
npm run build                            # Build for production
```

### Mobile App (Flutter)
```bash
cd mh_employee_flutter_app
flutter pub get
flutter run                              # Run on connected device/emulator
flutter analyze                          # Static analysis
```

## Architecture Overview

### Backend (.NET)
- **Clean Architecture**: API/ → Application/ → Core/ → Infrastructure/ → Data/
- **Authentication**: JWT Bearer tokens (SHA256 password hashing)
- **Database**: SQL Server with multiple DbContexts:
  - `AppDbContext` - Main entities (users, documents, equipment, training, moments)
  - `AnnualLeaveContext` - Leave management
  - `AttendanceContext` - Attendance records
  - `Mc_leaveDB` - Medical leave

**API Routes:**
- Legacy: `/admin/api/[controller]`
- Modern: `/api/[controller]` and `/admin/api/[controller]`
- Swagger: Available at `/` in development

**Document Types:**
- MEMO (`/admin/api/Memo`)
- POLICY (`/admin/api/Policy`)
- SOP (`/admin/api/SOP`)
- UPDATES (`/admin/api/Updates`)

### Web Admin (React)
- **Tech Stack**: React 18 + Vite + Tailwind CSS + Material-UI
- **State**: Local component state (no Redux)
- **API**: Axios with automatic JWT token injection
- **Auth**: JWT stored in localStorage, auto-logout on 401

**Key Pages:**
- `/main` - Equipment requests
- `/document` - Documents (Memos, Policies, SOPs, Updates)
- `/staff` - Staff management
- `/leave` - Leave applications

**Roles:**
- `user` - Basic access
- `department-admin` - Department admin
- `super-admin` - Full system access

### Mobile App (Flutter)
- **Tech Stack**: Flutter 3.5.4+ with Dart
- **State**: Provider + MobX
- **Storage**: flutter_secure_storage (JWT), shared_preferences (user data)
- **Theme**: Modern purple gradient design with dark/light mode support

**Design System:**
- **Colors**: Purple gradient (`AppColors.gradientPurple`), theme-aware text colors
- **Cards**: `ModernGlassCard` with subtle gradient backgrounds
- **Buttons**: Gradient buttons with shadows
- **Loading**: `ModernLoading` component
- **Animations**: flutter_animate for entrance animations

**Key Screens:**
- `home_screen_new.dart` - Main dashboard
- `equipment_screen_new.dart` - Equipment management (tabs: Request, Approved, History)
- `document_screen.dart` - Documents with modern pill-style tabs
- `company_updates_screen.dart` - Company updates list
- `handbook_screen_new.dart` - Employee handbook
- `profile_screen_new.dart` - User profile

**Widget Locations:**
- Shared screens: `lib/shared/screens/`
- Feature screens: `lib/features/[feature]/presentation/screens/`
- Shared widgets: `lib/shared/widgets/`
- Core widgets: `lib/core/widgets/`

## Common Development Tasks

### Adding a New Flutter Screen

1. Create screen file in appropriate location:
   ```dart
   // lib/features/[feature]/presentation/screens/my_screen.dart
   import 'package:flutter/material.dart';
   import 'package:mh_employee_app/core/theme/app_colors.dart';
   import 'package:mh_employee_app/shared/widgets/modern_glass_card.dart';

   class MyScreen extends StatefulWidget {
     const MyScreen({Key? key}) : super(key: key);

     @override
     State<MyScreen> createState() => _MyScreenState();
   }

   class _MyScreenState extends State<MyScreen> {
     @override
     Widget build(BuildContext context) {
       final isDark = Theme.of(context).brightness == Brightness.dark;

       return Scaffold(
         backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
         body: // Your content
       );
     }
   }
   ```

2. Use modern design patterns:
   - `ModernGlassCard` for containers
   - Purple gradient for primary actions: `AppColors.gradientPurple`
   - Green gradient for success: `[Color(0xFF10B981), Color(0xFF059669)]`
   - Theme-aware colors: `isDark ? AppColors.darkTextPrimary : AppColors.textPrimary`
   - Animations: `.animate().fadeIn().slideY(begin: 0.1, end: 0)`

### Working with API Service

Add methods to `lib/services/api_service.dart`:

```dart
static Future<List<MyModel>> getMyData() async {
  final token = await _getToken();
  final response = await http.get(
    Uri.parse('$baseUrl/api/MyEndpoint'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  ).timeout(const Duration(seconds: 10));

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data.map((json) => MyModel.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load data');
  }
}
```

### Document Management

**Backend Controllers:**
- All document types use shared DTOs: `CreateMemoDto`, `MarkReadDto`
- Documents stored in single `documents` table with `Type` field

**Mobile App:**
- Main documents screen: `document_screen.dart` with pill-style tabs
- Company updates screen: `company_updates_screen.dart` (independent list)
- Document detail: `document_detail_screen.dart` with type-specific gradients

### Equipment Management

**Mobile App Structure:**
- Main screen: `equipment_screen_new.dart` with 3 tabs
  - Request tab: `request_screen.dart` - Create new requests
  - Approved tab: `approved_screen.dart` - Mark as received
  - History tab: `history_screen.dart` - View all requests with filters

**Design Pattern:**
- Green gradient for approved items
- Orange gradient for pending items
- Red gradient for rejected items
- Modern dialogs with gradient headers
- Status chips with gradient backgrounds

## Important Conventions

### Flutter Code Style
- Always use theme-aware colors (`isDark` check)
- Add entrance animations to list items: `.animate(delay: (index * 50).ms)`
- Use `ModernGlassCard` instead of plain containers
- Apply gradient styling to primary buttons
- Include proper dark/light mode support in all new screens

### Authentication
- **Backend**: JWT tokens via `LoginController`
- **Web**: localStorage with axios interceptors
- **Mobile**: flutter_secure_storage + token refresh every 15 minutes

### File Uploads
- **Backend**: Saves to `wwwroot/uploads/certificates/` (10MB limit)
- **Web**: FormData API
- **Mobile**: file_picker + MultipartRequest

## Security Notes

- Never commit: `appsettings.json`, Firebase keys, `.env` files
- JWT keys must be minimum 32 characters
- Use HTTPS in production
- Database credentials should be environment variables

## Testing

```bash
# Backend
cd mh_hr_employee_dotnet_backend && dotnet test

# Web Admin
cd mh_hr_employee_react_web/my-react && npm run lint

# Mobile App
cd mh_employee_flutter_app && flutter analyze
```

## Recent Updates

### Mobile App Modern Redesign (Latest)
- Redesigned all equipment screens (Request, Approved, History) with purple/green gradient theme
- Updated company updates to independent screen with pagination
- Modernized signature pad with gradient styling
- Improved document screen with pill-style tabs
- Enhanced home page text contrast for better readability
- Reordered handbook (company info first, then documents)
- Updated moment creation and training dialogs to match theme

### Backend
- JSON case-insensitive deserialization enabled
- Document controllers for all types (Memo, Policy, SOP, Updates)
- Shared DTOs to avoid code duplication

### Web Admin
- Department ID fix in staff creation
- Centralized document routing functions
