using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using React.Core.DTOs.Request;
using React.Core.Interfaces.Services;
using System.Security.Claims;

namespace React.API.Controllers;

/// <summary>
/// Controller for push notification operations (FCM tokens and sending notifications)
/// </summary>
[ApiController]
[Route("admin/api/[controller]")]
[Authorize]
public class NotificationController : ControllerBase
{
    private readonly INotificationService _notificationService;
    private readonly ILogger<NotificationController> _logger;

    public NotificationController(
        INotificationService notificationService,
        ILogger<NotificationController> logger)
    {
        _notificationService = notificationService ?? throw new ArgumentNullException(nameof(notificationService));
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

    /// <summary>
    /// Update FCM token for current user
    /// POST: api/Notification/update-fcm-token
    /// </summary>
    [HttpPost("update-fcm-token")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> UpdateFCMToken([FromBody] UpdateFCMTokenRequestDto request)
    {
        if (!ModelState.IsValid)
        {
            return BadRequest(new { message = "Invalid input", errors = ModelState });
        }

        try
        {
            var userId = GetCurrentUserId();
            var result = await _notificationService.UpdateFcmTokenAsync(userId, request);

            if (!result.IsSuccess)
            {
                return NotFound(new { message = result.Message });
            }

            return Ok(new { message = "FCM token updated successfully" });
        }
        catch (UnauthorizedAccessException)
        {
            return Unauthorized(new { message = "User is not authenticated" });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Unexpected error updating FCM token");
            return StatusCode(500, new { message = "Internal server error" });
        }
    }

    /// <summary>
    /// Send push notification to a specific user
    /// POST: api/Notification/send
    /// </summary>
    [HttpPost("send")]
    [ProducesResponseType(typeof(object), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> SendNotification([FromBody] SendNotificationRequestDto request)
    {
        if (!ModelState.IsValid)
        {
            return BadRequest(new { message = "Invalid input", errors = ModelState });
        }

        var result = await _notificationService.SendNotificationAsync(request);

        if (!result.IsSuccess)
        {
            if (result.Message.Contains("not found"))
            {
                return NotFound(new { message = result.Message });
            }
            return BadRequest(new { message = result.Message });
        }

        return Ok(new { messageId = result.Data });
    }

    /// <summary>
    /// Get all user FCM tokens
    /// GET: api/Notification/users/fcm-tokens
    /// </summary>
    [HttpGet("users/fcm-tokens")]
    [ProducesResponseType(typeof(object), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> GetAllUserFcmTokens()
    {
        var result = await _notificationService.GetAllUserFcmTokensAsync();

        if (!result.IsSuccess)
        {
            return StatusCode(500, new { message = result.Message });
        }

        return Ok(result.Data);
    }
}
