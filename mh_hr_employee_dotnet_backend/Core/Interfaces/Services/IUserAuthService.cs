using React.DTOs;
using React.Shared.Results;

namespace React.Core.Interfaces.Services;

/// <summary>
/// Service interface for user authentication and profile management operations
/// </summary>
public interface IUserAuthService
{
    /// <summary>
    /// Update user FCM token for push notifications
    /// </summary>
    Task<ServiceResult<bool>> UpdateFCMTokenAsync(int userId, string token);

    /// <summary>
    /// Validate JWT token and return user details
    /// </summary>
    Task<ServiceResult<UserProfileDto>> ValidateTokenAsync(int userId);

    /// <summary>
    /// Get user profile by user ID
    /// </summary>
    Task<ServiceResult<UserProfileDto>> GetUserProfileAsync(int userId);

    /// <summary>
    /// Get user nickname by user ID
    /// </summary>
    Task<ServiceResult<string>> GetUserNicknameAsync(int userId);

    /// <summary>
    /// Get user active status by user ID
    /// </summary>
    Task<ServiceResult<UserStatusDto>> GetUserStatusAsync(int userId);

    /// <summary>
    /// Register a new user
    /// </summary>
    Task<ServiceResult<bool>> RegisterAsync(RegisterModel model);

    /// <summary>
    /// Login user with email and password
    /// </summary>
    Task<ServiceResult<LoginResponse>> LoginAsync(LoginModel model);

    /// <summary>
    /// Update user nickname
    /// </summary>
    Task<ServiceResult<bool>> UpdateNicknameAsync(int userId, string nickname);

    /// <summary>
    /// Update user contact number
    /// </summary>
    Task<ServiceResult<bool>> UpdateContactAsync(int userId, string contactNumber);

    /// <summary>
    /// Upload user profile picture
    /// </summary>
    Task<ServiceResult<bool>> UploadProfilePictureAsync(int userId, byte[] profilePicture);

    /// <summary>
    /// Request password change (sets user status to pending)
    /// </summary>
    Task<ServiceResult<bool>> RequestPasswordChangeAsync(int userId);

    /// <summary>
    /// Change user password
    /// </summary>
    Task<ServiceResult<bool>> ChangePasswordAsync(int userId, string currentPassword, string newPassword);

    /// <summary>
    /// Get username by annual leave ID
    /// </summary>
    Task<ServiceResult<string>> GetUsernameByAnnualLeaveIdAsync(int annualLeaveId);
}

public class UserProfileDto
{
    public int Id { get; set; }
    public string FullName { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public byte[]? ProfilePicture { get; set; }
    public DateTime Birthday { get; set; }
    public string Password { get; set; } = string.Empty;
    public string NRIC { get; set; } = string.Empty;
    public string? TIN { get; set; }
    public string? EPF { get; set; }
    public string Role { get; set; } = string.Empty;
    public string Status { get; set; } = string.Empty;
    public string ActiveStatus { get; set; } = string.Empty;
    public DepartmentInfo? Department { get; set; }
    public string? Nickname { get; set; }
    public string? ContactNumber { get; set; }
    public DateTime? DateJoined { get; set; }
    public DateTime? ChangePasswordDate { get; set; }
}

public class DepartmentInfo
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
}

public class UserStatusDto
{
    public string ActiveStatus { get; set; } = string.Empty;
    public DateTime Timestamp { get; set; }
}

public class LoginResponse
{
    public bool Success { get; set; }
    public string Token { get; set; } = string.Empty;
    public UserInfo? User { get; set; }
}

public class UserInfo
{
    public int Id { get; set; }
    public string FullName { get; set; } = string.Empty;
    public string NickName { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string NRIC { get; set; } = string.Empty;
    public string? TIN { get; set; }
    public string? EPF { get; set; }
    public string Status { get; set; } = string.Empty;
    public string Role { get; set; } = string.Empty;
    public DepartmentInfo? Department { get; set; }
    public DateTime Birthday { get; set; }
    public DateTime? DateJoined { get; set; }
    public DateTime? ChangePasswordDate { get; set; }
    public string? FCMToken { get; set; }
}
