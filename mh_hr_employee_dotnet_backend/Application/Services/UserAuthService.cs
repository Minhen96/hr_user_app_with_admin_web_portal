using Microsoft.Extensions.Logging;
using React.Core.DTOs.Response;
using React.Core.Interfaces.Repositories;
using React.Core.Interfaces.Services;
using React.DTOs;
using React.Models;
using React.Shared.Results;

namespace React.Application.Services;

public class UserAuthService : IUserAuthService
{
    private readonly IUserAuthRepository _repository;
    private readonly IPasswordHasher _passwordHasher;
    private readonly IJwtTokenGenerator _jwtTokenGenerator;
    private readonly ILogger<UserAuthService> _logger;

    public UserAuthService(
        IUserAuthRepository repository,
        IPasswordHasher passwordHasher,
        IJwtTokenGenerator jwtTokenGenerator,
        ILogger<UserAuthService> logger)
    {
        _repository = repository ?? throw new ArgumentNullException(nameof(repository));
        _passwordHasher = passwordHasher ?? throw new ArgumentNullException(nameof(passwordHasher));
        _jwtTokenGenerator = jwtTokenGenerator ?? throw new ArgumentNullException(nameof(jwtTokenGenerator));
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));
    }

    public async Task<ServiceResult<bool>> UpdateFCMTokenAsync(int userId, string token)
    {
        try
        {
            var user = await _repository.GetUserByIdAsync(userId);
            if (user == null)
            {
                _logger.LogWarning("User with ID {UserId} not found.", userId);
                return ServiceResult<bool>.Failure("User not found");
            }

            user.FcmToken = token;
            await _repository.UpdateUserAsync(user);
            await _repository.SaveChangesAsync();

            _logger.LogInformation("Successfully updated FCM token for user ID {UserId}.", userId);
            return ServiceResult<bool>.Success(true, "FCM token updated successfully");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error updating FCM token for user ID {UserId}.", userId);
            return ServiceResult<bool>.Failure($"Error updating FCM token: {ex.Message}");
        }
    }

    public async Task<ServiceResult<UserProfileDto>> ValidateTokenAsync(int userId)
    {
        try
        {
            var user = await _repository.GetUserByIdAsync(userId);
            if (user == null)
            {
                return ServiceResult<UserProfileDto>.Failure("User not found");
            }

            if (user.active_status != "active")
            {
                return ServiceResult<UserProfileDto>.Failure("User account is not active");
            }

            var profileDto = MapToUserProfileDto(user);
            return ServiceResult<UserProfileDto>.Success(profileDto);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Token validation failed");
            return ServiceResult<UserProfileDto>.Failure($"Token validation error: {ex.Message}");
        }
    }

    public async Task<ServiceResult<UserProfileDto>> GetUserProfileAsync(int userId)
    {
        try
        {
            var user = await _repository.GetUserByIdAsync(userId);
            if (user == null)
            {
                return ServiceResult<UserProfileDto>.Failure("User not found");
            }

            var profileDto = MapToUserProfileDto(user);
            return ServiceResult<UserProfileDto>.Success(profileDto);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Profile retrieval failed");
            return ServiceResult<UserProfileDto>.Failure($"Error retrieving profile: {ex.Message}");
        }
    }

    public async Task<ServiceResult<string>> GetUserNicknameAsync(int userId)
    {
        try
        {
            var user = await _repository.GetUserByIdAsync(userId);
            if (user == null)
            {
                return ServiceResult<string>.Failure("User not found");
            }

            var displayName = !string.IsNullOrEmpty(user.nickname) ? user.nickname : user.FullName;
            return ServiceResult<string>.Success(displayName);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving user nickname");
            return ServiceResult<string>.Failure($"Error retrieving nickname: {ex.Message}");
        }
    }

    public async Task<ServiceResult<UserStatusDto>> GetUserStatusAsync(int userId)
    {
        try
        {
            var user = await _repository.GetUserByIdAsync(userId);
            if (user == null)
            {
                return ServiceResult<UserStatusDto>.Failure("User not found");
            }

            var statusDto = new UserStatusDto
            {
                ActiveStatus = user.active_status,
                Timestamp = DateTime.UtcNow
            };

            return ServiceResult<UserStatusDto>.Success(statusDto);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error checking user status for userId: {UserId}", userId);
            return ServiceResult<UserStatusDto>.Failure($"Error retrieving status: {ex.Message}");
        }
    }

    public async Task<ServiceResult<bool>> RegisterAsync(RegisterModel model)
    {
        try
        {
            _logger.LogInformation($"Registration attempt for email: {model.Email}");

            var existingUser = await _repository.UserExistsAsync(model.Email, model.NRIC, model.TIN, model.EPFNo);
            if (existingUser)
            {
                return ServiceResult<bool>.Failure("User with these details already exists");
            }

            var departmentExists = await _repository.DepartmentExistsAsync(model.DepartmentId);
            if (!departmentExists)
            {
                return ServiceResult<bool>.Failure("Invalid department selection");
            }

            var hashedPassword = _passwordHasher.HashPassword(model.Password);

            var user = new User
            {
                FullName = model.FullName.Trim(),
                Email = model.Email.ToLower().Trim(),
                Birthday = model.Birthday,
                Password = hashedPassword,
                DepartmentId = model.DepartmentId,
                NRIC = model.NRIC.Trim(),
                contactNumber = model.contactNumber,
                TIN = string.IsNullOrWhiteSpace(model.TIN?.Trim()) ? null : model.TIN.Trim(),
                EPFNo = string.IsNullOrWhiteSpace(model.EPFNo?.Trim()) ? null : model.EPFNo.Trim(),
                Role = "user",
                Status = "active",
                active_status = "inactive",
                DateJoined = DateTime.UtcNow
            };

            await _repository.AddUserAsync(user);
            await _repository.SaveChangesAsync();

            return ServiceResult<bool>.Success(true, "Registration successful!");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Registration failed, Exception: {ex.Message}");
            return ServiceResult<bool>.Failure($"Registration error: {ex.Message}");
        }
    }

    public async Task<ServiceResult<LoginResponse>> LoginAsync(LoginModel model)
    {
        try
        {
            _logger.LogInformation($"Login attempt for email: {model.Email}");

            if (string.IsNullOrEmpty(model.Email) || string.IsNullOrEmpty(model.Password))
            {
                _logger.LogWarning("Login failed: Empty email or password");
                return ServiceResult<LoginResponse>.Failure("Email and password are required");
            }

            var user = await _repository.GetUserByEmailAsync(model.Email);
            if (user == null)
            {
                _logger.LogWarning($"Login failed: Email {model.Email} not found");
                return ServiceResult<LoginResponse>.Failure("Invalid credentials");
            }

            if (user.active_status != "active")
            {
                _logger.LogWarning($"Login failed: User {model.Email} is not active");
                return ServiceResult<LoginResponse>.Failure("Your account is not active. Please contact the administrator.");
            }

            if (!_passwordHasher.VerifyPassword(model.Password, user.Password))
            {
                _logger.LogWarning($"Login failed: Invalid credentials");
                return ServiceResult<LoginResponse>.Failure("Invalid credentials");
            }

            var loginResponseDto = new LoginResponseDto
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

            var token = _jwtTokenGenerator.GenerateToken(loginResponseDto);
            _logger.LogInformation($"Login successful for email: {model.Email}");

            var loginResponse = new LoginResponse
            {
                Success = true,
                Token = token,
                User = new UserInfo
                {
                    Id = user.Id,
                    FullName = user.FullName,
                    NickName = user.FullName.Split(' ')[0],
                    Email = user.Email,
                    NRIC = user.NRIC,
                    TIN = user.TIN,
                    EPF = user.EPFNo,
                    Status = user.Status,
                    Role = user.Role,
                    Department = user.Department != null ? new DepartmentInfo
                    {
                        Id = user.Department.Id,
                        Name = user.Department.Name
                    } : null,
                    Birthday = user.Birthday,
                    DateJoined = user.DateJoined,
                    ChangePasswordDate = user.ChangePasswordDate,
                    FCMToken = user.FcmToken
                }
            };

            return ServiceResult<LoginResponse>.Success(loginResponse);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Login failed");
            return ServiceResult<LoginResponse>.Failure($"Login error: {ex.Message}");
        }
    }

    public async Task<ServiceResult<bool>> UpdateNicknameAsync(int userId, string nickname)
    {
        try
        {
            var user = await _repository.GetUserByIdAsync(userId);
            if (user == null)
            {
                return ServiceResult<bool>.Failure("User not found");
            }

            user.nickname = nickname;
            await _repository.SaveChangesAsync();

            return ServiceResult<bool>.Success(true, "Nickname updated successfully");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error updating nickname");
            return ServiceResult<bool>.Failure($"Error updating nickname: {ex.Message}");
        }
    }

    public async Task<ServiceResult<bool>> UpdateContactAsync(int userId, string contactNumber)
    {
        try
        {
            var user = await _repository.GetUserByIdAsync(userId);
            if (user == null)
            {
                return ServiceResult<bool>.Failure("User not found");
            }

            user.contactNumber = contactNumber;
            await _repository.SaveChangesAsync();

            return ServiceResult<bool>.Success(true, "Contact number updated successfully");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error updating contact number");
            return ServiceResult<bool>.Failure($"Error updating contact: {ex.Message}");
        }
    }

    public async Task<ServiceResult<bool>> UploadProfilePictureAsync(int userId, byte[] profilePicture)
    {
        try
        {
            var user = await _repository.GetUserByIdAsync(userId);
            if (user == null)
            {
                return ServiceResult<bool>.Failure("User not found");
            }

            user.profile_picture = profilePicture;
            await _repository.SaveChangesAsync();

            return ServiceResult<bool>.Success(true, "Profile picture uploaded successfully");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error uploading profile picture");
            return ServiceResult<bool>.Failure($"Error uploading profile picture: {ex.Message}");
        }
    }

    public async Task<ServiceResult<bool>> RequestPasswordChangeAsync(int userId)
    {
        try
        {
            var user = await _repository.GetUserByIdAsync(userId);
            if (user == null)
            {
                return ServiceResult<bool>.Failure("User not found");
            }

            user.Status = "pending";
            await _repository.SaveChangesAsync();

            return ServiceResult<bool>.Success(true, "Password change request submitted successfully");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Password change request failed");
            return ServiceResult<bool>.Failure($"Error requesting password change: {ex.Message}");
        }
    }

    public async Task<ServiceResult<bool>> ChangePasswordAsync(int userId, string currentPassword, string newPassword)
    {
        try
        {
            var user = await _repository.GetUserByIdAsync(userId);
            if (user == null)
            {
                return ServiceResult<bool>.Failure("User not found");
            }

            if (!_passwordHasher.VerifyPassword(currentPassword, user.Password))
            {
                return ServiceResult<bool>.Failure("Current password is incorrect");
            }

            user.Password = _passwordHasher.HashPassword(newPassword);
            user.ChangePasswordDate = DateTime.UtcNow;
            user.Status = "active";

            await _repository.UpdateUserAsync(user);
            await _repository.SaveChangesAsync();

            return ServiceResult<bool>.Success(true, "Password changed successfully");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Password change failed");
            return ServiceResult<bool>.Failure($"Error changing password: {ex.Message}");
        }
    }

    public async Task<ServiceResult<string>> GetUsernameByAnnualLeaveIdAsync(int annualLeaveId)
    {
        try
        {
            var username = await _repository.GetUsernameByAnnualLeaveIdAsync(annualLeaveId);
            if (username == null)
            {
                return ServiceResult<string>.Failure("Username not found");
            }

            return ServiceResult<string>.Success(username);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving username by annual leave ID");
            return ServiceResult<string>.Failure($"Error retrieving username: {ex.Message}");
        }
    }

    private UserProfileDto MapToUserProfileDto(User user)
    {
        return new UserProfileDto
        {
            Id = user.Id,
            FullName = user.FullName,
            Email = user.Email,
            ProfilePicture = user.profile_picture,
            Birthday = user.Birthday,
            Password = user.Password,
            NRIC = user.NRIC,
            TIN = user.TIN,
            EPF = user.EPFNo,
            Role = user.Role,
            Status = user.Status,
            ActiveStatus = user.active_status,
            Department = user.Department != null ? new DepartmentInfo
            {
                Id = user.Department.Id,
                Name = user.Department.Name
            } : null,
            Nickname = user.nickname,
            ContactNumber = user.contactNumber,
            DateJoined = user.DateJoined,
            ChangePasswordDate = user.ChangePasswordDate
        };
    }
}
