using Microsoft.AspNetCore.Mvc;
using React.Core.DTOs.Request;
using React.Core.Interfaces.Services;

namespace React.API.Controllers;

[Route("admin/api/[controller]")]
[ApiController]
public class EquipmentReturnsController : ControllerBase
{
    private readonly IEquipmentReturnService _equipmentReturnService;

    public EquipmentReturnsController(IEquipmentReturnService equipmentReturnService)
    {
        _equipmentReturnService = equipmentReturnService ?? throw new ArgumentNullException(nameof(equipmentReturnService));
    }

    [HttpGet]
    public async Task<IActionResult> GetReturns()
    {
        var result = await _equipmentReturnService.GetAllReturnsAsync();
        return result.IsSuccess
            ? Ok(result.Data)
            : StatusCode(500, new { message = result.Message });
    }

    [HttpGet("{id}/details")]
    public async Task<IActionResult> GetReturnDetails(int id)
    {
        var result = await _equipmentReturnService.GetReturnDetailsByIdAsync(id);
        return result.IsSuccess
            ? Ok(result.Data)
            : NotFound(new { message = result.Message });
    }

    [HttpGet("unchecked")]
    public async Task<IActionResult> GetUncheckedReturns()
    {
        var result = await _equipmentReturnService.GetUncheckedReturnsAsync();
        return result.IsSuccess
            ? Ok(result.Data)
            : StatusCode(500, new { message = result.Message });
    }

    // POST endpoint temporarily disabled - requires CreateEquipmentReturnRequestDto and CreateReturnAsync implementation
    // [HttpPost]
    // public async Task<IActionResult> CreateReturn([FromBody] CreateEquipmentReturnRequestDto request)
    // {
    //     if (!ModelState.IsValid)
    //         return BadRequest(new { success = false, message = "Invalid request data" });
    //
    //     var result = await _equipmentReturnService.CreateReturnAsync(request);
    //     return result.IsSuccess
    //         ? Ok(new { success = true, returnId = result.Data, message = result.Message })
    //         : BadRequest(new { success = false, message = result.Message });
    // }

    [HttpPut("{id}/status")]
    public async Task<IActionResult> UpdateReturnStatus(int id, [FromBody] UpdateEquipmentReturnStatusRequestDto request)
    {
        if (!ModelState.IsValid)
            return BadRequest(new { success = false, message = "Invalid request data" });

        var result = await _equipmentReturnService.UpdateReturnStatusAsync(id, request);
        return result.IsSuccess
            ? Ok(new { success = true, message = result.Message })
            : BadRequest(new { success = false, message = result.Message });
    }
}
