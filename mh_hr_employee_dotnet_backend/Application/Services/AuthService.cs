using Microsoft.Extensions.Logging;
using React.Core.DTOs.Request;
using React.Core.DTOs.Response;
using React.Core.Interfaces.Repositories;
using React.Core.Interfaces.Services;
using React.Shared.Results;

namespace React.Application.Services;

/// <summary>
/// Service implementation for authentication and authorization business logic
/// </summary>
public class AuthService : IAuthService
{
    private readonly IUserRepository _userRepository;
    private readonly IPasswordHasher _passwordHasher;
    private readonly IJwtTokenGenerator _jwtTokenGenerator;
    private readonly ILogger<AuthService> _logger;

    public AuthService(
        IUserRepository userRepository,
        IPasswordHasher passwordHasher,
        IJwtTokenGenerator jwtTokenGenerator,
        ILogger<AuthService> logger)
    {
        _userRepository = userRepository ?? throw new ArgumentNullException(nameof(userRepository));
        _passwordHasher = passwordHasher ?? throw new ArgumentNullException(nameof(passwordHasher));
        _jwtTokenGenerator = jwtTokenGenerator ?? throw new ArgumentNullException(nameof(jwtTokenGenerator));
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));
    }

    public async Task<ServiceResult<LoginResponseDto>> LoginAsync(LoginRequestDto request)
    {
        try
        {
            // Validate input
            if (string.IsNullOrWhiteSpace(request.Email) || string.IsNullOrWhiteSpace(request.Password))
            {
                return ServiceResult<LoginResponseDto>.Failure("Email and password are required");
            }

            // Get user by email
            var user = await _userRepository.GetByEmailAsync(request.Email);
            if (user == null)
            {
                _logger.LogWarning("Login attempt failed: User not found for email {Email}", request.Email);
                return ServiceResult<LoginResponseDto>.Failure("Invalid email or password");
            }

            // Verify password
            string hashedPassword = _passwordHasher.HashPassword(request.Password);
            if (!string.Equals(user.Password, hashedPassword, StringComparison.OrdinalIgnoreCase))
            {
                _logger.LogWarning("Login attempt failed: Invalid password for email {Email}", request.Email);
                return ServiceResult<LoginResponseDto>.Failure("Invalid email or password");
            }

            // Create response DTO
            var response = new LoginResponseDto
            {
                Id = user.Id,
                FullName = user.FullName,
                Nric = user.NRIC,
                Tin = user.TIN,
                EpfNo = user.EPFNo,
                Email = user.Email,
                DepartmentId = user.DepartmentId,
                DepartmentName = user.Department?.Name ?? string.Empty,
                Role = user.Role,
                Status = user.Status
            };

            // Generate JWT token
            response.Token = _jwtTokenGenerator.GenerateToken(response);

            _logger.LogInformation("User {Email} logged in successfully", request.Email);
            return ServiceResult<LoginResponseDto>.Success(response, "Login successful");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error during login for email {Email}", request.Email);
            return ServiceResult<LoginResponseDto>.Failure("An error occurred during login");
        }
    }

    public async Task<ServiceResult> ChangePasswordAsync(ChangePasswordRequestDto request)
    {
        try
        {
            // Get user
            var user = await _userRepository.GetByIdAsync(request.UserId);
            if (user == null)
            {
                return ServiceResult.Failure("User not found");
            }

            // Verify old password
            if (!_passwordHasher.VerifyPassword(request.OldPassword, user.Password))
            {
                _logger.LogWarning("Password change failed: Invalid old password for user {UserId}", request.UserId);
                return ServiceResult.Failure("Old password is incorrect");
            }

            // Validate new password
            if (request.NewPassword != request.ConfirmPassword)
            {
                return ServiceResult.Failure("New password and confirm password do not match");
            }

            // Hash new password
            string newHashedPassword = _passwordHasher.HashPassword(request.NewPassword);

            // Update password
            bool success = await _userRepository.UpdatePasswordAsync(request.UserId, newHashedPassword);
            if (!success)
            {
                return ServiceResult.Failure("Failed to update password");
            }

            _logger.LogInformation("Password changed successfully for user {UserId}", request.UserId);
            return ServiceResult.Success("Password changed successfully");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error changing password for user {UserId}", request.UserId);
            return ServiceResult.Failure("An error occurred while changing password");
        }
    }

    public async Task<ServiceResult<IEnumerable<PasswordChangeResponseDto>>> GetPendingPasswordChangesAsync()
    {
        try
        {
            var pendingChanges = await _userRepository.GetPendingPasswordChangesAsync();
            return ServiceResult<IEnumerable<PasswordChangeResponseDto>>.Success(
                pendingChanges,
                "Pending password changes retrieved successfully"
            );
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving pending password changes");
            return ServiceResult<IEnumerable<PasswordChangeResponseDto>>.Failure(
                "An error occurred while retrieving pending password changes"
            );
        }
    }

    public async Task<ServiceResult> UpdatePasswordStatusAsync(int userId, UpdatePasswordStatusRequestDto request)
    {
        try
        {
            // Check if user exists and has pending status
            var currentStatus = await _userRepository.GetUserPasswordStatusAsync(userId);
            if (currentStatus == null)
            {
                return ServiceResult.Failure("User not found");
            }

            if (currentStatus != "pending")
            {
                return ServiceResult.Failure("Can only update pending status");
            }

            // Update status
            bool success = await _userRepository.UpdatePasswordStatusAsync(
                userId,
                request.Status,
                request.ApproverId,
                request.DateApproved
            );

            if (!success)
            {
                return ServiceResult.Failure("Failed to update password status");
            }

            _logger.LogInformation(
                "Password status updated to {Status} for user {UserId} by approver {ApproverId}",
                request.Status, userId, request.ApproverId
            );

            return ServiceResult.Success($"Password change request {request.Status} successfully");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error updating password status for user {UserId}", userId);
            return ServiceResult.Failure("An error occurred while updating password status");
        }
    }
}
