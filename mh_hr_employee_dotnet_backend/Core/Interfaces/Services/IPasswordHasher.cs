namespace React.Core.Interfaces.Services;

/// <summary>
/// Interface for password hashing operations
/// </summary>
public interface IPasswordHasher
{
    /// <summary>
    /// Hash a plain text password using SHA256
    /// </summary>
    string HashPassword(string password);

    /// <summary>
    /// Verify a plain text password against a hashed password
    /// </summary>
    bool VerifyPassword(string providedPassword, string storedHash);
}
