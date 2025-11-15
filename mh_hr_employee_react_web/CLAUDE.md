# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

MH_HR Admin Portal - A full-stack web application for managing company administrative tasks including equipment requests, document management, leave applications, staff management, and training approvals. The application features role-based access control with multiple user tiers (user, department-admin, super-admin).

## Tech Stack

**Frontend (my-react/):**
- React 18 with Vite
- React Router DOM v6 for navigation
- Tailwind CSS + Material-UI for styling
- Axios for API communication
- Additional libraries: jsPDF, html2canvas, recharts, react-signature-canvas

**Backend:**
- .NET 8.0 ASP.NET Core Web API (located in mh_hr_employee_dotnet_backend/)
- API Endpoints: http://localhost:5000/admin/api (development) or https://realwebsite.com.my/admin/api (production)

## Development Commands

### Frontend (my-react/)
```bash
cd my-react
npm run dev          # Start development server (Vite)
npm run build        # Build for production
npm run lint         # Run ESLint
npm run preview      # Preview production build
```

Note: The root package.json has convenience scripts (`npm start` and `npm run build`) that run the my-react commands.

### Backend (.NET API)
See the monorepo root CLAUDE.md for backend setup instructions. The backend is located in `../mh_hr_employee_dotnet_backend/`.

## Architecture & Code Organization

### Authentication & Authorization

**Authentication Flow:**
1. User logs in via `LoginPage.jsx` which calls `login()` from `api.js`
2. JWT token is stored in localStorage and automatically attached to all API requests via axios interceptor (api.js:14-25)
3. Token validation happens on every request; 401 responses trigger automatic logout and redirect (api.js:27-41)
4. User data stored in localStorage as JSON

**Route Protection:**
- `ProtectedRoute.jsx` wraps all authenticated routes in `App.jsx`
- Checks for both `user` and `token` in localStorage
- Redirects to login page ("/") if either is missing

**Role-Based Access:**
Three user roles control feature access:
- `user`: Basic access (no staff management)
- `department-admin`: Department-level admin (no staff management)
- `super-admin`: Full system access

Role checks are implemented in individual components (e.g., `Sidebar.jsx:23-24`, `Sidebar.jsx:31-34`)

### API Communication (my-react/src/api.js)

**Central API Configuration:**
- Base URL: `http://localhost:5000/admin/api` (production)
- Alternate: `https://localhost:7280/admin/api` (commented out, local development)
- All API calls use `apiClient` (axios instance with interceptors)

**Request Interceptor:** Automatically adds Bearer token to all requests
**Response Interceptor:** Handles 401 errors by clearing auth and redirecting to login

**Key API Categories:**
- Authentication: `login()`, `changePassword()`, password change approval
- Equipment Management: requests, returns, categories, fixed assets
- **Document Management**: Each document type has dedicated backend endpoints:
  - `createMemo()`, `updateMemo()`, `fetchMemos()`, `deleteMemo()` → `/admin/api/Memo`
  - `createPolicy()`, `updatePolicy()`, `fetchPolicies()`, `deletePolicy()` → `/admin/api/Policy`
  - `createSOP()`, `updateSOP()`, `fetchSOPs()`, `deleteSOP()` → `/admin/api/SOP`
  - `createUpdates()`, `updateUpdates()`, `fetchUpdates()`, `deleteUpdates()` → `/admin/api/Updates`
  - Routing functions: `fetchDocuments()`, `deleteDocument()`, `downloadDocument()` handle type-based routing
  - All document operations use FormData for file uploads
- Leave Management: leave requests, medical leaves, calendar data, user entitlements
- Staff Management: CRUD operations on users, departments, roles, leave details
- Training Management: training records, status updates, certificate handling
- Signature Management: digital signatures for approvals

### Application Structure

**Main Entry Point:**
- `main.jsx` → `App.jsx` → React Router with protected routes
- Base route: `/app` (configured in Router, App.jsx:14)

**Core Pages (my-react/src/):**

1. **LoginPage.jsx**: Unauthenticated entry point with modern 2-column layout
   - Left column: Login form with email, password, and submit button
   - Right column: Large company logo (224x224px on desktop, 192x192px on mobile) with white background
   - Mobile view: Logo displays below login form
   - Features animated background, framer-motion animations
