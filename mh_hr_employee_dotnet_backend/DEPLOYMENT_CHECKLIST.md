# Deployment Checklist

Use this checklist before deploying to production.

## 🔐 Security Checklist

### Secrets & Configuration
- [ ] **Change JWT Secret Key** - Current key is `Change-this-secret-key-before-production`
  - [ ] Generate new 32+ character random key
  - [ ] Update in production environment variables
  - [ ] Never commit to source control

- [ ] **Secure Database Password**
  - [ ] Use strong password (not `123456`)
  - [ ] Store in environment variables or Azure Key Vault
  - [ ] Restrict database access to application server IPs only

- [ ] **Email Credentials**
  - [ ] Verify SMTP credentials are correct
  - [ ] Use app-specific password if available
  - [ ] Store in environment variables

- [ ] **Remove Test Data**
  - [ ] Remove any test users with weak passwords
  - [ ] Clear test data from database
  - [ ] Verify no dummy data in production

### Code Security
- [ ] **Update CORS Policy**
  - [ ] Currently allows `AllowAnyOrigin()` - **NOT SAFE FOR PRODUCTION**
  - [ ] Update to specific origins only:
    ```csharp
    policy.WithOrigins("https://yourdomain.com", "https://app.yourdomain.com")
    ```

- [ ] **HTTPS Only**
  - [ ] Disable HTTP in production
  - [ ] Force HTTPS redirection
  - [ ] Set `UseHttpsRedirection()` in Program.cs

- [ ] **Disable Swagger in Production**
  - [ ] Currently enabled in development only ✅
  - [ ] Verify swagger not accessible in production

## 📊 Database Checklist

- [ ] **Database Backup**
  - [ ] Setup automated backups
  - [ ] Test restore procedure
  - [ ] Document backup schedule

- [ ] **Database Migration**
  - [ ] Choose migration strategy (see DBCONTEXT_MIGRATION_GUIDE.md)
  - [ ] Run migrations in staging first
  - [ ] Backup before production migration

- [ ] **Database Performance**
  - [ ] Review and add indexes for common queries
  - [ ] Check query performance
  - [ ] Setup database monitoring

- [ ] **Data Seeding**
  - [ ] Create departments
  - [ ] Create admin user
  - [ ] Setup initial leave balances
  - [ ] Add company holidays

## 🚀 Application Configuration

- [ ] **Environment Variables**
  ```bash
  ConnectionStrings__DefaultConnection=<your-connection-string>
  Jwt__Key=<your-32-char-secret>
  Jwt__Issuer=MH_HR
  Jwt__Audience=MHHR_Employee
  Jwt__ExpiryInHours=24
  Email__SmtpServer=<your-smtp-server>
  Email__SmtpPort=587
  Email__Username=<your-email>
  Email__Password=<your-email-password>
  Email__FromName=MH_HR_System
  ```

- [ ] **Logging Configuration**
  - [ ] Configure application insights or similar
  - [ ] Set appropriate log levels
  - [ ] Setup error alerting

- [ ] **Connection Pooling**
  - [ ] Review EF Core connection string settings
  - [ ] Set appropriate pool size
  - [ ] Configure timeouts

## 🧪 Testing Checklist

- [ ] **Functional Testing**
  - [ ] Test user registration
  - [ ] Test user login
  - [ ] Test leave management
  - [ ] Test document uploads
  - [ ] Test all CRUD operations

- [ ] **Performance Testing**
  - [ ] Load test authentication endpoints
  - [ ] Test concurrent users
  - [ ] Verify response times
  - [ ] Check memory usage

- [ ] **Security Testing**
  - [ ] Test JWT token validation
  - [ ] Test authorization (user vs admin)
  - [ ] Verify SQL injection protection
  - [ ] Test file upload restrictions

## 📦 Deployment Steps

### 1. Pre-Deployment
```bash
# Build in Release mode
dotnet build -c Release

# Run tests (if available)
dotnet test

# Publish application
dotnet publish -c Release -o ./publish
```

### 2. Environment Setup
- [ ] Create database (if new)
- [ ] Configure environment variables
- [ ] Setup SSL certificate
- [ ] Configure firewall rules

### 3. Database Migration
```bash
# Option 1: Using existing database
# Just update connection string

# Option 2: New database with migrations
dotnet ef database update --context ApplicationDbContext
```

### 4. Deploy Application
- [ ] Deploy published files
- [ ] Verify app starts successfully
- [ ] Check application logs
- [ ] Test endpoints

### 5. Post-Deployment
- [ ] Verify HTTPS working
- [ ] Test login endpoint
- [ ] Check database connectivity
- [ ] Monitor error logs
- [ ] Test email sending

## 🔍 Verification Tests

After deployment, test these endpoints:

### 1. Health Check
```bash
curl https://your-domain.com/api/Auth/login -I
# Should return 405 Method Not Allowed (because it needs POST)
```

### 2. Login Test
```bash
curl -X POST https://your-domain.com/api/Auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@example.com","password":"your-password"}'
# Should return JWT token
```

### 3. Authenticated Request
```bash
curl https://your-domain.com/api/Auth/validate-token \
  -H "Authorization: Bearer <your-jwt-token>"
# Should return user profile
```

## 🚨 Rollback Plan

If deployment fails:

1. **Database Rollback**
   ```bash
   # Restore from backup
   RESTORE DATABASE mydatabase FROM DISK = 'C:\Backups\mydatabase.bak'
   ```

2. **Application Rollback**
   - Redeploy previous version
   - Or revert to previous Docker container

3. **Notify Users**
   - Update status page
   - Send notification to users

## 📝 Post-Deployment Tasks

- [ ] **Monitor Application**
  - [ ] Check CPU/Memory usage
  - [ ] Monitor request rates
  - [ ] Watch error logs
  - [ ] Verify database connections

- [ ] **Update Documentation**
  - [ ] Document deployment date
  - [ ] Update API documentation
  - [ ] Note any issues encountered

- [ ] **Stakeholder Communication**
  - [ ] Notify team of successful deployment
  - [ ] Share deployment notes
  - [ ] Schedule retrospective

## 🔧 Common Issues & Solutions

### Issue: "Cannot connect to database"
**Solutions:**
- Verify connection string is correct
- Check firewall rules
- Verify SQL Server is running
- Check network connectivity

### Issue: "JWT validation failed"
**Solutions:**
- Verify JWT Key is same across servers
- Check token expiry settings
- Verify Issuer and Audience match

### Issue: "Email sending failed"
**Solutions:**
- Verify SMTP credentials
- Check port is not blocked (587)
- Test SMTP connection manually
- Verify TLS is enabled

### Issue: "CORS errors"
**Solutions:**
- Update CORS policy to include your domain
- Verify HTTPS is configured correctly
- Check browser console for exact error

## 📞 Emergency Contacts

- **Database Admin:** [Name/Contact]
- **DevOps Lead:** [Name/Contact]
- **Project Manager:** [Name/Contact]
- **Support Team:** [Email/Phone]

## 🎯 Success Criteria

Deployment is successful when:
- [x] Application is accessible via HTTPS
- [x] Users can login successfully
- [x] All API endpoints respond correctly
- [x] No critical errors in logs
- [x] Database connectivity verified
- [x] Email functionality working
- [x] Performance meets requirements

---

**Last Updated:** [Add date when deploying]
**Deployed By:** [Add name]
**Environment:** [Production/Staging/Development]
