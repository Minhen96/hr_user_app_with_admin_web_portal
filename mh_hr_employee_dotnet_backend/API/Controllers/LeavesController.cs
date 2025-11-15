using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using React.Core.DTOs.Request;
using React.Core.Interfaces.Services;
using React.Data;

namespace React.API.Controllers;

[ApiController]
[Route("admin/api/[controller]")]
public class LeavesController : ControllerBase
{
    private readonly ILeaveService _leaveService;
    private readonly ApplicationDbContext _context;

    public LeavesController(ILeaveService leaveService, ApplicationDbContext context)
    {
        _leaveService = leaveService ?? throw new ArgumentNullException(nameof(leaveService));
        _context = context ?? throw new ArgumentNullException(nameof(context));
    }

    [HttpGet]
    public async Task<IActionResult> GetLeaves()
    {
        var result = await _leaveService.GetAllLeavesAsync();
        return result.IsSuccess ? Ok(result.Data) : StatusCode(500, new { message = result.Message });
    }

    [HttpGet("medical")]
    public async Task<IActionResult> GetMedicalLeaves()
    {
        var result = await _leaveService.GetAllMedicalLeavesAsync();
        return result.IsSuccess ? Ok(result.Data) : StatusCode(500, new { message = result.Message });
    }

    [HttpPost]
    public async Task<IActionResult> CreateLeave([FromBody] SubmitLeaveRequestDto request)
    {
        if (!ModelState.IsValid)
            return BadRequest(ModelState);

        try
        {
            var leaveDetail = new React.Models.LeaveDetail
            {
                annual_leave_id = request.AnnualLeaveId,
                leave_date = request.LeaveDate,
                leave_end_date = request.LeaveEndDate,
                reason = request.Reason,
                no_of_days = request.NoOfDays,
                status = "Pending",
                date_submission = DateTime.Now
            };

            _context.LeaveDetails.Add(leaveDetail);
            await _context.SaveChangesAsync();

            return Ok(new { success = true, leaveId = leaveDetail.id, message = "Leave created successfully" });
        }
        catch (Exception ex)
        {
            return BadRequest(new { success = false, message = "Error creating leave", error = ex.Message });
        }
    }

    [HttpPut("{id}/status")]
    public async Task<IActionResult> UpdateLeaveStatus(int id, [FromBody] LeaveStatusUpdateDto updateDto)
    {
        if (!ModelState.IsValid)
            return BadRequest(ModelState);

        var result = await _leaveService.UpdateLeaveStatusAsync(id, updateDto);
        return result.IsSuccess ? Ok(result.Data) : NotFound(new { message = result.Message });
    }

    [HttpPut("medical/{id}/status")]
    public async Task<IActionResult> UpdateMedicalLeaveStatus(int id, [FromBody] LeaveStatusUpdateDto updateDto)
    {
        if (!ModelState.IsValid)
            return BadRequest(ModelState);

        var result = await _leaveService.UpdateMedicalLeaveStatusAsync(id, updateDto);
        return result.IsSuccess ? Ok(result.Data) : NotFound(new { message = result.Message });
    }

    [HttpGet("calendar")]
    public async Task<IActionResult> GetCalendarData([FromQuery] DateTime? startDate, [FromQuery] DateTime? endDate)
    {
        try
        {
            var start = startDate ?? DateTime.Now.AddMonths(-1);
            var end = endDate ?? DateTime.Now.AddMonths(1);

            // Get all approved leave details within the date range
            var leaveDetails = await _context.LeaveDetails
                .Where(ld => ld.status == "Approved" &&
                       ld.leave_date <= end &&
                       ld.leave_end_date >= start)
                .ToListAsync();

            // Group by date and get user info
            var calendarData = new List<object>();
            var currentDate = start.Date;

            while (currentDate <= end.Date)
            {
                var usersOnLeave = leaveDetails
                    .Where(ld => ld.leave_date.Date <= currentDate && ld.leave_end_date.Date >= currentDate)
                    .Select(ld => new { userId = ld.annual_leave_id })
                    .ToList();

                if (usersOnLeave.Any())
                {
                    calendarData.Add(new
                    {
                        date = currentDate,
                        users = usersOnLeave
                    });
                }

                currentDate = currentDate.AddDays(1);
            }

            return Ok(calendarData);
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "Error fetching calendar data", error = ex.Message });
        }
    }
}
