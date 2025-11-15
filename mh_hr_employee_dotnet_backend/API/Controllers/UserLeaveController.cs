using Microsoft.AspNetCore.Mvc;
using React.Core.DTOs.Request;
using React.Core.Interfaces.Services;

namespace React.API.Controllers;

[ApiController]
[Route("api/Leave")]
public class UserLeaveController : ControllerBase
{
    private readonly IUserLeaveService _userLeaveService;

    public UserLeaveController(IUserLeaveService userLeaveService)
    {
        _userLeaveService = userLeaveService ?? throw new ArgumentNullException(nameof(userLeaveService));
    }

    [HttpPost("submit")]
    public async Task<IActionResult> SubmitLeave([FromBody] SubmitLeaveRequestDto requestDto)
    {
        if (!ModelState.IsValid)
        {
            return BadRequest(ModelState);
        }

        var result = await _userLeaveService.SubmitLeaveAsync(requestDto);
        return result.IsSuccess
            ? CreatedAtAction(nameof(SubmitLeave), result.Data)
            : BadRequest(new { message = result.Message });
    }

    [HttpGet("entitlement/{userId}")]
    public async Task<IActionResult> GetEntitlement(int userId)
    {
        var result = await _userLeaveService.GetEntitlementAsync(userId);
        return result.IsSuccess
            ? Ok(result.Data)
            : NotFound(new { message = result.Message });
    }

    [HttpGet("ANLpending-leaves/{id}")]
    public async Task<IActionResult> GetPendingLeaves(int id)
    {
        var result = await _userLeaveService.GetPendingLeavesAsync(id);
        return result.IsSuccess
            ? Ok(result.Data)
            : NotFound(new { message = result.Message });
    }

    [HttpGet("ANLapprove-leaves/{id}")]
    public async Task<IActionResult> GetApproveLeaves(int id)
    {
        var result = await _userLeaveService.GetApprovedLeavesByIdAsync(id);
        return result.IsSuccess
            ? Ok(result.Data)
            : NotFound(new { message = result.Message });
    }

    [HttpGet("ANLapprove-leaves")]
    public async Task<IActionResult> GetApprovewithoutifLeaves()
    {
        var result = await _userLeaveService.GetAllApprovedLeavesAsync();
        return result.IsSuccess
            ? Ok(result.Data)
            : NotFound(new { message = result.Message });
    }

    [HttpPut("update")]
    public async Task<IActionResult> UpdateLeaveRequest([FromBody] UpdateLeaveRequestDto requestDto)
    {
        if (!ModelState.IsValid)
        {
            return BadRequest(ModelState);
        }

        var result = await _userLeaveService.UpdateLeaveRequestAsync(requestDto);
        return result.IsSuccess
            ? Ok(new { message = result.Message })
            : NotFound(new { message = result.Message });
    }

    [HttpDelete("delete/{id}")]
    public async Task<IActionResult> DeleteLeaveRequest(int id)
    {
        var result = await _userLeaveService.DeleteLeaveRequestAsync(id);
        return result.IsSuccess
            ? Ok(new { message = result.Message })
            : NotFound(new { message = result.Message });
    }
}
