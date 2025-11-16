# MH HR Employee Management System - Backend API

A comprehensive .NET 8.0 ASP.NET Core Web API backend for HR management, built with Clean Architecture principles.

## 🏗️ Architecture Overview

This project follows **Clean Architecture** with clear separation of concerns:

```
React.sln
├── API/                          # Presentation Layer
│   ├── Controllers/             # New Clean Architecture controllers
│   ├── Extensions/              # Dependency injection configuration
│   └── Program.cs               # Application entry point
├── Application/                  # Application Layer
│   ├── Services/                # Business logic implementation
│   └── Helpers/                 # Utilities (JWT, Password hashing)
├── Core/                        # Domain Layer
│   ├── Interfaces/
│   │   ├── Repositories/        # Repository contracts
│   │   └── Services/            # Service contracts
│   └── DTOs/                    # Data Transfer Objects
├── Infrastructure/              # Infrastructure Layer
│   └── Repositories/            # Data access implementation
├── Data/                        # Database contexts
│   ├── AppDbContext.cs
│   ├── AnnualLeaveContext.cs
│   ├── AttendanceContext.cs
│   └── Mc_leaveDB.cs
├── Models/                      # EF Core entity models
├── DTOs/                        # Legacy DTOs
├── Shared/                      # Shared utilities
└── Controller/                  # Legacy controllers (being phased out)
```

## 🚀 Features

### Core HR Modules
- **User Authentication & Authorization** - JWT-based auth with role management
- **Leave Management** - Annual leave, medical leave, leave balance tracking
- **Attendance Tracking** - Clock in/out, attendance reports
- **Training & Certificates** - Course enrollment, certificate uploads
- **Document Management** - Company updates, handbooks, policies with read tracking
- **Equipment Requests** - IT equipment requests and returns
- **Change Requests** - Asset change management workflow
- **Employee Directory** - Staff information and profiles
- **Events & Notifications** - Company events with Firebase push notifications
- **Social Feed** - Employee moments/posts with reactions
- **Birthday & Holiday Calendar** - Company calendar management

### Technical Features
- Clean Architecture with SOLID principles
- Repository and Service Layer patterns
- JWT authentication
- Firebase Cloud Messaging for push notifications
- File upload/download (images, PDFs, documents)
- Role-based authorization
- Read tracking system for documents
- Email notifications via SMTP
- Swagger/OpenAPI documentation

## 📋 Prerequisites

- .NET 8.0 SDK
- SQL Server 2019 or later (or SQL Server Express)
- Visual Studio 2022 / VS Code / Rider
- Firebase account (for push notifications)
- SMTP server credentials (for email)

## 🛠️ Setup Instructions

### 1. Clone the Repository
```bash
git clone <repository-url>
cd mh_hr_employee_dotnet_backend
```

### 2. Configure Application Settings

Create `appsettings.json` from the example template:

```bash
cp appsettings.Example.json appsettings.json
```

Edit `appsettings.json` with your actual configuration:

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=YOUR_SERVER;Database=mydatabase;User Id=YOUR_USERNAME;Password=YOUR_PASSWORD;TrustServerCertificate=True;Trusted_connection=False;Integrated Security=False;"
  },
  "Jwt": {
    "Key": "YOUR_SECURE_SECRET_KEY_MINIMUM_32_CHARACTERS",
    "Issuer": "MH_HR",
    "Audience": "MH_HR Employee",
    "ExpiryInHours": 24
  },
  "Firebase": {
    "ServiceAccountKeyPath": "firebase/YOUR_SERVICE_ACCOUNT.json"
  }
}
```

**Important:** Never commit `appsettings.json` to version control!

### 3. Setup Firebase (Optional but recommended)

1. Create a Firebase project at https://console.firebase.google.com
2. Generate a service account key:
   - Project Settings → Service Accounts → Generate New Private Key
3. Save the JSON file to `firebase/` directory
4. Update the path in `appsettings.json`

### 4. Setup Database

#### Option A: Using Existing Database
If you have an existing SQL Server database with tables already created:

1. Update the connection string in `appsettings.json`
2. Verify the database has all required tables (see Database Schema section)

#### Option B: Create New Database with Migrations

```bash
# Install EF Core tools (if not already installed)
dotnet tool install --global dotnet-ef

# Create initial migration
dotnet ef migrations add InitialCreate

# Apply migration to create database
dotnet ef database update
```

**Note:** The project uses multiple DbContext classes:
- `AppDbContext` - Main entities
- `AnnualLeaveContext` - Leave management
- `AttendanceContext` - Attendance records
- `Mc_leaveDB` - Medical certificates

You may need to create migrations for each context separately.

### 5. Build and Run

```bash
# Restore NuGet packages
dotnet restore

# Build the solution
dotnet build React.sln

# Run the application
dotnet run --project React.csproj
```

The API will start at:
- HTTPS: `https://localhost:7106`
- HTTP: `http://localhost:5000`
- Swagger UI: `https://localhost:7106/` (development only)

### 6. Development with Hot Reload

```bash
dotnet watch run --project React.csproj
```

## 📚 API Documentation

### Swagger/OpenAPI
Access interactive API documentation at `https://localhost:7106/` when running in development mode.

### Main API Routes

#### Authentication (`/api/Auth`)
- `POST /api/Auth/register` - User registration
- `POST /api/Auth/login` - User login (returns JWT token)
- `GET /api/Auth/validate-token` - Validate JWT token
- `GET /api/Auth/profile` - Get user profile
- `PUT /api/Auth/update-nickname` - Update nickname
- `PUT /api/Auth/update-contact` - Update contact number
- `POST /api/Auth/upload-profile-picture` - Upload profile picture
- `POST /api/Auth/change-password` - Change password

