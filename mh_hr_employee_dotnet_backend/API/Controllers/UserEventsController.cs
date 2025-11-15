using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using React.Core.DTOs.Request;
using React.Core.Interfaces.Services;
using System.Security.Claims;

namespace React.API.Controllers;

[ApiController]
[Route("api/Events")]
[Authorize]
public class UserEventsController : ControllerBase
{
    private readonly IUserEventService _userEventService;

    public UserEventsController(IUserEventService userEventService)
    {
        _userEventService = userEventService ?? throw new ArgumentNullException(nameof(userEventService));
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

    [HttpGet("all")]
    public async Task<IActionResult> GetAllEvents()
    {
        var userId = GetCurrentUserId();
        var result = await _userEventService.GetAllEventsAsync(userId);
        return result.IsSuccess
            ? Ok(result.Data)
            : BadRequest(new { message = result.Message });
    }

    [HttpGet]
    public async Task<IActionResult> GetEvents([FromQuery] DateTime date)
    {
        var userId = GetCurrentUserId();
        var result = await _userEventService.GetEventsByDateAsync(date, userId);

        if (result == null)
            return Ok(new List<object>());

        return result.IsSuccess
            ? Ok(result.Data)
            : BadRequest(new { message = result.Message });
    }

    [HttpGet("month")]
    public async Task<IActionResult> GetMonthEvents([FromQuery] int year, [FromQuery] int month)
    {
        var userId = GetCurrentUserId();
        var result = await _userEventService.GetEventsByMonthAsync(year, month, userId);
        return result.IsSuccess
            ? Ok(result.Data)
            : BadRequest(new { message = result.Message });
    }

    [HttpPost]
    public async Task<IActionResult> CreateEvent([FromBody] CreateEventRequestDto requestDto)
    {
        if (!ModelState.IsValid)
        {
            return BadRequest(ModelState);
        }

        var userId = GetCurrentUserId();
        var result = await _userEventService.CreateEventAsync(requestDto, userId);
        return result.IsSuccess
            ? CreatedAtAction(nameof(GetEvents), new { date = requestDto.Date }, result.Data)
            : BadRequest(new { message = result.Message });
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> UpdateEvent(int id, [FromBody] UpdateEventRequestDto requestDto)
    {
        if (id != requestDto.Id)
        {
            return BadRequest("ID mismatch");
        }

        if (!ModelState.IsValid)
        {
            return BadRequest(ModelState);
        }

        var result = await _userEventService.UpdateEventAsync(requestDto);
        return result.IsSuccess
            ? Ok(result.Data)
            : NotFound(new { message = result.Message });
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteEvent(int id)
    {
        var result = await _userEventService.DeleteEventAsync(id);
        return result.IsSuccess
            ? NoContent()
            : NotFound(new { message = result.Message });
    }

    [HttpPost("{id}/mark-read")]
    public async Task<IActionResult> MarkEventAsRead(int id)
    {
        var userId = GetCurrentUserId();
        var result = await _userEventService.MarkEventAsReadAsync(id, userId);
        return result.IsSuccess
            ? Ok(new { message = result.Message })
            : NotFound(new { message = result.Message });
    }

    [HttpGet("{eventId}/read-status")]
    public async Task<IActionResult> GetReadStatus(int eventId)
    {
        var userId = GetCurrentUserId();
        var result = await _userEventService.GetEventReadStatusAsync(eventId, userId);
        return result.IsSuccess
            ? Ok(result.Data)
            : NotFound(new { message = result.Message });
    }
}
