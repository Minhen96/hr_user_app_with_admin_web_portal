# MH HR Employee Management System

A comprehensive HR management system with backend API, web admin portal, and mobile employee app.

## 📁 Project Structure

This is a monorepo containing three interconnected applications:

```
mh_hr_employee_projects/
├── mh_hr_employee_dotnet_backend/    # .NET 8.0 Web API Backend
├── mh_hr_employee_react_web/         # React Web Admin Portal
├── mh_employee_flutter_app/          # Flutter Mobile Employee App
├── CLAUDE.md                          # Detailed project documentation
└── README.md                          # This file
```

### 🔧 Backend API - .NET 8.0
**Directory**: `mh_hr_employee_dotnet_backend/`

A RESTful API backend built with ASP.NET Core, featuring:
- JWT authentication
- Clean Architecture
- SQL Server database
- Firebase push notifications
- Document management, leave tracking, equipment requests, and more

**[📖 View Backend Documentation](mh_hr_employee_dotnet_backend/README.md)**

### 🌐 Web Admin Portal - React
**Directory**: `mh_hr_employee_react_web/my-react/`

Modern React web application for HR administrators:
- User & staff management
- Approve/reject leave requests
- Equipment request management
- Document uploads
- Training course management

**[📖 View Web Admin Documentation](mh_hr_employee_react_web/README.md)**

### 📱 Mobile Employee App - Flutter
**Directory**: `mh_employee_flutter_app/`

Flutter mobile app for employees (Android/iOS):
- View documents & company updates
- Apply for leave
- Request equipment
- View training courses
- Check attendance
- Modern purple gradient UI with dark/light mode

**[📖 View Mobile App Documentation](mh_employee_flutter_app/README.md)**

---

## 🚀 Quick Start

### 1. Start Backend API

```bash
cd mh_hr_employee_dotnet_backend
dotnet restore
dotnet build React.sln
dotnet run --project React.csproj

# API runs on:
# - HTTP: http://localhost:5000
# - HTTPS: https://localhost:7106
# - Swagger: https://localhost:7106/
```

### 2. Start Web Admin Portal

```bash
cd mh_hr_employee_react_web/my-react
npm install
npm run dev

# Web admin runs on: http://localhost:5173
```

### 3. Run Mobile App

```bash
cd mh_employee_flutter_app
flutter pub get
flutter run

# Runs on connected Android/iOS device or emulator
```

## 🏗️ System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Mobile App (Flutter)                     │
│          Employee-facing features & self-service            │
└────────────────────────┬────────────────────────────────────┘
                         │
                         │ HTTPS/REST API
                         │ JWT Authentication
                         │
┌────────────────────────▼────────────────────────────────────┐
│                  Backend API (.NET 8.0)                     │
│        - JWT Auth    - Document Management                  │
│        - SQL Server  - Leave Tracking                       │
│        - Firebase    - Equipment Requests                   │
└────────────────────────▲────────────────────────────────────┘
                         │
                         │ HTTPS/REST API
                         │ JWT Authentication
                         │
┌────────────────────────┴────────────────────────────────────┐
│              Web Admin Portal (React)                       │
│          Admin-facing features & management                 │
└─────────────────────────────────────────────────────────────┘
```

## 📋 Prerequisites

- **.NET 8.0 SDK** - For backend API
- **Node.js 16+** - For React web admin
- **Flutter 3.5.4+** - For mobile app
- **SQL Server** - Database (local or remote)
- **Firebase** (optional) - For push notifications

## 🔐 Authentication Flow

1. Users log in via web or mobile app
2. Backend validates credentials and returns JWT token
3. Token is stored (localStorage for web, secure storage for mobile)
4. All subsequent API requests include the token in headers
5. Backend validates token and processes requests
6. Token expires after 24 hours (configurable)

## 📚 Documentation

### Project Documentation
- **CLAUDE.md** - Comprehensive development guide with architecture details, conventions, and examples
- **README.md** (this file) - Monorepo overview and quick start

### Individual Project Documentation
- **[Backend README](mh_hr_employee_dotnet_backend/README.md)** - API setup, endpoints, deployment
- **[Web Admin README](mh_hr_employee_react_web/README.md)** - React app setup, features, deployment
- **[Mobile App README](mh_employee_flutter_app/README.md)** - Flutter setup, design system, APIs

### Additional Documentation
- **Backend CLAUDE.md** - Backend-specific development guide
- **TEST_AND_FINISH.md** - React testing guide
- **QUICK_REFERENCE.md** - Common commands and patterns
- **REFACTORING.md** - Architecture refactoring notes

## 🎯 Key Features

### For Employees (Mobile App)
- View company documents and updates
- Apply for annual/medical leave
- Request IT equipment
- View training courses and upload certificates
- Track attendance
- View company calendar and events
- Social feed (moments)

### For Administrators (Web Portal)
- Manage users and departments
- Approve/reject leave requests
- Manage equipment requests
- Upload company documents
- Create training courses
- View analytics and reports
- Manage staff directory

### Technical Features
- JWT-based authentication
- Role-based access control (super-admin, department-admin, user)
- File upload/download
- Push notifications (Firebase)
- Email notifications
- PDF generation and viewing
- Real-time data updates

## 🛠️ Development Workflow

### 1. Setup Development Environment

```bash
# Clone repository
git clone <repository-url>
cd mh_hr_employee_projects

