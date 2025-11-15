using React.Core.DTOs.Response;

namespace React.Core.Interfaces.Services;

/// <summary>
/// Interface for JWT token generation
/// </summary>
public interface IJwtTokenGenerator
{
    /// <summary>
    /// Generate JWT token for authenticated user
    /// </summary>
    string GenerateToken(LoginResponseDto user);
}
