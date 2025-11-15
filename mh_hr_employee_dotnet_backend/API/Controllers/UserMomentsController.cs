using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using React.Core.Interfaces.Services;
using React.DTOs;
using System.Security.Claims;

namespace React.API.Controllers;

[ApiController]
[Route("api/moments")]
[Authorize]
public class UserMomentsController : ControllerBase
{
    private readonly IUserMomentService _userMomentService;

    public UserMomentsController(IUserMomentService userMomentService)
    {
        _userMomentService = userMomentService ?? throw new ArgumentNullException(nameof(userMomentService));
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

    [HttpGet]
    public async Task<IActionResult> GetMoments([FromQuery] int page = 1, [FromQuery] int pageSize = 3)
    {
        try
        {
            var userId = GetCurrentUserId();
            var result = await _userMomentService.GetMomentsAsync(page, pageSize, userId);

            if (!result.IsSuccess)
            {
                return StatusCode(500, new { Message = result.Message });
            }

            return Ok(result.Data);
        }
        catch (Exception ex)
        {
            return StatusCode(500, new
            {
                Message = "An error occurred while fetching moments",
                ErrorDetails = ex.Message
            });
        }
    }

    [HttpPost]
    public async Task<IActionResult> CreateMoment([FromForm] CreateMomentDto createMomentDto)
    {
        var userId = GetCurrentUserId();

        var result = await _userMomentService.CreateMomentAsync(
            createMomentDto.Title,
            createMomentDto.Description,
            createMomentDto.Media,
            userId,
            Request.Scheme,
            Request.Host.ToString()
        );

        return result.IsSuccess
            ? CreatedAtAction(nameof(GetMoments), new { id = result.Data!.Id }, result.Data)
            : BadRequest(new { Message = result.Message });
    }

    [HttpPost("{momentId}/reactions")]
    public async Task<IActionResult> AddReaction(int momentId, [FromBody] CreateMomentReactionDto reactionDto)
    {
        var userId = GetCurrentUserId();

        var result = await _userMomentService.AddOrUpdateReactionAsync(momentId, userId, reactionDto.ReactionType);

        return result.IsSuccess
            ? Ok(result.Data)
            : NotFound(new { Message = result.Message });
    }
}
