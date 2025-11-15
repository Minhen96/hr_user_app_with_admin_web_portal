# Quick Start Guide

Get the MH_HR Employee Management System up and running in 5 minutes!

## 🚀 Quick Setup (Existing Database)

If you already have a SQL Server database with data:

### 1. Configure Secrets

```bash
# Copy the example config
cp appsettings.Example.json appsettings.json

# Edit with your actual credentials
notepad appsettings.json  # Windows
# or
nano appsettings.json     # Linux/Mac
```

Update these values:
- **Server**: Your SQL Server address
- **Database**: Your database name
- **User Id**: Your SQL username
- **Password**: Your SQL password
- **JWT Key**: Generate a random 32+ character string

### 2. Build and Run

```bash
dotnet restore
dotnet build
dotnet run
```

### 3. Access the API

- Swagger UI: https://localhost:7106/
- API Base URL: https://localhost:7106/api/

### 4. Test Login

Use Swagger to test the login endpoint:
```
POST /api/Auth/login
{
  "email": "your-email@example.com",
  "password": "your-password"
}
```

---

## 🆕 Fresh Installation (New Database)

If you're starting from scratch:

### 1. Install Prerequisites

```bash
# Install .NET 8 SDK (if not installed)
# Download from: https://dotnet.microsoft.com/download

# Install EF Core tools
dotnet tool install --global dotnet-ef

# Install SQL Server Express (if not installed)
# Download from: https://www.microsoft.com/sql-server/sql-server-downloads
```

### 2. Configure Connection String

```bash
cp appsettings.Example.json appsettings.json
```

Edit `appsettings.json`:
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost\\SQLEXPRESS;Database=mydatabase;Trusted_Connection=True;TrustServerCertificate=True;"
  },
  "Jwt": {
    "Key": "YOUR_RANDOM_32_CHARACTER_SECRET_KEY_HERE",
    "Issuer": "MH_HR",
    "Audience": "MHHR_Employee",
    "ExpiryInHours": 24
  }
}
```

### 3. Create Database with Migrations

```bash
# Create migrations
dotnet ef migrations add InitialCreate --context AppDbContext

# Apply migrations to create database
dotnet ef database update --context AppDbContext
```

### 4. Seed Initial Data

Connect to your database and run:

```sql
-- Create departments
INSERT INTO departments (name, description) VALUES
('Human Resources', 'HR Department'),
('IT', 'Information Technology'),
('Finance', 'Finance and Accounting');

-- Note: Create your first user via the /api/Auth/register endpoint
```

### 5. Run the Application

```bash
dotnet run
```

### 6. Register First User

Open Swagger UI at https://localhost:7106/ and use the registration endpoint:

```
POST /api/Auth/register
{
  "fullName": "Admin User",
  "email": "admin@example.com",
  "password": "YourSecurePassword123!",
  "birthday": "1990-01-01",
  "departmentId": 1,
  "nric": "000000000000",
  "contactNumber": "0123456789"
}
```

---

## 🔧 Common Issues

### ❌ "Cannot connect to database"
- Check SQL Server is running
- Verify connection string is correct
- Enable TCP/IP in SQL Server Configuration Manager

### ❌ "JWT Key not configured"
- Make sure you set a JWT Key in appsettings.json
- Key must be at least 32 characters

### ❌ "Firebase error"
- Firebase is optional for notifications
- You can ignore Firebase errors if you don't need push notifications
- To disable: Remove Firebase-related code or add error handling

### ❌ "Port already in use"
- Change ports in `Properties/launchSettings.json`
- Or kill the process using port 7106/5000

---

## 📖 Next Steps

- **Read the full documentation**: [README.md](README.md)
- **Setup database properly**: [DATABASE_SETUP.md](DATABASE_SETUP.md)
- **Configure secrets**: See README.md Security section
- **Deploy to production**: See README.md Deployment section

---

## 🔐 Security Checklist

Before deploying to production:

- [ ] Change default JWT secret key
- [ ] Use strong database passwords
- [ ] Remove sensitive data from appsettings.json
- [ ] Enable HTTPS only
- [ ] Configure CORS for specific origins only
- [ ] Setup Firebase properly (or remove if not needed)
- [ ] Review and update admin user credentials
- [ ] Enable SQL Server encryption
- [ ] Setup regular database backups

---

## 📞 Need Help?

- Check [README.md](README.md) for detailed documentation
- Check [DATABASE_SETUP.md](DATABASE_SETUP.md) for database help
- Review the Troubleshooting section in README
- Contact your team lead or system administrator

Happy coding! 🎉