#### Documents (`/api/Document`)
- `GET /api/Document` - Get paginated documents
- `GET /api/Document/updates` - Get recent updates (last 30 days)
- `GET /api/Document/updates/unread-count` - Get unread count
- `POST /api/Document/updates/{id}/mark-read` - Mark as read
- `POST /api/Document/updates` - Create update
- `PUT /api/Document/updates/{id}` - Edit update
- `DELETE /api/Document/updates/{id}` - Delete update

#### Events (`/api/Events`)
- `GET /api/Events/all` - Get all events
- `GET /api/Events` - Get events by date
- `GET /api/Events/month` - Get events by month
- `POST /api/Events` - Create event
- `PUT /api/Events/{id}` - Update event
- `DELETE /api/Events/{id}` - Delete event

#### Leave Management (`/api/Leave`)
- `GET /api/Leave/balance` - Get leave balance
- `GET /api/Leave/history` - Get leave history
- `POST /api/Leave/apply` - Apply for leave
- `GET /api/Leave/requests` - Get leave requests

#### Moments/Social Feed (`/api/moments`)
- `GET /api/moments` - Get paginated moments
- `POST /api/moments` - Create moment (with media)
- `POST /api/moments/{id}/reactions` - Add/update reaction

*See Swagger documentation for complete API reference*

## 🗄️ Database Schema

### Key Tables
- `users` - User accounts and profiles
- `departments` - Company departments
- `documents` - Company documents and updates
- `document_reads` - Document read tracking
- `annual_leaves` - Leave records
- `leave_details` - Leave details
- `attendance` - Attendance records
- `training_courses` - Training courses
- `certificates` - Training certificates
- `equipment_requests` - Equipment requests
- `change_requests` - Change requests
- `events` - Company events
- `moments` - Social feed posts
- `quotes` - Daily quotes
- `holidays` - Company holidays
- `handbooks` - Company handbook sections/content

## 🔐 Security Best Practices

### Secrets Management
1. **Never commit secrets to version control**
   - `appsettings.json` is gitignored
   - Firebase service account keys are gitignored

2. **Use User Secrets in Development**
   ```bash
   dotnet user-secrets init
   dotnet user-secrets set "Jwt:Key" "your-secret-key"
   dotnet user-secrets set "ConnectionStrings:DefaultConnection" "your-connection-string"
   ```

3. **Use Environment Variables in Production**
   - Azure App Service: Configure in Application Settings
   - Docker: Use environment variables or secrets
   - On-premise: Use environment variables

### JWT Security
- Use a strong secret key (minimum 32 characters)
- Use HTTPS in production
- Set appropriate token expiry
- Implement refresh tokens for long-lived sessions

### Database Security
- Use parameterized queries (already implemented)
- Never expose connection strings in logs
- Use least privilege database accounts
- Enable encryption at rest and in transit

## 🧪 Testing

```bash
# Run tests (if test projects exist)
dotnet test
```

## 📦 Deployment

### Deploy to Azure App Service

1. **Publish the application**
   ```bash
   dotnet publish -c Release -o ./publish
   ```

2. **Configure Application Settings in Azure**
   - Connection strings
   - JWT settings
   - Firebase path

3. **Deploy using Azure CLI**
   ```bash
   az webapp deployment source config-zip --resource-group <rg-name> --name <app-name> --src publish.zip
   ```

### Deploy with Docker

```dockerfile
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["React.csproj", "./"]
RUN dotnet restore "React.csproj"
COPY . .
RUN dotnet build "React.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "React.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "React.dll"]
```

## 🐛 Troubleshooting

### Common Issues

**1. Database Connection Failed**
- Verify SQL Server is running
- Check connection string format
- Ensure user has appropriate permissions
- For Azure SQL: Add your IP to firewall rules

**2. JWT Token Validation Failed**
- Verify JWT Key matches between token generation and validation
- Check token expiry
- Ensure Issuer and Audience are configured correctly

**3. Firebase Notifications Not Working**
- Verify service account JSON path is correct
- Check Firebase project configuration
- Ensure FCM tokens are being updated

**4. CORS Errors**
- Current configuration allows all origins (development only)
- Update CORS policy in `Program.cs` for production

## 📝 Migration Notes

This project has been refactored from legacy monolithic controllers to Clean Architecture:

### Refactored Controllers
- ✅ `AuthController` → `UserAuthController`
- ✅ `DocumentController` → `UserDocumentsController`
- ✅ `EventsController` → `UserEventsController`
- ✅ `MomentsController` → `UserMomentsController`
- ✅ Legacy leave endpoints → `UserLeaveController`
- ✅ Legacy change request endpoints → `UserChangeRequestsController`

### Legacy Controllers (Still in `Controller/` directory)
Some admin controllers remain in the legacy folder. These will be gradually migrated.

## 🤝 Contributing

1. Follow Clean Architecture principles
2. Use Repository and Service patterns
3. Write unit tests for new features
4. Update API documentation
5. Follow C# coding conventions

## 🔗 Related Projects

This backend serves two frontend applications:

- **Flutter Mobile App**: See `../mh_employee_flutter_app/` for employee mobile application
- **React Web Admin**: See `../mh_hr_employee_react_web/` for admin web portal
- **Main Project**: See `../README.md` for monorepo overview and quick start

## 📄 License

Proprietary - MH HR Employee Management System

## 👥 Team

MH HR Development Team

## 📞 Support

For issues and questions, contact your system administrator
