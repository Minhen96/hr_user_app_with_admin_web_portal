# MH HR Employee Backend API Documentation

**Base URL**: `http://localhost:5000/admin/api`

**Server Status**: ✅ Running on Port 5000

**Last Updated**: 2025-10-22

---

## Table of Contents
- [Authentication](#authentication)
- [Users Management](#users-management)
- [Staff Management](#staff-management)
- [Department Management](#department-management)
- [Documents Management](#documents-management)
  - [Memo](#memo)
  - [Policy](#policy)
  - [SOP](#sop)
  - [Updates](#updates)
  - [Handbook](#handbook)
- [Leave Management](#leave-management)
- [Holiday Management](#holiday-management)
- [Attendance](#attendance)
- [Training](#training)
- [Equipment Management](#equipment-management)
- [Change Requests](#change-requests)
- [Notifications](#notifications)
- [Birthday](#birthday)
- [Events](#events)

---

## Authentication

### Auth Controller
Base: `/admin/api/Auth`

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/login` | User login |
| POST | `/change-password` | Change user password |

---

## Users Management

### Users Controller
Base: `/admin/api/users`

| Method | Endpoint | Description | Request Body |
|--------|----------|-------------|--------------|
| GET | `/` | Get all users | - |
| POST | `/` | Create new user | `CreateUserDto` |
| PUT | `/{id}` | Update user | `UpdateUserDto` |
| DELETE | `/{id}` | Delete user | - |
| GET | `/departments` | Get all departments | - |
| GET | `/roles` | Get all roles (user, department-admin, super-admin) | - |
| PUT | `/{userId}/toggle-status` | Toggle user active/inactive status | - |
| GET | `/password-changes` | Get pending password change requests | - |

#### CreateUserDto
```json
{
  "fullName": "string",
  "email": "string",
  "password": "string",
  "nric": "string",
  "tin": "string (optional)",
  "epfNo": "string (optional)",
  "departmentId": "int",
  "role": "string (user/department-admin/super-admin)",
  "birthday": "datetime",
  "dateJoined": "datetime",
  "contactNumber": "string (optional)"
}
```

#### UpdateUserDto
```json
{
  "fullName": "string",
  "email": "string",
  "password": "string (optional)",
  "nric": "string",
  "tin": "string (optional)",
  "epfNo": "string (optional)",
  "departmentId": "int",
  "role": "string",
  "birthday": "datetime",
  "dateJoined": "datetime",
  "contactNumber": "string (optional)"
}
```

---

## Staff Management

### Staff Controller
Base: `/admin/api/staff`

| Method | Endpoint | Description | Request Body |
|--------|----------|-------------|--------------|
| GET | `/` | Get all staff | - |
| GET | `/{userId}/leave-details` | Get staff leave details | - |
| PUT | `/{userId}/leave-entitlement` | Update leave entitlement | `UpdateEntitlementDto` |

#### UpdateEntitlementDto
```json
{
  "entitlement": "int"
}
```

---

## Department Management

### Department Controller
Base: `/admin/api/Department`

| Method | Endpoint | Description | Request Body |
|--------|----------|-------------|--------------|
| GET | `/` | Get all departments | - |
| GET | `/{id}` | Get department by ID | - |
| POST | `/` | Create new department | `DepartmentDto` |
| PUT | `/{id}` | Update department | `DepartmentDto` |
| DELETE | `/{id}` | Delete department | - |

#### DepartmentDto
```json
{
  "name": "string"
}
```

---

## Documents Management

### Documents Controller
Base: `/admin/api/Documents`

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/create` | Create document (any type) |
| GET | `/{id}` | Get document by ID |
| GET | `/` | Get all documents |
| GET | `/departments` | Get all departments |

---

### Memo

#### Memo Controller
Base: `/admin/api/Memo`

| Method | Endpoint | Description | Request Type |
|--------|----------|-------------|--------------|
| GET | `/` | Get all memos | - |
| GET | `/{id}` | Get memo by ID | - |
| POST | `/` | Create new memo | `multipart/form-data` |
| PUT | `/{id}` | Update memo | `multipart/form-data` |
| DELETE | `/{id}` | Delete memo | - |
| GET | `/{id}/download` | Download memo file | - |
| POST | `/{id}/mark-read` | Mark memo as read | `MarkReadDto` |

#### CreateMemoDto (Form Data)
- `Title` (string, required)
- `Content` (string, optional)
- `DepartmentId` (int, required)
- `PostBy` (int, required)
- `File` (IFormFile, optional)

#### MarkReadDto
```json
{
  "userId": "int"
}
```

---

### Policy

#### Policy Controller
Base: `/admin/api/Policy`

| Method | Endpoint | Description | Request Type |
|--------|----------|-------------|--------------|
| GET | `/` | Get all policies | - |
| GET | `/{id}` | Get policy by ID | - |
| POST | `/` | Create new policy | `multipart/form-data` |
| PUT | `/{id}` | Update policy | `multipart/form-data` |
| DELETE | `/{id}` | Delete policy | - |
| GET | `/{id}/download` | Download policy file | - |
| POST | `/{id}/mark-read` | Mark policy as read | `MarkReadDto` |

**Note**: Uses same DTO structure as Memo (`CreateMemoDto`, `MarkReadDto`)

---

### SOP

#### SOP Controller
Base: `/admin/api/SOP`

| Method | Endpoint | Description | Request Type |
|--------|----------|-------------|--------------|
| GET | `/` | Get all SOPs | - |
| GET | `/{id}` | Get SOP by ID | - |
| POST | `/` | Create new SOP | `multipart/form-data` |
| PUT | `/{id}` | Update SOP | `multipart/form-data` |
| DELETE | `/{id}` | Delete SOP | - |
| GET | `/{id}/download` | Download SOP file | - |
| POST | `/{id}/mark-read` | Mark SOP as read | `MarkReadDto` |

**Note**: Uses same DTO structure as Memo (`CreateMemoDto`, `MarkReadDto`)

---

### Updates

#### Updates Controller
Base: `/admin/api/Updates`

| Method | Endpoint | Description | Request Type |
|--------|----------|-------------|--------------|
| GET | `/` | Get all updates | - |
| GET | `/{id}` | Get update by ID | - |
| POST | `/` | Create new update | `multipart/form-data` |
| PUT | `/{id}` | Update update | `multipart/form-data` |
| DELETE | `/{id}` | Delete update | - |
| GET | `/{id}/download` | Download update file | - |
| POST | `/{id}/mark-read` | Mark update as read | `MarkReadDto` |

**Note**: Uses same DTO structure as Memo (`CreateMemoDto`, `MarkReadDto`)

---

### Handbook

#### Handbook Controller
Base: `/admin/api/Handbook`

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/` | Get all sections |
| GET | `/userguide` | Get user guide PDF |
| GET | `/{id}` | Get section by ID |
| GET | `/content/{sectionId}` | Get section content |

---

## Leave Management

### Leaves Controller
Base: `/admin/api/Leaves`

| Method | Endpoint | Description | Request Body |
|--------|----------|-------------|--------------|
| GET | `/` | Get all leaves | - |
| GET | `/medical` | Get all medical leaves | - |
| POST | `/` | Create leave request | `SubmitLeaveRequestDto` |
| PUT | `/{id}/status` | Update leave status | `LeaveStatusUpdateDto` |
| PUT | `/medical/{id}/status` | Update medical leave status | `LeaveStatusUpdateDto` |
| GET | `/calendar` | Get calendar data | Query: startDate, endDate |

---

### Leave Controller (Holiday Specific)
Base: `/admin/api/Leave`

| Method | Endpoint | Description | Request Body |
|--------|----------|-------------|--------------|
| GET | `/holidays` | Get holidays | Query: year, month |
| POST | `/holidays` | Add new holiday | `AddHolidayDto` |
| PUT | `/holidays/{id}` | Update holiday | `AddHolidayDto` |
| DELETE | `/holidays/{id}` | Delete holiday | - |

#### AddHolidayDto
```json
{
  "holidayName": "string",
  "holidayDate": "datetime"
}
```

---

## Holiday Management

### Holiday Controller
Base: `/admin/api/Holiday`

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/` | Get holidays by year/month |
| GET | `/all` | Get all holidays (current + next year) |
| POST | `/` | Add holiday |
| PUT | `/{id}` | Update holiday |
| DELETE | `/{id}` | Delete holiday |

---

## Attendance

### Attendance Controller
Base: `/admin/api/Attendance`

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/{userId}` | Get attendance for user |
| POST | `/` | Submit attendance |

---

## Training

### Trainings Controller
Base: `/admin/api/Trainings`

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/` | Get all trainings |
| GET | `/{id}` | Get training by ID |
| POST | `/` | Create training |
| PUT | `/{id}` | Update training |
| DELETE | `/{id}` | Delete training |
| PUT | `/{id}/status` | Update training status |

---

## Equipment Management

### Equipment Request Controller
Base: `/admin/api/EquipmentRequest`

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/` | Get all equipment requests |
| GET | `/{id}` | Get equipment request by ID |
| POST | `/` | Create equipment request |
| PUT | `/{id}` | Update equipment request |
| PUT | `/{id}/status` | Update request status |

### Equipment Returns Controller
Base: `/admin/api/EquipmentReturns`

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/` | Get all equipment returns |
| POST | `/` | Create equipment return |

---

## Change Requests

### Change Requests Controller
Base: `/admin/api/ChangeRequests`

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/` | Get all change requests |
| GET | `/{id}` | Get change request by ID |
| POST | `/` | Create change request |
| PUT | `/{id}/status` | Update request status |

### Change Returns Controller
Base: `/admin/api/ChangeReturns`

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/` | Get all change returns |
| POST | `/` | Create change return |

---

## Notifications

### Notification Controller
Base: `/admin/api/Notification`

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/send` | Send notification to user |
| POST | `/send-all` | Send notification to all users |

---

## Birthday

### Birthday Controller
Base: `/admin/api/Birthday`

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/today` | Get today's birthdays |
| GET | `/month` | Get this month's birthdays |

---

## Events

### UserEvents Controller
Base: `/api/Events`

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/` | Get all events |
| GET | `/{id}` | Get event by ID |
| POST | `/` | Create event |
| PUT | `/{id}` | Update event |
| DELETE | `/{id}` | Delete event |

---

## Email

### Email Controller
Base: `/admin/api/Email`

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/send` | Send email |

---

## Medical Certificate Leave

### MC Controller
Base: `/admin/api/Mc`

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/` | Get all MC leaves |
| GET | `/{id}` | Get MC leave by ID |
| POST | `/` | Submit MC leave |
| PUT | `/{id}/status` | Update MC leave status |

### MC Pending Controller
Base: `/admin/api/Mc_Pending`

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/` | Get pending MC leaves |
| PUT | `/{id}/approve` | Approve MC leave |
| PUT | `/{id}/reject` | Reject MC leave |

---

## Leave Report

### Leave Report Controller
Base: `/admin/api/LeaveReport`

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/generate` | Generate leave report |
| GET | `/export` | Export leave report |

---

## User-Specific APIs (Mobile App)

### User Auth Controller
Base: `/api/UserAuth`

Similar to Auth but for mobile app users.

### User Documents Controller
Base: `/api/Document`

User-facing document APIs with read tracking.

### User Leave Controller
Base: `/api/Leave`

User-facing leave management APIs.

### User Change Requests Controller
Base: `/api/ChangeRequest`

User-facing change request APIs.

### User Moments Controller
Base: `/api/Moments`

Social feed/moments management for users.

---

## Common Response Formats

### Success Response
```json
{
  "success": true,
  "message": "Operation successful",
  "data": {}
}
```

### Error Response
```json
{
  "success": false,
  "message": "Error message",
  "error": "Detailed error"
}
```

---

## Authentication

Most endpoints require JWT Bearer token authentication:

```
Authorization: Bearer <your-jwt-token>
```

Token is obtained from `/admin/api/Auth/login` endpoint.

---

## Notes

1. **Password Hashing**: All passwords are hashed using SHA256 before storage
2. **File Uploads**: Document files are stored as binary data (byte[]) in the database
3. **File Types**: Supported file types include PDF, DOC, DOCX, JPG, PNG, etc.
4. **Date Format**: All dates should be in ISO 8601 format
5. **Active Status**: Users have `active_status` field ("active"/"inactive")
6. **Status**: Users have `status` field ("pending"/"approved"/"rejected")

---

## Database Models

### Key Models

- **User**: Full user information with authentication
- **Department**: Department/team structure
- **Document**: Generic document model (MEMO, POLICY, SOP, UPDATES, Handbook)
- **DocumentRead**: Tracks which users have read which documents
- **AnnualLeave**: Annual leave records
- **LeaveDetail**: Detailed leave information
- **MC_Leave**: Medical certificate leave
- **Attendance**: Attendance records
- **TrainingCourse**: Training courses
- **Certificate**: Training certificates
- **EquipmentRequest**: Equipment requests
- **ChangeRequest**: Change requests
- **Holiday**: Public holidays
- **Event**: Company events
- **Moment**: Social feed posts

---

## All Fixed Endpoints (New/Updated)

✅ `/admin/api/users/departments` - Get departments list
✅ `/admin/api/users/roles` - Get roles list
✅ `/admin/api/users/{id}/toggle-status` - Toggle user status
✅ `/admin/api/users` POST - Create user
✅ `/admin/api/users/{id}` PUT - Update user
✅ `/admin/api/users/{id}` DELETE - Delete user
✅ `/admin/api/Memo` - All CRUD operations (GET, POST, PUT, DELETE, Download, Mark Read)
✅ `/admin/api/Department` - All CRUD operations
✅ `/admin/api/Leave/holidays` - All CRUD operations for holidays
✅ `/admin/api/staff/{userId}/leave-entitlement` - Update leave entitlement

---

## Recent Fixes (Latest Session - October 2025)

### Document Management Controllers
**Issues Resolved:**
1. ✅ 404 Error - `/admin/api/Policy` - **FIXED**: Created PolicyController with full CRUD
2. ✅ 404 Error - `/admin/api/SOP` - **FIXED**: Created SOPController with full CRUD
3. ✅ 404 Error - `/admin/api/Updates` - **FIXED**: Created UpdatesController with full CRUD
4. ✅ Document Tab Filtering - **FIXED**: Each tab now shows only its document type instead of all memos

**Controllers Created:**
- PolicyController.cs - Complete CRUD for policy documents
- SOPController.cs - Complete CRUD for SOP documents
- UpdatesController.cs - Complete CRUD for updates documents

**DTO Sharing Pattern:**
- All document controllers share `CreateMemoDto` and `MarkReadDto` to avoid code duplication
- Structure: `{ Title, Content, DepartmentId, PostBy, File (IFormFile) }`
- This pattern ensures consistency across all document types

### User Management Fixes
**Issues Resolved:**
1. ✅ 400 Error - User creation validation - **FIXED**: Department dropdown now uses `dept.id` instead of `dept.name`
2. ✅ JSON Case Sensitivity - **FIXED**: Backend now accepts both camelCase and PascalCase via `PropertyNameCaseInsensitive = true`

**Frontend Fixed:**
- AddStaffDialog.jsx:319 - Changed department dropdown from `value={dept.name}` to `value={dept.id}`
- Reason: departmentId expects integer ID, not string name

### Backend Configuration
**PropertyNameCaseInsensitive:**
- Added to Program.cs:57
- Enables seamless communication between React (camelCase) and .NET (PascalCase)
- No manual case conversion required

### Previous Session Fixes
**Issues Resolved:**
1. ✅ 404 Error - `/admin/api/users/departments` - **FIXED**: Added endpoint to UsersController
2. ✅ 404 Error - `/admin/api/users/roles` - **FIXED**: Added endpoint to UsersController
3. ✅ 404 Error - `/admin/api/users/{id}/toggle-status` - **FIXED**: Added endpoint to UsersController
4. ✅ 404 Error - `/admin/api/users/{id}` DELETE - **FIXED**: Added DELETE endpoint to UsersController
5. ✅ 404 Error - `/admin/api/Memo` - **FIXED**: Created MemoController with full CRUD
6. ✅ 404 Error - `/admin/api/Department/{id}` DELETE - **FIXED**: Created DepartmentController with full CRUD
7. ✅ 404 Error - `/admin/api/Leave/holidays` POST - **FIXED**: Created LeaveController with holiday management
8. ✅ 404 Error - `/admin/api/staff/{userId}/leave-entitlement` PUT - **FIXED**: Added endpoint to StaffController
9. ✅ React Error - Invalid object keys in `<option>` - **FIXED**: Updated StaffPage.jsx and AddStaffDialog.jsx to use object properties
10. ✅ React Error - Whitespace in table - **FIXED**: Removed whitespace between table tags in StaffPage.jsx

**Controllers Created (Previous):**
- MemoController.cs - Complete CRUD for memos
- DepartmentController.cs - Complete CRUD for departments
- LeaveController.cs - Holiday management

**Controllers Updated (Previous):**
- UsersController.cs - Added departments, roles, toggle-status, create, update, delete endpoints
- StaffController.cs - Added leave entitlement update endpoint
- HolidayController.cs - Added POST, PUT, DELETE endpoints

**Frontend Fixed (Previous):**
- AddStaffDialog.jsx - Fixed roles/departments object rendering
- StaffPage.jsx - Fixed roles/departments object rendering, removed table whitespace

---

**Backend Server**: ✅ Running on http://0.0.0.0:5000 (Port 5000)
**Last Build**: Successful (0 errors)
**Controllers Loaded**: 29 controllers
**Document Controllers**: MemoController, PolicyController, SOPController, UpdatesController
**Last Updated**: 2025-10-22
