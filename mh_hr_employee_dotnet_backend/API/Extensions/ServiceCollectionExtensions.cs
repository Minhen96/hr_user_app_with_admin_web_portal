using React.Application.Helpers;
using React.Application.Services;
using React.Core.Interfaces.Repositories;
using React.Core.Interfaces.Services;
using React.Infrastructure.Repositories;

namespace React.API.Extensions;

/// <summary>
/// Extension methods for IServiceCollection to register application services
/// </summary>
public static class ServiceCollectionExtensions
{
    /// <summary>
    /// Register all application services
    /// </summary>
    public static IServiceCollection AddApplicationServices(this IServiceCollection services)
    {
        // Core business services - Clean Architecture
        services.AddScoped<IAuthService, AuthService>();
        services.AddScoped<ILeaveService, LeaveService>();
        services.AddScoped<IUserLeaveService, UserLeaveService>();
        services.AddScoped<IAttendanceService, AttendanceService>();
        services.AddScoped<IUserManagementService, UserManagementService>();
        services.AddScoped<ITrainingService, TrainingService>();
        services.AddScoped<IStaffService, StaffService>();
        services.AddScoped<IDocumentService, DocumentService>();

        // Equipment and Change Management services
        services.AddScoped<IEquipmentRequestService, EquipmentRequestService>();
        services.AddScoped<IEquipmentReturnService, EquipmentReturnService>();
        services.AddScoped<IChangeRequestService, ChangeRequestService>();
        services.AddScoped<IUserChangeRequestService, UserChangeRequestService>();
        services.AddScoped<IChangeReturnService, ChangeReturnService>();

        // Reporting services
        services.AddScoped<ILeaveReportService, LeaveReportService>();

        // Content Management services
        services.AddScoped<IBirthdayService, BirthdayService>();
        services.AddScoped<IHolidayService, HolidayService>();
        services.AddScoped<IHandbookService, HandbookService>();

        // Notification services
        services.AddScoped<INotificationService, NotificationService>();

        // Medical Certificate services
        services.AddScoped<IMedicalCertificateService, MedicalCertificateService>();

        // Event services
        services.AddScoped<IUserEventService, UserEventService>();

        // Moment services
        services.AddScoped<IUserMomentService, UserMomentService>();

        // User Document services
        services.AddScoped<IUserDocumentService, UserDocumentService>();

        // User Auth services
        services.AddScoped<IUserAuthService, UserAuthService>();

        return services;
    }

    /// <summary>
    /// Register all repository implementations
    /// </summary>
    public static IServiceCollection AddRepositories(this IServiceCollection services)
    {
        // Data access repositories - Clean Architecture
        services.AddScoped<IUserRepository, UserRepository>();
        services.AddScoped<ILeaveRepository, LeaveRepository>();
        services.AddScoped<IUserLeaveRepository, UserLeaveRepository>();
        services.AddScoped<IAttendanceRepository, AttendanceRepository>();
        services.AddScoped<ITrainingRepository, TrainingRepository>();
        services.AddScoped<IStaffRepository, StaffRepository>();
        services.AddScoped<IDocumentRepository, DocumentRepository>();

        // Equipment and Change Management repositories
        services.AddScoped<IEquipmentRequestRepository, EquipmentRequestRepository>();
        services.AddScoped<IEquipmentReturnRepository, EquipmentReturnRepository>();
        services.AddScoped<IChangeRequestRepository, ChangeRequestRepository>();
        services.AddScoped<IUserChangeRequestRepository, UserChangeRequestRepository>();
        services.AddScoped<IChangeReturnRepository, ChangeReturnRepository>();

        // Reporting repositories
        services.AddScoped<ILeaveReportRepository, LeaveReportRepository>();

        // Content Management repositories
        services.AddScoped<IBirthdayRepository, BirthdayRepository>();
        services.AddScoped<IHolidayRepository, HolidayRepository>();
        services.AddScoped<IHandbookRepository, HandbookRepository>();

        // Notification repositories
        services.AddScoped<INotificationRepository, NotificationRepository>();

        // Medical Certificate repositories
        services.AddScoped<IMedicalCertificateRepository, MedicalCertificateRepository>();

        // Event repositories
        services.AddScoped<IUserEventRepository, UserEventRepository>();

        // Moment repositories
        services.AddScoped<IUserMomentRepository, UserMomentRepository>();

        // User Document repositories
        services.AddScoped<IUserDocumentRepository, UserDocumentRepository>();

        // User Auth repositories
        services.AddScoped<IUserAuthRepository, UserAuthRepository>();

        return services;
    }

    /// <summary>
    /// Register helper/utility services
    /// </summary>
    public static IServiceCollection AddHelpers(this IServiceCollection services)
    {
        services.AddScoped<IPasswordHasher, PasswordHasher>();
        services.AddScoped<IJwtTokenGenerator, JwtTokenGenerator>();

        return services;
    }
}
