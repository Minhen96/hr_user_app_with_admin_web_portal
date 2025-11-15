using React.Core.DTOs.Response;
using React.Models;

namespace React.Core.Interfaces.Repositories;

/// <summary>
/// Repository interface for User entity data access operations
/// </summary>
public interface IUserRepository
{
    /// <summary>
    /// Get user by email address
    /// </summary>
    Task<User?> GetByEmailAsync(string email);

    /// <summary>
    /// Get user by ID
    /// </summary>
    Task<User?> GetByIdAsync(int id);

    /// <summary>
    /// Get all users with pending password change requests
    /// </summary>
    Task<IEnumerable<PasswordChangeResponseDto>> GetPendingPasswordChangesAsync();

    /// <summary>
    /// Update password change status (approve/reject)
    /// </summary>
    Task<bool> UpdatePasswordStatusAsync(int userId, string status, int approverId, DateTime dateApproved);

    /// <summary>
    /// Get current password status for a user
    /// </summary>
    Task<string?> GetUserPasswordStatusAsync(int userId);

    /// <summary>
    /// Update user password
    /// </summary>
    Task<bool> UpdatePasswordAsync(int userId, string hashedPassword);
}
