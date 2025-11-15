using React.Models;

namespace React.Core.Interfaces.Repositories;

/// <summary>
/// Repository interface for user authentication data access operations
/// </summary>
public interface IUserAuthRepository
{
    /// <summary>
    /// Gets user by ID with department
    /// </summary>
    Task<User?> GetUserByIdAsync(int userId);

    /// <summary>
    /// Gets user by email with department
    /// </summary>
    Task<User?> GetUserByEmailAsync(string email);

    /// <summary>
    /// Checks if user exists by email, NRIC, TIN, or EPF
    /// </summary>
    Task<bool> UserExistsAsync(string email, string nric, string? tin, string? epfNo);

    /// <summary>
    /// Checks if department exists
    /// </summary>
    Task<bool> DepartmentExistsAsync(int departmentId);

    /// <summary>
    /// Adds a new user
    /// </summary>
    Task<User> AddUserAsync(User user);

    /// <summary>
    /// Updates an existing user
    /// </summary>
    Task UpdateUserAsync(User user);

    /// <summary>
    /// Gets username by annual leave ID
    /// </summary>
    Task<string?> GetUsernameByAnnualLeaveIdAsync(int annualLeaveId);

    /// <summary>
    /// Saves changes to the database
    /// </summary>
    Task SaveChangesAsync();
}
