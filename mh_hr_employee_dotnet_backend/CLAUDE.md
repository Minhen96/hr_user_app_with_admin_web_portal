# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a .NET 8.0 ASP.NET Core Web API backend for a MH HR employee management system. The application provides REST APIs for HR functions including leave management, attendance tracking, training courses, document management, equipment requests, and employee notifications.

## Build and Run Commands

### Build the project
```bash
dotnet build React.sln
```

### Run the application
```bash
dotnet run --project React.csproj
```

### Run in development mode with hot reload
```bash
dotnet watch run --project React.csproj
```

### Clean build artifacts
```bash
dotnet clean
```

### Restore NuGet packages
```bash
dotnet restore
```

## Architecture Overview

### Database Architecture
- **AppDbContext**: Main context containing all entities 
All contexts connect to the same SQL Server database using the connection string from `appsettings.json`.

### Authentication & Authorization
- **JWT Bearer authentication** configured in Program.cs:50
- JWT settings stored in `appsettings.json` under `Jwt` section (Key, Issuer, Audience, ExpiryInHours)
- Login handled via LoginController using SHA256 password hashing
- Passwords are hashed using SHA256 before database comparison (LoginController.cs:21-34)

### API Structure
- **Controllers**: Two patterns exist:
  - Legacy controllers in `Controller/` directory with `[Route("admin/api/[controller]")]`
  - Clean architecture controllers in `API/Controllers/` with same routing pattern
- **Key Controllers**:
  - `LoginController`: Authentication (login endpoint)
  - `UsersController` (API/Controllers/): User management with JWT authentication
  - `UserController` & `UserSideController`: Legacy user management
  - `LeavesController` & `LeaveReportController`: Leave management
  - `AttendanceController`: Attendance tracking
  - `TrainingsController`: Training courses and certificates
  - **Document Controllers** (all in API/Controllers/):
    - `MemoController`: Memo documents (Type = "MEMO")
    - `PolicyController`: Policy documents (Type = "POLICY")
    - `SOPController`: SOP documents (Type = "SOP")
    - `UpdatesController`: Updates documents (Type = "UPDATES")
    - Note: All document controllers share `CreateMemoDto` and `MarkReadDto` from MemoController
  - `EquipmentRequestController` & `EquipmentReturnsController`: Equipment management
  - `ChangeRequestsController` & `ChangeReturnsController`: Change request workflows
  - `StaffController`: Staff information

### Services Layer
- **FirebaseNotificationService**: Push notifications via Firebase Cloud Messaging
  - Configured using service account key from `firebase/` directory
  - Path configured in `appsettings.json` under `Firebase:ServiceAccountKeyPath`
  - Sends notifications with logo image support
- **EmailService**: Email sending via MailKit/SMTP
  - Currently uses hardcoded credentials (example@company.com)
  - Server: dr235.registrarservers.net:587 with TLS
- **FileHandler**: File upload/download utility for certificates
  - Saves files to `wwwroot/uploads/certificates/`
  - Validates file types and enforces 10MB size limit
  - Allowed extensions: .jpg, .jpeg, .png, .gif, .bmp, .pdf, .doc, .docx, .zip, .rar

### Models & DTOs
- **Models**: Located in `Models/` - EF Core entities mapping to database tables
  - Key entities: User, Department, AnnualLeave, LeaveDetail, Attendance, Document, EquipmentRequest, TrainingCourse, Certificate, Moment, Quote, Event, Holiday, ChangeRequest, FixedAssetProduct, FixedAssetType
- **DTOs**: Located in `DTOs/` - Data transfer objects for API requests/responses
  - Decouples API contracts from database models

### CORS Configuration
- Configured to allow all origins, methods, and headers (Program.cs:17-27)
- Policy name: "AllowAll"