2. **EquipmentPage.jsx**: Equipment request management (route: `/main`)
3. **DocumentPage.jsx**: Document management with tabs (Memos, Policies, SOPs, Updates, Handbook, All Posted)
4. **ProfilePage.jsx**: User profile and settings
5. **RequestApproval.jsx**: Approval workflows for equipment requests, returns, password changes
6. **StaffPage.jsx**: Staff management (CRUD, leave entitlements, attendance, training)
7. **LeavePage.jsx**: Leave application and approval management

**Shared Components:**
- **ModernTopNav.jsx**: Top navigation bar with role-based menu items, theme toggle, and mobile responsive design
  - Located in `my-react/src/components/modern/ModernTopNav.jsx`
  - Uses logo from `images/logo_transparent.png`
  - Features: Menu items, dark/light theme toggle, profile dropdown, logout functionality
  - Note: Logo has white background to ensure visibility in dark mode
- **Sidebar.jsx**: (Legacy) Navigation sidebar with role-based menu items
  - Note: Currently not in use - replaced by ModernTopNav
- **ProtectedRoute.jsx**: Route guard component
- Multiple dialog components for modals (e.g., AddStaffDialog, MemoDialog, PolicyDialog, HandbookDialog, TrainingDetailsDialog)

**Specialized Components:**
- **ChangeRequest.jsx** / **ChangeReturn.jsx**: Equipment request/return workflows
- **LeaveApprovalTab.jsx**: Leave approval interface
- **LeaveCalendar.jsx**: Calendar view for leave tracking
- **LeaveReportButton.jsx**: Leave report generation
- **TrainingApproval.jsx**: Training approval workflow
- **AttendanceTab.jsx**: Attendance tracking
- **ChangePasswordTab.jsx**: Password management interface

### Data Flow Patterns

**Common Pattern:**
1. Component loads → calls API function from `api.js`
2. API function uses `apiClient` (includes auth token automatically)
3. Response data used to update component state
4. Errors handled locally or bubbled up

**File Upload Pattern (Documents):**
- Uses FormData with multipart/form-data
- Implemented in: `createMemo`, `updateMemo`, `createPolicy`, `updatePolicy`, `createSOP`, `updateSOP`, `createUpdates`, `updateUpdates`
- Pattern: Create FormData → append fields (Title, Content, DepartmentId, PostBy, File) → POST/PUT with Content-Type header
- Example:
  ```javascript
  const formData = new FormData();
  formData.append('Title', memoData.title);
  formData.append('Content', memoData.content);
  formData.append('DepartmentId', memoData.departmentId);
  formData.append('PostBy', memoData.userId);
  if (memoData.file) formData.append('File', memoData.file);
  await apiClient.post('/Memo', formData, { headers: { 'Content-Type': 'multipart/form-data' } });
  ```

**File Download Pattern:**
- Uses blob response type with content-type headers
- Creates temporary object URL → triggers download → cleans up URL
- Implemented in: `downloadDocument`, `fetchTrainingCertificate`

**Image Handling:**
- Array buffer to base64 conversion for handbook images
- Function: `arrayBufferToBase64` (api.js:342-350)
- Returns data URI for display

### Styling Approach

- Primary: Tailwind CSS utility classes with dark mode support
- Component-specific CSS files for complex layouts
- Material-UI components (@mui/material) for advanced UI elements
- Radix UI primitives for accessible components
- Color scheme: Purple/Pink gradients (primary), Green (success), Orange (warning), Red (error)
- **Dark Mode**: Implemented using Tailwind's `dark:` classes
  - Global dark mode toggle in ModernTopNav
  - Theme persisted via `document.documentElement.classList.toggle('dark')`
  - Status badges have specific dark mode styling with increased opacity and brighter text colors
  - All interactive elements support both light and dark themes

### State Management

- No global state management library (Redux, Zustand, etc.)
- Local component state with React hooks (useState, useEffect)
- User authentication state via localStorage
- API calls made directly from components

## Important Implementation Details

**Router Configuration:**
- Router basename is `/app` - all routes are prefixed with this
- Route structure: `/` → Login, `/main` → Equipment, `/document` → Documents, etc.

