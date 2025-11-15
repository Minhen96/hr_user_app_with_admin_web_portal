using Microsoft.AspNetCore.Mvc;
using React.Core.DTOs.Request;
using React.Core.Interfaces.Services;

namespace React.API.Controllers;

/// <summary>
/// Controller for authentication operations (login, password management)
/// </summary>
[ApiController]
[Route("admin/api/[controller]")]
public class AuthController : ControllerBase
{
    private readonly IAuthService _authService;
    private readonly ILogger<AuthController> _logger;

    public AuthController(IAuthService authService, ILogger<AuthController> logger)
    {
        _authService = authService ?? throw new ArgumentNullException(nameof(authService));
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));
    }

    /// <summary>
    /// Authenticate user with email and password
    /// POST: admin/api/auth/login
    /// </summary>
    [HttpPost("login")]
    [ProducesResponseType(typeof(object), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(object), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(object), StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> Login([FromBody] LoginRequestDto request)
    {
        if (!ModelState.IsValid)
        {
            return BadRequest(new { success = false, message = "Invalid input", errors = ModelState });
        }

        var result = await _authService.LoginAsync(request);

        if (!result.IsSuccess)
        {
            return Unauthorized(new { success = false, message = result.Message });
        }

        return Ok(new { success = true, user = result.Data });
    }

    /// <summary>
    /// Change user password
    /// PUT: admin/api/auth/change-password
    /// </summary>
    [HttpPut("change-password")]
    [ProducesResponseType(typeof(object), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(object), StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> ChangePassword([FromBody] ChangePasswordRequestDto request)
    {
        if (!ModelState.IsValid)
        {
            return BadRequest(new { success = false, message = "Invalid input", errors = ModelState });
        }

        var result = await _authService.ChangePasswordAsync(request);

        if (!result.IsSuccess)
        {
            return BadRequest(new { success = false, message = result.Message });
        }

        return Ok(new { success = true, message = result.Message });
    }

    /// <summary>
    /// Get all pending password change requests
    /// GET: admin/api/auth/password-changes
    /// </summary>
    [HttpGet("password-changes")]
    [ProducesResponseType(typeof(object), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(object), StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> GetPendingPasswordChanges()
    {
        var result = await _authService.GetPendingPasswordChangesAsync();

        if (!result.IsSuccess)
        {
            return StatusCode(StatusCodes.Status500InternalServerError,
                new { success = false, message = result.Message });
        }

        return Ok(result.Data);
    }

    /// <summary>
    /// Approve or reject password change request
    /// PUT: admin/api/auth/{userId}/password-status
    /// </summary>
    [HttpPut("{userId}/password-status")]
    [ProducesResponseType(typeof(object), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(object), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(object), StatusCodes.Status404NotFound)]
    public async Task<IActionResult> UpdatePasswordStatus(
        int userId,
        [FromBody] UpdatePasswordStatusRequestDto request)
    {
        if (!ModelState.IsValid)
        {
            return BadRequest(new { success = false, message = "Invalid input", errors = ModelState });
        }

        var result = await _authService.UpdatePasswordStatusAsync(userId, request);

        if (!result.IsSuccess)
        {
            if (result.Message.Contains("not found"))
            {
                return NotFound(new { success = false, message = result.Message });
            }

            return BadRequest(new { success = false, message = result.Message });
        }

        return Ok(new { success = true, message = result.Message });
    }
}