### JSON Serialization
- Configured with `ReferenceHandler.IgnoreCycles` to handle circular references (Program.cs:56)
- **PropertyNameCaseInsensitive** set to `true` (Program.cs:57) - accepts both camelCase (from frontend) and PascalCase (backend DTOs)
- This enables seamless communication between React frontend (camelCase) and .NET backend (PascalCase)

### Static Files
- Stored in `wwwroot/` directory
- File uploads go to `wwwroot/uploads/certificates/`
- Static files middleware enabled in Program.cs:100

## Database Connection

The connection string is configured in `appsettings.json`:
- Current active connection: `Server=26.38.5.164,1433;Database=mydatabase;User Id=sa;Password=123456;...`
- Uses SQL Server with TrustServerCertificate=True

## Key Configuration Files

### appsettings.json
Contains:
- Connection strings for SQL Server
- JWT authentication settings (Key, Issuer, Audience, ExpiryInHours)
- Firebase service account key path
- Logging configuration

### React.csproj
Key NuGet packages:
- `Microsoft.EntityFrameworkCore` & `Microsoft.EntityFrameworkCore.SqlServer` (8.0.10)
- `Pomelo.EntityFrameworkCore.MySql` (8.0.2)
- `Microsoft.AspNetCore.Authentication.JwtBearer` (8.0.0)
- `FirebaseAdmin` (3.1.0)
- `MailKit` & `MimeKit` (4.9.0)
- `Swashbuckle.AspNetCore` (6.6.2) for Swagger/OpenAPI
- `iTextSharp` (5.5.13.3) for PDF generation

## Development Notes

### Document Management Controllers
All document controllers (MemoController, PolicyController, SOPController, UpdatesController) follow the same pattern:
- Use shared DTOs: `CreateMemoDto` (for create/update) and `MarkReadDto` (for mark-read endpoint)
- Filter documents by `Type` field in Documents table ("MEMO", "POLICY", "SOP", "UPDATES")
- Support operations: GET all, GET by ID, POST (create), PUT (update), DELETE, download, mark-read
- Accept `[FromForm]` data for create/update to support file uploads
- Store files as binary data in `DocumentUpload` column with `FileType` indicating extension
- Return standardized responses: `{ success: true, documentId: x, message: "..." }`

### Swagger/OpenAPI
- Enabled in development environment
- Access at root URL (/) when running in development mode
- API title: "MH HR Employee Management API" (Clean Architecture API)

### Entity Relationships
The AppDbContext (Data/AppDbContext.cs) configures complex relationships:
- HandbookSection → HandbookContent (one-to-many)
- EquipmentRequest → Signature (multiple foreign keys for request and approval signatures)
- TrainingCourse → Certificate (cascade delete)
- Quote → QuoteReaction & QuoteView (one-to-many)
- Document → DocumentRead (cascade delete, with custom table/column naming)
- FixedAssetProduct has unique ProductCode constraint
- FixedAssetType has unique Code constraint

### Table Naming Conventions
Most entities use default naming, but some have explicit table mappings:
- `documents` table (dbo schema)
- `certificates` table
- `equipment_requests` table (dbo schema)
- `document_reads` table (dbo schema) with snake_case columns
- `change_requests` table

### Direct SQL Usage
Some controllers may use direct SQL queries with ADO.NET (e.g., LoginController uses SqlConnection/SqlCommand for authentication query).

### DTO Sharing Pattern
To avoid code duplication, document controllers share DTOs:
- `CreateMemoDto` is used by all document controllers (Memo, Policy, SOP, Updates)
- `MarkReadDto` is used by all document controllers for the mark-read endpoint
- Structure: `{ Title, Content, DepartmentId, PostBy, File (IFormFile) }`
- This pattern reduces duplicate code and ensures consistency across document types

## Important Security Notes

**DO NOT commit**:
- Firebase service account JSON files (already in repository - treat as sensitive)
- Database credentials in appsettings.json
- Email service credentials in EmailService.cs

When working with authentication/authorization, always validate JWT tokens are properly configured and enforced on protected endpoints.
