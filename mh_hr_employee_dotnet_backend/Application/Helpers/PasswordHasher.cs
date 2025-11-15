using System.Security.Cryptography;
using System.Text;
using React.Core.Interfaces.Services;

namespace React.Application.Helpers;

/// <summary>
/// Implementation of password hashing using SHA256 to match SQL Server HASHBYTES
/// </summary>
public class PasswordHasher : IPasswordHasher
{
    /// <summary>
    /// Hash a password using SHA256 algorithm (matches SQL Server's HASHBYTES output)
    /// </summary>
    public string HashPassword(string password)
    {
        if (string.IsNullOrWhiteSpace(password))
            throw new ArgumentException("Password cannot be null or empty", nameof(password));

        using var sha256 = SHA256.Create();

        // Convert the password string to bytes
        byte[] passwordBytes = Encoding.UTF8.GetBytes(password);

        // Compute the hash
        byte[] hashBytes = sha256.ComputeHash(passwordBytes);

        // Convert the hash to a lowercase hex string to match SQL Server's HASHBYTES output
        return string.Concat(hashBytes.Select(b => b.ToString("x2")));
    }

    /// <summary>
    /// Verify a provided password against a stored hash
    /// </summary>
    public bool VerifyPassword(string providedPassword, string storedHash)
    {
        if (string.IsNullOrWhiteSpace(providedPassword))
            return false;

        if (string.IsNullOrWhiteSpace(storedHash))
            return false;

        string hashedProvidedPassword = HashPassword(providedPassword);
        return string.Equals(hashedProvidedPassword, storedHash, StringComparison.OrdinalIgnoreCase);
    }
}
