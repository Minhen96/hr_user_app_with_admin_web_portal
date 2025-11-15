using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using React.Core.Interfaces.Services;
using React.DTOs;
using System.Security.Claims;

namespace React.API.Controllers;

[ApiController]
[Route("api/Auth")]
public class UserAuthController : ControllerBase
{
    private readonly IUserAuthService _userAuthService;
    private readonly ILogger<UserAuthController> _logger;

    public UserAuthController(IUserAuthService userAuthService, ILogger<UserAuthController> logger)
    {
        _userAuthService = userAuthService ?? throw new ArgumentNullException(nameof(userAuthService));
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));
    }

    private int GetCurrentUserId()
    {
        var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier);
        if (userIdClaim == null)
        {
            throw new UnauthorizedAccessException("User ID not found in token");
        }
        return int.Parse(userIdClaim.Value);
    }

    [HttpPost("fcm-token")]
    [Authorize]
    public async Task<IActionResult> UpdateFCMToken([FromBody] FCMTokenRequest request)
    {
        if (request == null || string.IsNullOrEmpty(request.Token))
        {
            _logger.LogWarning("FCM token request is invalid or token is empty.");
            return BadRequest(new { message = "FCM token is required." });
        }

        try
        {
            var userId = GetCurrentUserId();
            var result = await _userAuthService.UpdateFCMTokenAsync(userId, request.Token);

            return result.IsSuccess
                ? Ok(new { message = result.Message })
                : NotFound(new { message = result.Message });
        }
        catch (UnauthorizedAccessException)
        {
            return Unauthorized(new { message = "User is not authenticated." });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Unexpected error while updating FCM token.");
            return StatusCode(500, new { message = "An unexpected error occurred." });
        }
    }

    [HttpGet("validate-token")]
    [Authorize]
    public async Task<IActionResult> ValidateToken()
    {
        try
        {
            var userId = GetCurrentUserId();
            var result = await _userAuthService.ValidateTokenAsync(userId);

            if (!result.IsSuccess)
            {
                return Unauthorized(new
                {
                    valid = false,
                    error = result.Message
                });
            }

            var profile = result.Data!;
            return Ok(new
            {
                valid = true,
                user = new
                {
                    id = profile.Id,
                    fullName = profile.FullName,
                    nickName = profile.FullName.Split(' ')[0],
                    email = profile.Email,
                    nric = profile.NRIC,
                    tin = profile.TIN,
                    epf = profile.EPF,
                    status = profile.Status,
                    role = profile.Role,
                    department = profile.Department,
                    birthday = profile.Birthday,
                    dateJoined = profile.DateJoined,
                    changePasswordDate = profile.ChangePasswordDate
                }
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Token validation failed");
            return StatusCode(500, new
            {
                valid = false,
                error = "Internal server error"
            });
        }
    }

    [HttpGet("profile")]
    [Authorize]
    public async Task<IActionResult> GetUserProfile()
    {
        try
        {
            var userId = GetCurrentUserId();
            var result = await _userAuthService.GetUserProfileAsync(userId);

            if (!result.IsSuccess)
            {
                return Unauthorized(new { error = result.Message });
            }

            var profile = result.Data!;
            return Ok(new
            {
                success = true,
                user = new
                {
                    id = profile.Id,
                    fullName = profile.FullName,
                    email = profile.Email,
                    profilePicture = profile.ProfilePicture,
                    birthday = profile.Birthday,
                    password = profile.Password,
                    nric = profile.NRIC,
                    tin = profile.TIN,
                    epf = profile.EPF,
                    role = profile.Role,
                    status = profile.Status,
                    active_status = profile.ActiveStatus,
                    department = profile.Department,
                    nickname = profile.Nickname,
                    contactNumber = profile.ContactNumber
                }
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Profile retrieval failed");
            return StatusCode(500, new { error = "Internal server error" });
        }
    }

    [HttpGet("nickname/{userId}")]
    public async Task<IActionResult> GetUserNickname(int userId)
    {
        try
        {
            var result = await _userAuthService.GetUserNicknameAsync(userId);

            return result.IsSuccess
                ? Ok(new { displayName = result.Data })
                : NotFound(new { message = result.Message });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving user nickname");
            return StatusCode(500, new { message = "Internal server error" });
        }
    }

    [HttpGet("status/{userId}")]
    public async Task<IActionResult> GetUserStatus(int userId)
    {
        try
        {
            var result = await _userAuthService.GetUserStatusAsync(userId);

            return result.IsSuccess
                ? Ok(result.Data)
                : NotFound(new { message = result.Message });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error checking user status for userId: {UserId}", userId);
            return StatusCode(500, new { message = "Internal server error" });
        }
    }

    [HttpPost("register")]
    public async Task<IActionResult> Register([FromBody] RegisterModel model)
    {
        try
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var result = await _userAuthService.RegisterAsync(model);

            return result.IsSuccess
                ? CreatedAtAction(nameof(Login), new { success = true, message = result.Message })
                : BadRequest(new { error = result.Message });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Registration failed, Exception: {ex.Message}");
            return StatusCode(500, new { error = "Internal server error" });
        }
    }

    [HttpPost("login")]
    public async Task<IActionResult> Login([FromBody] LoginModel model)
    {
        try
        {
            var result = await _userAuthService.LoginAsync(model);

            if (!result.IsSuccess)
            {
                return Unauthorized(new { error = result.Message });
            }

            var loginResponse = result.Data!;
            return Ok(new
            {
                success = loginResponse.Success,
                token = loginResponse.Token,
                user = loginResponse.User
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Login failed");
            return StatusCode(500, new { error = "Internal server error" });
        }
    }

    [HttpPut("update-nickname")]
    [Authorize]
    public async Task<IActionResult> UpdateNickname([FromBody] UpdateNicknameRequest request)
    {
        try
        {
            var userId = GetCurrentUserId();
            var result = await _userAuthService.UpdateNicknameAsync(userId, request.Nickname);

            return result.IsSuccess
                ? Ok(new { message = result.Message })
                : NotFound(result.Message);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error updating nickname");
            return StatusCode(500, "Internal server error");
        }
    }

    [HttpPut("update-contact")]
    [Authorize]
    public async Task<IActionResult> UpdateContact([FromBody] UpdateContactRequest request)
    {
        try
        {
            var userId = GetCurrentUserId();
            var result = await _userAuthService.UpdateContactAsync(userId, request.ContactNumber);

            return result.IsSuccess
                ? Ok(new { message = result.Message })
                : NotFound(result.Message);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error updating contact number");
            return StatusCode(500, "Internal server error");
        }
    }

    [HttpPost("upload-profile-picture")]
    [Authorize]
    public async Task<IActionResult> UploadProfilePicture(IFormFile file)
    {
        if (file == null || file.Length == 0)
        {
            return BadRequest(new { error = "No file uploaded" });
        }

        try
        {
            var userId = GetCurrentUserId();

            byte[] profilePicture;
            using (var memoryStream = new MemoryStream())
            {
                await file.CopyToAsync(memoryStream);
                profilePicture = memoryStream.ToArray();
            }

            var result = await _userAuthService.UploadProfilePictureAsync(userId, profilePicture);

            return result.IsSuccess
                ? Ok(new { success = true, message = result.Message })
                : NotFound(new { error = result.Message });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error uploading profile picture");
            return StatusCode(500, new { error = "Internal server error" });
        }
    }

    [HttpPost("request-password-change")]
    [Authorize]
    public async Task<IActionResult> RequestPasswordChange()
    {
        try
        {
            var userId = GetCurrentUserId();
            var result = await _userAuthService.RequestPasswordChangeAsync(userId);

            return result.IsSuccess
                ? Ok(new { message = result.Message })
                : NotFound(new { error = result.Message });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Password change request failed");
            return StatusCode(500, new { error = "Internal server error" });
        }
    }

    [HttpPost("change-password")]
    [Authorize]
    public async Task<IActionResult> ChangePassword([FromBody] ChangePasswordDTO model)
    {
        try
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var userId = GetCurrentUserId();
            var result = await _userAuthService.ChangePasswordAsync(userId, model.CurrentPassword, model.NewPassword);

            return result.IsSuccess
                ? Ok(new { message = result.Message })
                : BadRequest(new { error = result.Message });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Password change failed");
            return StatusCode(500, new { error = "Internal server error" });
        }
    }

    [HttpGet("username/{annualLeaveId}")]
    public async Task<IActionResult> GetUsernameByAnnualLeaveId(int annualLeaveId)
    {
        try
        {
            var result = await _userAuthService.GetUsernameByAnnualLeaveIdAsync(annualLeaveId);

            return result.IsSuccess
                ? Ok(result.Data)
                : NotFound();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving username by annual leave ID");
            return StatusCode(500, "Internal server error");
        }
    }

    public class FCMTokenRequest
    {
        public string Token { get; set; } = string.Empty;
    }

    public class UpdateNicknameRequest
    {
        public string Nickname { get; set; } = string.Empty;
    }

    public class UpdateContactRequest
    {
        public string ContactNumber { get; set; } = string.Empty;
    }
}
