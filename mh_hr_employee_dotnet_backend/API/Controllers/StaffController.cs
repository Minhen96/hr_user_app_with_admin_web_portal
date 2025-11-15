using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using React.Core.Interfaces.Services;
using React.Data;

namespace React.API.Controllers;

[Route("admin/api/staff")]
[ApiController]
public class StaffController : ControllerBase
{
    private readonly IStaffService _staffService;
    private readonly ApplicationDbContext _context;

    public StaffController(IStaffService staffService, ApplicationDbContext context)
    {
        _staffService = staffService ?? throw new ArgumentNullException(nameof(staffService));
        _context = context ?? throw new ArgumentNullException(nameof(context));
    }

    [HttpGet]
    public async Task<IActionResult> GetAllStaff()
    {
        var result = await _staffService.GetAllStaffAsync();
        return result.IsSuccess ? Ok(result.Data) : StatusCode(500, new { message = result.Message });
    }

    [HttpGet("{userId}/leave-details")]
    public async Task<IActionResult> GetStaffLeaveDetails(int userId)
    {
        var result = await _staffService.GetStaffLeaveDetailsAsync(userId);
        return result.IsSuccess ? Ok(result.Data) : NotFound(new { message = result.Message });
    }

    [HttpPut("{userId}/leave-entitlement")]
    public async Task<IActionResult> UpdateLeaveEntitlement(int userId, [FromBody] UpdateEntitlementDto dto)
    {
        try
        {
            var annualLeave = await _context.AnnualLeaves
                .FirstOrDefaultAsync(al => al.user_id == userId);

            if (annualLeave == null)
                return NotFound(new { message = "Annual leave record not found" });

            annualLeave.entitlement = dto.Entitlement;
            await _context.SaveChangesAsync();

            return Ok(new { success = true, message = "Leave entitlement updated successfully" });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "Error updating leave entitlement", error = ex.Message });
        }
    }
}

public class UpdateEntitlementDto
{
    public int Entitlement { get; set; }
}
