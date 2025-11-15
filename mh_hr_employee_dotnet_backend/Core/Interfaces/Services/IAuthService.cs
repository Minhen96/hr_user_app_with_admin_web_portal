using React.Core.DTOs.Request;
using React.Core.DTOs.Response;
using React.Shared.Results;

namespace React.Core.Interfaces.Services;

/// <summary>
/// Service interface for authentication and authorization operations
/// </summary>
public interface IAuthService
{
    /// <summary>
    /// Authenticate user with email and password
    /// </summary>
    Task<ServiceResult<LoginResponseDto>> LoginAsync(LoginRequestDto request);

    /// <summary>
    /// Change user password
    /// </summary>
    Task<ServiceResult> ChangePasswordAsync(ChangePasswordRequestDto request);

    /// <summary>
    /// Get all pending password change requests
    /// </summary>
    Task<ServiceResult<IEnumerable<PasswordChangeResponseDto>>> GetPendingPasswordChangesAsync();

    /// <summary>
    /// Approve or reject password change request
    /// </summary>
    Task<ServiceResult> UpdatePasswordStatusAsync(int userId, UpdatePasswordStatusRequestDto request);
}
