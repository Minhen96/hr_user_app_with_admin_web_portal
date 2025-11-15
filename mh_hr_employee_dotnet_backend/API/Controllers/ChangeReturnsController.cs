using Microsoft.AspNetCore.Mvc;
using React.Core.DTOs.Request;
using React.Core.Interfaces.Services;

namespace React.API.Controllers;

[Route("admin/api/[controller]")]
[ApiController]
public class ChangeReturnsController : ControllerBase
{
    private readonly IChangeReturnService _changeReturnService;

    public ChangeReturnsController(IChangeReturnService changeReturnService)
    {
        _changeReturnService = changeReturnService ?? throw new ArgumentNullException(nameof(changeReturnService));
    }

    [HttpGet]
    public async Task<IActionResult> GetChangeReturns()
    {
        var result = await _changeReturnService.GetAllChangeReturnsAsync();
        return result.IsSuccess
            ? Ok(result.Data)
            : StatusCode(500, new { message = result.Message });
    }

    [HttpGet("{id}/details")]
    public async Task<IActionResult> GetChangeReturnDetails(int id)
    {
        var result = await _changeReturnService.GetChangeReturnDetailsByIdAsync(id);
        return result.IsSuccess
            ? Ok(result.Data)
            : NotFound(new { message = result.Message });
    }

    [HttpPut("{id}/returnstatus")]
    public async Task<IActionResult> UpdateChangeReturnStatus(int id, [FromBody] UpdateChangeReturnStatusRequestDto request)
    {
        if (!ModelState.IsValid)
            return BadRequest(new { success = false, message = "Invalid request data" });

        var result = await _changeReturnService.UpdateChangeReturnStatusAsync(id, request);
        return result.IsSuccess
            ? Ok(new { success = true, message = result.Message })
            : BadRequest(new { success = false, message = result.Message });
    }
}
