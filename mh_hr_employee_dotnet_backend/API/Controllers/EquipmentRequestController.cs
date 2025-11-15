using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using React.Core.Interfaces.Services;
using React.DTOs;
using System.Security.Claims;

namespace React.API.Controllers;

[ApiController]
[Route("admin/api/EquipmentRequests")]
[Authorize]
public class EquipmentRequestController : ControllerBase
{
    private readonly IEquipmentRequestService _equipmentRequestService;

    public EquipmentRequestController(IEquipmentRequestService equipmentRequestService)
    {
        _equipmentRequestService = equipmentRequestService ?? throw new ArgumentNullException(nameof(equipmentRequestService));
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
    public async Task<IActionResult> GetEquipmentRequests([FromQuery] string? status)
    {
        var userId = GetCurrentUserId();
        var result = await _equipmentRequestService.GetEquipmentRequestsByUserAsync(userId, status);
        return result.IsSuccess ? Ok(result.Data) : BadRequest(new { message = result.Message });
    }

    [HttpGet("all")]
    public async Task<IActionResult> GetAllEquipmentRequests([FromQuery] string? status)
    {
        var result = await _equipmentRequestService.GetAllEquipmentRequestsAsync(status);
        return result.IsSuccess ? Ok(result.Data) : BadRequest(new { message = result.Message });
    }

    [HttpGet("{id}/details")]
    public async Task<IActionResult> GetEquipmentRequestDetails(int id)
    {
        var result = await _equipmentRequestService.GetEquipmentRequestByIdAsync(id);
        return result.IsSuccess ? Ok(result.Data) : NotFound(new { message = result.Message });
    }

    [HttpPut("{id}/status")]
    public async Task<IActionResult> UpdateRequestStatus(int id, [FromBody] UpdateStatusDto data)
    {
        var result = await _equipmentRequestService.UpdateRequestStatusAsync(id, data.Status, data.ApproverId);
        return result.IsSuccess
            ? Ok(new { message = "Status updated successfully" })
            : BadRequest(new { message = result.Message });
    }

    [HttpPut("{id}/approve")]
    public async Task<IActionResult> ApproveRequest(int id)
    {
        var userId = GetCurrentUserId();
        var result = await _equipmentRequestService.UpdateRequestStatusAsync(id, "approved", userId);
        return result.IsSuccess
            ? Ok(new { message = "Request approved successfully" })
            : BadRequest(new { message = result.Message });
    }

    [HttpPut("{id}/reject")]
    public async Task<IActionResult> RejectRequest(int id)
    {
        var result = await _equipmentRequestService.UpdateRequestStatusAsync(id, "rejected");
        return result.IsSuccess
            ? Ok(new { message = "Request rejected successfully" })
            : BadRequest(new { message = result.Message });
    }

    [HttpPost]
    public async Task<IActionResult> CreateEquipmentRequest([FromBody] CreateEquipmentRequestDto requestData)
    {
        var userId = GetCurrentUserId();
        var result = await _equipmentRequestService.CreateEquipmentRequestAsync(userId, requestData);
        return result.IsSuccess
            ? Ok(result.Data)
            : BadRequest(new { message = result.Message });
    }

    [HttpPut("{id}/received")]
    public async Task<IActionResult> UpdateReceivedDetails(int id, [FromBody] UpdateReceivedDetailsDto data)
    {
        var result = await _equipmentRequestService.UpdateReceivedDetailsAsync(id, data);
        return result.IsSuccess
            ? Ok(new { message = "Received details updated successfully" })
            : BadRequest(new { message = result.Message });
    }
}