**Form Validation:**
- Mix of HTML5 validation (required attributes) and custom validation
- Error messages displayed via local state

**Signature Handling:**
- Uses react-signature-canvas for digital signatures
- Stored and retrieved via API for approval workflows

**Leave Management:**
- Supports both regular and medical leave types
- Includes calendar view, monthly tracking, and entitlement management
- Signature-based approval workflow

**Equipment Management:**
- Distinguishes between "Fixed Asset" (quantity always 1) and other categories
- Supports request and return workflows with approval states

**Document Management:**
- Five document types: MEMO, POLICY, SOP, UPDATES, Handbook
- Each type has dedicated dialog components (MemoDialog, PolicyDialog, SOPDialog, UpdatesDialog, HandbookDialog)
- Each type has dedicated backend endpoints for proper filtering
- Documents stored in single `documents` table with `Type` field differentiating types
- Documents can be filtered by department and type
- Document routing handled by `fetchDocuments()`, `deleteDocument()`, `downloadDocument()` based on activeTab

## Working with This Codebase

**When adding new features:**
1. Add API functions to `api.js` using `apiClient`
2. Create component in `my-react/src/`
3. Add route in `App.jsx` wrapped with `ProtectedRoute` if needed
4. Add navigation link to `Sidebar.jsx` if applicable
5. Implement role checks if feature is role-restricted

**When modifying API endpoints:**
- Update the corresponding function in `api.js`
- Maintain error handling pattern with try-catch and console.error
- Keep response interceptor logic for 401 handling

**When adding new user roles:**
- Update role checks in `Sidebar.jsx`, page components
- Update `validateSuperAdmin` logic if needed
- Consider impact on ProtectedRoute logic

**File Structure Conventions:**
- Page components: PascalCase.jsx
- Supporting components: Dialog/Modal suffixes
- Styles: matching .css files with same base name
- Assets: stored in `my-react/src/images/` and `my-react/src/document/`

## Recent Updates & Changes

### UI/UX Improvements (Latest)
1. **Modern Top Navigation**: Replaced sidebar with horizontal top navigation bar
   - Always visible at top of screen
   - Includes theme toggle for dark/light mode
   - Profile menu with logout functionality
   - Mobile responsive with collapsible menu

2. **Dark Mode Implementation**:
   - Full dark theme support across all pages
   - Status badges: Enhanced visibility with darker backgrounds (opacity 0.3) and brighter text colors
   - Leave approval, staff management, leave management status badges all optimized
   - Leave calendar week bar: Lighter background with dark text in dark mode
   - All text elements have proper contrast in dark theme

3. **Login Page Redesign**:
   - 2-column layout: Login form on left, logo on right
   - Large logo display (224x224px) with white background for visibility
   - Mobile responsive: Logo appears below form on small screens
   - Consistent styling with main application theme

4. **Logo Visibility Fixes**:
   - Top navigation logo: White background in dark mode
   - Login page logo: White background container
   - Ensures dark logos are always visible regardless of theme

## Known Issues & Fixes

### Department Dropdown in AddStaffDialog
**Issue**: Department dropdown must use `dept.id` as the value, not `dept.name`
**Location**: `AddStaffDialog.jsx:319`
**Correct Implementation**:
```jsx
<option key={dept.id} value={dept.id}>
  {dept.name}
</option>
```
**Reason**: The `departmentId` field expects an integer ID. Using `dept.name` causes validation errors because `parseInt()` cannot parse department names like "HR" or "IT".

### JSON Case Sensitivity
**Backend Configuration**: The backend now accepts both camelCase (frontend) and PascalCase (backend) property names via `PropertyNameCaseInsensitive = true` in Program.cs
**Frontend**: Uses camelCase (fullName, departmentId, dateJoined)
**Backend DTOs**: Uses PascalCase (FullName, DepartmentId, DateJoined)
**Result**: Seamless communication without manual case conversion

## Database Connection

The React web application connects to the .NET backend API, which uses SQL Server:
- Development API: http://localhost:5000/admin/api (configured in `.env.development`)
- Production API: https://realwebsite.com.my/admin/api (configured in `.env.production`)

Database configuration is managed in the backend project (`../mh_hr_employee_dotnet_backend/appsettings.json`).
