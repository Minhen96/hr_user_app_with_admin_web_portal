using Microsoft.AspNetCore.Mvc;
using React.Core.DTOs.Request;
using React.Core.Interfaces.Services;
using System.Security.Claims;

namespace React.API.Controllers;

[ApiController]
[Route("api/ChangeRequests")]
public class UserChangeRequestsController : ControllerBase
{
    private readonly IUserChangeRequestService _userChangeRequestService;

    public UserChangeRequestsController(IUserChangeRequestService userChangeRequestService)
    {
        _userChangeRequestService = userChangeRequestService ?? throw new ArgumentNullException(nameof(userChangeRequestService));
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

    [HttpPost("signature")]
    public async Task<IActionResult> CreateSignature([FromBody] CreateSignatureRequestDto signatureDto)
    {
        var userId = GetCurrentUserId();
        var result = await _userChangeRequestService.CreateSignatureAsync(userId, signatureDto);
        return result.IsSuccess
            ? CreatedAtAction(nameof(CreateSignature), new { id = result.Data.Id }, result.Data)
            : StatusCode(500, new { error = result.Message });
    }

    [HttpPost]
    public async Task<IActionResult> CreateChangeRequest([FromBody] CreateUserChangeRequestDto requestDto)
    {
        var result = await _userChangeRequestService.CreateChangeRequestAsync(requestDto);
        return result.IsSuccess
            ? CreatedAtAction(nameof(GetChangeRequest), new { id = result.Data.Id }, result.Data)
            : BadRequest(new { error = result.Message });
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetChangeRequest(int id)
    {
        var result = await _userChangeRequestService.GetChangeRequestByIdAsync(id);
        return result.IsSuccess
            ? Ok(result.Data)
            : NotFound(new { error = result.Message });
    }

    [HttpGet("user/{userId}")]
    public async Task<IActionResult> GetUserChangeRequests(int userId)
    {
        var result = await _userChangeRequestService.GetUserChangeRequestsAsync(userId);
        return result.IsSuccess
            ? Ok(result.Data)
            : StatusCode(500, new { error = result.Message });
    }

    [HttpPut("return/{id}")]
    public async Task<IActionResult> RequestReturn(int id)
    {
        var result = await _userChangeRequestService.RequestReturnAsync(id);
        return result.IsSuccess
            ? Ok(new { message = result.Message })
            : BadRequest(new { error = result.Message });
    }

    [HttpGet("user/{userId}/all")]
    public async Task<IActionResult> GetAllUserChangeRequests(int userId)
    {
        var result = await _userChangeRequestService.GetAllUserChangeRequestsAsync(userId);
        return result.IsSuccess
            ? Ok(result.Data)
            : StatusCode(500, new { error = result.Message });
    }
}
