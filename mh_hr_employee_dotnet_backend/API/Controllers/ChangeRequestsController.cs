using Microsoft.AspNetCore.Mvc;
using React.Core.DTOs.Request;
using React.Core.Interfaces.Services;

namespace React.API.Controllers;

[Route("admin/api/[controller]")]
[ApiController]
public class ChangeRequestsController : ControllerBase
{
    private readonly IChangeRequestService _changeRequestService;

    public ChangeRequestsController(IChangeRequestService changeRequestService)
    {
        _changeRequestService = changeRequestService ?? throw new ArgumentNullException(nameof(changeRequestService));
    }

    [HttpGet]
    public async Task<IActionResult> GetChangeRequests()
    {
        var result = await _changeRequestService.GetAllChangeRequestsAsync();
        return result.IsSuccess
            ? Ok(result.Data)
            : StatusCode(500, new { message = result.Message });
    }

    [HttpGet("brief")]
    public async Task<IActionResult> GetApprovedChangeRequests()
    {
        var result = await _changeRequestService.GetApprovedChangeRequestsAsync();
        return result.IsSuccess
            ? Ok(result.Data)
            : StatusCode(500, new { message = result.Message });
    }

    [HttpGet("{id}/details")]
    public async Task<IActionResult> GetChangeRequestDetails(int id)
    {
        var result = await _changeRequestService.GetChangeRequestDetailsByIdAsync(id);
        return result.IsSuccess
            ? Ok(result.Data)
            : NotFound(new { message = result.Message });
    }

    [HttpGet("pending")]
    public async Task<IActionResult> GetPendingChangeRequests()
    {
        var result = await _changeRequestService.GetPendingChangeRequestsAsync();
        return result.IsSuccess
            ? Ok(result.Data)
            : StatusCode(500, new { message = result.Message });
    }

    [HttpGet("fixedAssetTypes")]
    public async Task<IActionResult> GetFixedAssetTypes()
    {
        var result = await _changeRequestService.GetFixedAssetTypesAsync();
        return result.IsSuccess
            ? Ok(result.Data)
            : StatusCode(500, new { message = result.Message });
    }

    [HttpPut("{id}/status")]
    public async Task<IActionResult> UpdateChangeRequestStatus(int id, [FromBody] UpdateChangeRequestStatusRequestDto request)
    {
        if (!ModelState.IsValid)
            return BadRequest(new { success = false, message = "Invalid request data" });

        var result = await _changeRequestService.UpdateChangeRequestStatusAsync(id, request);
        return result.IsSuccess
            ? Ok(new { success = true, message = result.Message, productCode = result.Data })
            : BadRequest(new { success = false, message = result.Message });
    }

    [HttpPut("{id}/changestatus")]
    public async Task<IActionResult> ChangeRequestStatus(int id, [FromBody] ChangeStatusRequestDto request)
    {
        if (!ModelState.IsValid)
            return BadRequest(new { success = false, message = "Invalid request data" });

        var result = await _changeRequestService.ChangeRequestStatusAsync(id, request);
        return result.IsSuccess
            ? Ok(new { success = true, message = result.Message })
            : BadRequest(new { success = false, message = result.Message });
    }
}
