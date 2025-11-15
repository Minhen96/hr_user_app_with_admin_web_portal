# MH HR Backend API Endpoints Reference

**Last Updated:** 2025-10-27
**Base URL:** `http://localhost:5000`

## Table of Contents

- [Authentication](#authentication)
- [User Management](#user-management)
- [Leave Management](#leave-management)
- [Attendance](#attendance)
- [Documents](#documents)
- [Events](#events)
- [Equipment Management](#equipment-management)
- [Change Requests](#change-requests)
- [Training](#training)
- [Moments (Social Feed)](#moments-social-feed)
- [Calendar (Holidays & Birthdays)](#calendar-holidays--birthdays)
- [Notifications](#notifications)
- [Departments](#departments)
- [Handbook](#handbook)
- [Quotes](#quotes)
- [Email](#email)

## Route Pattern Conventions

The backend uses two route patterns:

### Admin Routes (Web Portal)
Format: `/admin/api/[Controller]`
- Used by the React web admin portal
- Examples: `/admin/api/Auth`, `/admin/api/Staff`, `/admin/api/Memo`

### User Routes (Mobile App)
Format: `/api/[Controller]`
- Used by the Flutter mobile app
- Examples: `/api/Auth`, `/api/Leave`, `/api/Events`

---

## Authentication

### User Auth Controller
**Base Route:** `/api/Auth`

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| POST | `/api/Auth/register` | Register new user | No |
| POST | `/api/Auth/login` | User login, returns JWT token | No |
| GET | `/api/Auth/validate-token` | Validate JWT token | Yes |
| GET | `/api/Auth/profile` | Get user profile | Yes |
| PUT | `/api/Auth/update-nickname` | Update user nickname | Yes |
| PUT | `/api/Auth/update-contact` | Update contact number | Yes |
| POST | `/api/Auth/upload-profile-picture` | Upload profile picture | Yes |
| POST | `/api/Auth/change-password` | Change user password | Yes |
| POST | `/api/Auth/request-password-change` | Request password change | Yes |

**Login Response Structure:**
```json
{
  "success": true,
  "token": "eyJhbGc...",
  "user": {
    "Id": 1,
    "FullName": "John Doe",
    "Email": "john@example.com",
    "Role": "user",
    "Department": {
      "Id": 1,
      "Name": "IT"
    }
  }
}
```

### Admin Auth Controller
**Base Route:** `/admin/api/Auth`

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| POST | `/admin/api/Auth/login` | Admin login | No |
| POST | `/admin/api/Auth/change-password` | Admin change password | Yes |
| GET | `/admin/api/Auth/password-change-requests` | Get password change requests | Yes |
| POST | `/admin/api/Auth/approve-password-change` | Approve password change | Yes |

---

## User Management

### Users Controller
**Base Route:** `/admin/api/users`

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | `/admin/api/users` | Get all users | Yes |
| GET | `/admin/api/users/{id}` | Get user by ID | Yes |
| POST | `/admin/api/users` | Create new user | Yes |
| PUT | `/admin/api/users/{id}` | Update user | Yes |
| DELETE | `/admin/api/users/{id}` | Delete user | Yes |
| GET | `/admin/api/users/by-department/{deptId}` | Get users by department | Yes |
| PUT | `/admin/api/users/{id}/role` | Update user role | Yes |
| PUT | `/admin/api/users/{id}/status` | Update user status | Yes |

### Staff Controller
**Base Route:** `/admin/api/staff`

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | `/admin/api/staff` | Get all staff | Yes |
| GET | `/admin/api/staff/{id}` | Get staff by ID | Yes |
| POST | `/admin/api/staff` | Create staff | Yes |
| PUT | `/admin/api/staff/{id}` | Update staff | Yes |
| DELETE | `/admin/api/staff/{id}` | Delete staff | Yes |
| GET | `/admin/api/staff/{id}/leave-details` | Get staff leave details | Yes |
| PUT | `/admin/api/staff/{id}/leave-entitlement` | Update leave entitlement | Yes |
| GET | `/admin/api/staff/{id}/attendance` | Get staff attendance | Yes |
| GET | `/admin/api/staff/{id}/training` | Get staff training records | Yes |

---

## Leave Management

### User Leave Controller (Mobile App)
**Base Route:** `/api/Leave`

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| POST | `/api/Leave/submit` | Submit leave request | Yes |
| GET | `/api/Leave/entitlement/{userId}` | Get leave entitlement | Yes |
| GET | `/api/Leave/ANLpending-leaves/{id}` | Get pending annual leaves | Yes |
| GET | `/api/Leave/ANLapprove-leaves/{id}` | Get approved annual leaves for user | Yes |
| GET | `/api/Leave/ANLapprove-leaves` | Get all approved annual leaves | Yes |
| PUT | `/api/Leave/update` | Update leave request | Yes |
| DELETE | `/api/Leave/delete/{id}` | Delete leave request | Yes |

### Leave Controller (Admin Portal)
**Base Route:** `/admin/api/Leave`

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | `/admin/api/Leave/holidays` | Get holidays by year/month | Yes |
| POST | `/admin/api/Leave/holidays` | Add holiday | Yes |
| PUT | `/admin/api/Leave/holidays/{id}` | Update holiday | Yes |
| DELETE | `/admin/api/Leave/holidays/{id}` | Delete holiday | Yes |

### Leaves Controller (Legacy)
**Base Route:** `/admin/api/Leaves`

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | `/admin/api/Leaves` | Get all leaves | Yes |
| GET | `/admin/api/Leaves/{id}` | Get leave by ID | Yes |
| POST | `/admin/api/Leaves/approve` | Approve leave | Yes |
| POST | `/admin/api/Leaves/reject` | Reject leave | Yes |

### Medical Certificate Leave (Mobile App)
**Base Route:** `/api/Mc_Pending_`

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | `/api/Mc_Pending_/approved-leaves` | Get all MC leaves | Yes |
| GET | `/api/Mc_Pending_/pending-leaves/{id}` | Get pending MC leaves for user | Yes |
| GET | `/api/Mc_Pending_/approved-leaves/{id}` | Get approved MC leaves for user | Yes |

### Medical Certificate Controller
**Base Route:** `/api/Mc`

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| POST | `/api/Mc/submit` | Submit MC leave | Yes |
| GET | `/api/Mc/{id}` | Get MC by ID | Yes |
| PUT | `/api/Mc/update` | Update MC leave | Yes |
| DELETE | `/api/Mc/delete/{id}` | Delete MC leave | Yes |

### Leave Report Controller
**Base Route:** `/admin/api/LeaveReport`

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | `/admin/api/LeaveReport/generate` | Generate leave report | Yes |
| GET | `/admin/api/LeaveReport/{year}/{month}` | Get monthly leave report | Yes |

---

## Attendance

### Attendance Controller
**Base Route:** `/admin/api/Attendance`

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| POST | `/admin/api/Attendance/TimeIn` | Clock in | Yes |
| POST | `/admin/api/Attendance/TimeOut/{id}` | Clock out | Yes |
| GET | `/admin/api/Attendance/CurrentDaySubmissions/{userID}` | Get today's attendance | Yes |
| GET | `/admin/api/Attendance/MonthlyAttendance/{userID}` | Get monthly attendance | Yes |

**Query Parameters for MonthlyAttendance:**
- `month` (optional): Month number (1-12)
- `year` (optional): Year (e.g., 2025)

---

## Documents

All document endpoints support file uploads using `multipart/form-data`.

### User Documents Controller (Mobile App)
**Base Route:** `/api/Document`

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | `/api/Document` | Get paginated documents | Yes |
| GET | `/api/Document/updates` | Get recent updates (last 30 days) | Yes |
| GET | `/api/Document/updates/unread-count` | Get unread count | Yes |
| POST | `/api/Document/updates/{id}/mark-read` | Mark document as read | Yes |
| POST | `/api/Document/updates` | Create update | Yes |
| PUT | `/api/Document/updates/{id}` | Edit update | Yes |
| DELETE | `/api/Document/updates/{id}` | Delete update | Yes |
| GET | `/api/Document/{docId}/mark-read` | Mark any document as read | Yes |
| GET | `/api/Document/{documentId}/download` | Download document | Yes |
| GET | `/api/Document/unread-counts` | Get unread counts by type | Yes |

### Admin Documents Controller
**Base Route:** `/admin/api/Documents`

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | `/admin/api/Documents` | Get all documents | Yes |
| GET | `/admin/api/Documents/{id}` | Get document by ID | Yes |
| POST | `/admin/api/Documents` | Create document | Yes |
| PUT | `/admin/api/Documents/{id}` | Update document | Yes |
| DELETE | `/admin/api/Documents/{id}` | Delete document | Yes |
| GET | `/admin/api/Documents/by-type/{type}` | Get documents by type | Yes |

### Memo Controller
**Base Route:** `/admin/api/Memo`

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | `/admin/api/Memo` | Get all memos | Yes |
| GET | `/admin/api/Memo/{id}` | Get memo by ID | Yes |
| POST | `/admin/api/Memo` | Create memo (with file upload) | Yes |
| PUT | `/admin/api/Memo/{id}` | Update memo | Yes |
| DELETE | `/admin/api/Memo/{id}` | Delete memo | Yes |
| GET | `/admin/api/Memo/{id}/download` | Download memo file | Yes |
| POST | `/admin/api/Memo/{id}/mark-read` | Mark memo as read | Yes |

**Form Data Fields:**
- `Title` (string, required)
- `Content` (string, required)
- `DepartmentId` (int, required)
- `PostBy` (int, required - user ID)
- `File` (file, optional)

### Policy Controller
**Base Route:** `/admin/api/Policy`

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | `/admin/api/Policy` | Get all policies | Yes |
| GET | `/admin/api/Policy/{id}` | Get policy by ID | Yes |
| POST | `/admin/api/Policy` | Create policy (with file upload) | Yes |
| PUT | `/admin/api/Policy/{id}` | Update policy | Yes |
| DELETE | `/admin/api/Policy/{id}` | Delete policy | Yes |
| GET | `/admin/api/Policy/{id}/download` | Download policy file | Yes |
| POST | `/admin/api/Policy/{id}/mark-read` | Mark policy as read | Yes |

### SOP Controller
**Base Route:** `/admin/api/SOP`

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | `/admin/api/SOP` | Get all SOPs | Yes |
| GET | `/admin/api/SOP/{id}` | Get SOP by ID | Yes |
| POST | `/admin/api/SOP` | Create SOP (with file upload) | Yes |
| PUT | `/admin/api/SOP/{id}` | Update SOP | Yes |
| DELETE | `/admin/api/SOP/{id}` | Delete SOP | Yes |
| GET | `/admin/api/SOP/{id}/download` | Download SOP file | Yes |
| POST | `/admin/api/SOP/{id}/mark-read` | Mark SOP as read | Yes |

### Updates Controller
**Base Route:** `/admin/api/Updates`

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | `/admin/api/Updates` | Get all updates | Yes |
| GET | `/admin/api/Updates/{id}` | Get update by ID | Yes |
| POST | `/admin/api/Updates` | Create update (with file upload) | Yes |
| PUT | `/admin/api/Updates/{id}` | Update update | Yes |
| DELETE | `/admin/api/Updates/{id}` | Delete update | Yes |
| GET | `/admin/api/Updates/{id}/download` | Download update file | Yes |
| POST | `/admin/api/Updates/{id}/mark-read` | Mark update as read | Yes |

---

## Events

### User Events Controller (Mobile App)
**Base Route:** `/api/Events`

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | `/api/Events/all` | Get all events | Yes |
| GET | `/api/Events` | Get events by date | Yes |
| GET | `/api/Events/month` | Get events by month | Yes |
| POST | `/api/Events` | Create event | Yes |
| PUT | `/api/Events/{id}` | Update event | Yes |
| DELETE | `/api/Events/{id}` | Delete event | Yes |
| POST | `/api/Events/{id}/mark-read` | Mark event as read | Yes |
| GET | `/api/Events/{eventId}/read-status` | Get event read status | Yes |

**Query Parameters:**
- `date` (DateTime): Filter by specific date
- `year` (int): Filter by year
- `month` (int): Filter by month (1-12)

---

## Equipment Management

### Equipment Request Controller
**Base Route:** `/admin/api/EquipmentRequests`

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | `/admin/api/EquipmentRequests` | Get all equipment requests | Yes |
| GET | `/admin/api/EquipmentRequests/{id}` | Get request by ID | Yes |
| POST | `/admin/api/EquipmentRequests` | Create equipment request | Yes |
| PUT | `/admin/api/EquipmentRequests/{id}` | Update request | Yes |
| DELETE | `/admin/api/EquipmentRequests/{id}` | Delete request | Yes |
| POST | `/admin/api/EquipmentRequests/{id}/approve` | Approve request | Yes |
| POST | `/admin/api/EquipmentRequests/{id}/reject` | Reject request | Yes |
| GET | `/admin/api/EquipmentRequests/user/{userId}` | Get user's requests | Yes |
| GET | `/admin/api/EquipmentRequests/pending` | Get pending requests | Yes |

**Note:** "Fixed Asset" category equipment always has quantity = 1

### Equipment Returns Controller
**Base Route:** `/admin/api/EquipmentReturns`

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | `/admin/api/EquipmentReturns` | Get all returns | Yes |
| GET | `/admin/api/EquipmentReturns/{id}` | Get return by ID | Yes |
| POST | `/admin/api/EquipmentReturns` | Create return | Yes |
| PUT | `/admin/api/EquipmentReturns/{id}` | Update return | Yes |
| DELETE | `/admin/api/EquipmentReturns/{id}` | Delete return | Yes |
| POST | `/admin/api/EquipmentReturns/{id}/approve` | Approve return | Yes |

---

## Change Requests

### User Change Requests Controller (Mobile App)
**Base Route:** `/api/ChangeRequests`

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | `/api/ChangeRequests` | Get all change requests | Yes |
| GET | `/api/ChangeRequests/{id}` | Get change request by ID | Yes |
| POST | `/api/ChangeRequests` | Create change request | Yes |
| PUT | `/api/ChangeRequests/{id}` | Update change request | Yes |
| DELETE | `/api/ChangeRequests/{id}` | Delete change request | Yes |
| GET | `/api/ChangeRequests/user/{userId}` | Get user's change requests | Yes |
| POST | `/api/ChangeRequests/signature` | Upload signature | Yes |

### Admin Change Requests Controller
**Base Route:** `/admin/api/ChangeRequests`

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | `/admin/api/ChangeRequests` | Get all change requests | Yes |
| GET | `/admin/api/ChangeRequests/{id}` | Get by ID | Yes |
| POST | `/admin/api/ChangeRequests/{id}/approve` | Approve request | Yes |
| POST | `/admin/api/ChangeRequests/{id}/reject` | Reject request | Yes |

### Change Returns Controller
**Base Route:** `/admin/api/ChangeReturns`

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | `/admin/api/ChangeReturns` | Get all change returns | Yes |
| POST | `/admin/api/ChangeReturns` | Create change return | Yes |
| POST | `/admin/api/ChangeReturns/{id}/approve` | Approve return | Yes |

---

## Training

### Trainings Controller
**Base Route:** `/admin/api/Trainings`

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | `/admin/api/Trainings` | Get all training records | Yes |
| GET | `/admin/api/Trainings/{id}` | Get training by ID | Yes |
| POST | `/admin/api/Trainings` | Create training record (with certificate upload) | Yes |
| PUT | `/admin/api/Trainings/{id}` | Update training | Yes |
| DELETE | `/admin/api/Trainings/{id}` | Delete training | Yes |
| GET | `/admin/api/Trainings/user/{userId}` | Get user's training records | Yes |
| PUT | `/admin/api/Trainings/{id}/status` | Update training status | Yes |
| GET | `/admin/api/Trainings/{id}/certificate` | Download certificate | Yes |

**Training Statuses:**
- Pending
- Approved
- Rejected
- Completed

---

## Moments (Social Feed)

### User Moments Controller (Mobile App)
**Base Route:** `/api/moments`

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | `/api/moments` | Get paginated moments | Yes |
| POST | `/api/moments` | Create moment (with media upload) | Yes |
| PUT | `/api/moments/{id}` | Update moment | Yes |
| DELETE | `/api/moments/{id}` | Delete moment | Yes |
| POST | `/api/moments/{id}/reactions` | Add/update reaction | Yes |
| DELETE | `/api/moments/{id}/reactions` | Remove reaction | Yes |
| POST | `/api/moments/{id}/comments` | Add comment | Yes |
| GET | `/api/moments/{id}/comments` | Get moment comments | Yes |
| POST | `/api/moments/{momentId}/reports` | Report moment | Yes |

**Query Parameters for GET:**
- `page` (int): Page number (default: 1)
- `pageSize` (int): Items per page (default: 10)

**Reaction Types:**
- Like
- Love
- Haha
- Wow
- Sad
- Angry

---

## Calendar (Holidays & Birthdays)

### Holiday Controller
**Base Route:** `/admin/api/Holiday`

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | `/admin/api/Holiday` | Get holidays by year/month | Yes |
| GET | `/admin/api/Holiday/all` | Get all holidays (current + next year) | Yes |
| POST | `/admin/api/Holiday` | Add holiday | Yes |
| PUT | `/admin/api/Holiday/{id}` | Update holiday | Yes |
| DELETE | `/admin/api/Holiday/{id}` | Delete holiday | Yes |

**Query Parameters:**
- `year` (int, optional): Year (defaults to current year)
- `month` (int, optional): Month 1-12 (defaults to current month)

### Birthday Controller
**Base Route:** `/admin/api/Birthday`

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | `/admin/api/Birthday` | Get birthdays by month | Yes |

**Query Parameters:**
- `month` (int, required): Month number (1-12)

---

## Notifications

### Notification Controller
**Base Route:** `/admin/api/Notification`

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| POST | `/admin/api/Notification/register-token` | Register FCM token | Yes |
| POST | `/admin/api/Notification/send` | Send push notification | Yes |
| GET | `/admin/api/Notification/user/{userId}` | Get user notifications | Yes |
| PUT | `/admin/api/Notification/{id}/read` | Mark notification as read | Yes |

**FCM Token Registration:**
```json
{
  "userId": 1,
  "fcmToken": "firebase-token-here"
}
```

---

## Departments

### Department Controller
**Base Route:** `/admin/api/Department`

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | `/admin/api/Department` | Get all departments | Yes |
| GET | `/admin/api/Department/{id}` | Get department by ID | Yes |
| POST | `/admin/api/Department` | Create department | Yes |
| PUT | `/admin/api/Department/{id}` | Update department | Yes |
| DELETE | `/admin/api/Department/{id}` | Delete department | Yes |

---

## Handbook

### Handbook Controller
**Base Route:** `/admin/api/Handbook`

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | `/admin/api/Handbook` | Get all handbook sections | Yes |
| GET | `/admin/api/Handbook/{id}` | Get section by ID | Yes |
| GET | `/admin/api/Handbook/userguide` | Get user guide | Yes |
| POST | `/admin/api/Handbook` | Create handbook section | Yes |
| PUT | `/admin/api/Handbook/{id}` | Update section | Yes |
| DELETE | `/admin/api/Handbook/{id}` | Delete section | Yes |

---

## Quotes

### Quote Controller
**Base Route:** `/api/Quote`

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | `/api/Quote` | Get latest quote | Yes |
| GET | `/api/Quote/carousel-content` | Get carousel items | Yes |
| GET | `/api/Quote/{quoteId}/views` | Get quote views | Yes |
| GET | `/api/Quote/{quoteId}/reactions` | Get quote reactions | Yes |

**Response Format:**
```json
{
  "id": 1,
  "text": "Quote text",
  "textCn": "Chinese translation",
  "lastEditedBy": "Admin",
  "lastEditedDate": "2025-10-27T10:00:00",
  "carouselType": "Quote",
  "imageUrl": "path/to/image.jpg"
}
```

---

## Email

### Email Controller
**Base Route:** `/api/Email`

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| POST | `/api/Email/send` | Send email | Yes |
| POST | `/api/Email/send-bulk` | Send bulk email | Yes |

**Email Request:**
```json
{
  "to": "recipient@example.com",
  "subject": "Email Subject",
  "body": "Email body content",
  "isHtml": true
}
```

---

## Authentication

All endpoints except login and register require JWT authentication.

### Request Headers:
```
Authorization: Bearer <jwt-token>
Content-Type: application/json
```

### For File Uploads:
```
Authorization: Bearer <jwt-token>
Content-Type: multipart/form-data
```

---

## Error Responses

### 400 Bad Request
```json
{
  "message": "Invalid request data",
  "errors": {
    "field": ["Error message"]
  }
}
```

### 401 Unauthorized
```json
{
  "message": "Authentication token not found or invalid"
}
```

### 404 Not Found
```json
{
  "message": "Resource not found"
}
```

### 500 Internal Server Error
```json
{
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

---

## Notes

1. **Route Prefixes:**
   - Mobile App endpoints typically use `/api/` prefix
   - Web Admin Portal endpoints use `/admin/api/` prefix

2. **File Uploads:**
   - Max file size: 10MB
   - Allowed extensions: .jpg, .jpeg, .png, .gif, .bmp, .pdf, .doc, .docx, .zip, .rar
   - Files stored in `wwwroot/uploads/certificates/`

3. **Pagination:**
   - Default page size: 10
   - Max page size: 100
   - Page numbers start at 1

4. **Date Formats:**
   - ISO 8601 format: `YYYY-MM-DDTHH:mm:ss`
   - Example: `2025-10-27T14:30:00`

5. **Case Sensitivity:**
   - Backend accepts both PascalCase and camelCase in requests
   - Backend responds in PascalCase by default
   - PropertyNameCaseInsensitive is enabled

---

## Quick Reference

### Most Common Endpoints

**Authentication:**
- POST `/api/Auth/login` - Login
- GET `/api/Auth/profile` - Get profile

**Leave:**
- POST `/api/Leave/submit` - Submit leave
- GET `/api/Leave/ANLapprove-leaves` - Get approved leaves

**Attendance:**
- POST `/admin/api/Attendance/TimeIn` - Clock in
- GET `/admin/api/Attendance/CurrentDaySubmissions/{userID}` - Today's attendance

**Documents:**
- GET `/api/Document/updates` - Get recent updates
- POST `/api/Document/updates/{id}/mark-read` - Mark as read

**Events:**
- GET `/api/Events/all` - Get all events
- GET `/api/Events/month?year=2025&month=10` - Get monthly events

---

**For detailed information about request/response formats, refer to Swagger documentation at `https://localhost:7106/` (development only).**