# Setup backend
cd mh_hr_employee_dotnet_backend
# Configure appsettings.json (see backend README)
dotnet restore

# Setup web admin
cd ../mh_hr_employee_react_web/my-react
npm install

# Setup mobile app
cd ../../mh_employee_flutter_app
flutter pub get
```

### 2. Run All Applications

```bash
# Terminal 1: Backend API
cd mh_hr_employee_dotnet_backend
dotnet run --project React.csproj

# Terminal 2: Web Admin
cd mh_hr_employee_react_web/my-react
npm run dev

# Terminal 3: Mobile App
cd mh_employee_flutter_app
flutter run
```

### 3. Access Applications

- **Backend API Swagger**: https://localhost:7106/
- **Web Admin Portal**: http://localhost:5173
- **Mobile App**: On connected device/emulator

## 🔧 Configuration

### Backend API Configuration
See `mh_hr_employee_dotnet_backend/appsettings.json`:
- Database connection string
- JWT secret key and settings
- Firebase service account path
- SMTP email settings

### Web Admin Configuration
See `mh_hr_employee_react_web/my-react/.env.development`:
- Backend API URL

### Mobile App Configuration
See `mh_employee_flutter_app/lib/services/api_service.dart`:
- Backend API base URL
- Timeout settings

## 🐛 Troubleshooting

### Backend Issues
- **Database connection failed**: Check SQL Server is running and connection string is correct
- **JWT validation failed**: Verify JWT key matches in config and is at least 32 characters
- See [Backend README](mh_hr_employee_dotnet_backend/README.md#-troubleshooting) for more

### Web Admin Issues
- **API connection failed**: Ensure backend is running on http://localhost:5000
- **401 errors**: Clear localStorage and login again
- See [Web Admin README](mh_hr_employee_react_web/README.md#troubleshooting) for more

### Mobile App Issues
- **API not connecting**: Check `api_service.dart` has correct backend URL
- **Build errors**: Run `flutter clean && flutter pub get`
- See [Mobile App README](mh_employee_flutter_app/README.md#common-issues) for more

## 📊 Project Status

| Component | Status | Description |
|-----------|--------|-------------|
| Backend API | ✅ Production Ready | Clean Architecture, fully documented |
| Web Admin Portal | ✅ Production Ready | Modern React app with feature-based structure |
| Mobile App | ✅ Production Ready | Modern UI with purple gradient theme |
| Database | ✅ Ready | SQL Server with multiple contexts |
| Authentication | ✅ Implemented | JWT with role-based access |
| Documentation | ✅ Complete | Comprehensive README files for all projects |

## 🤝 Contributing

1. Follow the architecture patterns described in CLAUDE.md
2. Write clean, documented code
3. Test thoroughly before committing
4. Update relevant documentation
5. Follow naming conventions and code style

## 📄 License

Proprietary - MH HR Employee Management System

## 💡 Need Help?

- **Backend setup**: See [mh_hr_employee_dotnet_backend/README.md](mh_hr_employee_dotnet_backend/README.md)
- **Web admin setup**: See [mh_hr_employee_react_web/README.md](mh_hr_employee_react_web/README.md)
- **Mobile app setup**: See [mh_employee_flutter_app/README.md](mh_employee_flutter_app/README.md)
- **Architecture & conventions**: See [CLAUDE.md](CLAUDE.md)

---

**Last Updated**: 2025-11-16
