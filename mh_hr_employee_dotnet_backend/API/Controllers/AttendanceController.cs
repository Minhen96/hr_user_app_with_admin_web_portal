using Microsoft.AspNetCore.Mvc;
using React.Core.DTOs.Request;
using React.Core.Interfaces.Services;

namespace React.API.Controllers;

[ApiController]
[Route("admin/api/[controller]")]
public class AttendanceController : ControllerBase
{
    private readonly IAttendanceService _attendanceService;

    public AttendanceController(IAttendanceService attendanceService)
    {
        _attendanceService = attendanceService ?? throw new ArgumentNullException(nameof(attendanceService));
    }

    [HttpPost("TimeIn")]
    public async Task<IActionResult> TimeIn([FromForm] AttendanceTimeInRequestDto request)
    {
        if (!ModelState.IsValid)
            return BadRequest("Invalid attendance data");

        var result = await _attendanceService.TimeInAsync(request);
        return result.IsSuccess
            ? CreatedAtAction(nameof(TimeIn), new { id = result.Data?.Id }, result.Data)
            : BadRequest(result.Message);
    }

    [HttpPost("TimeOut/{id}")]
    public async Task<IActionResult> TimeOut(int id, [FromForm] AttendanceTimeOutRequestDto request)
    {
        var result = await _attendanceService.TimeOutAsync(id, request);
        return result.IsSuccess ? NoContent() : NotFound(result.Message);
    }

    [HttpGet("CurrentDaySubmissions/{userID}")]
    public async Task<IActionResult> GetCurrentDaySubmissions(int userID)
    {
        var result = await _attendanceService.GetCurrentDaySubmissionsAsync(userID);
        return result.IsSuccess ? Ok(result.Data) : StatusCode(500, result.Message);
    }

    [HttpGet("MonthlyAttendance/{userID}")]
    public async Task<IActionResult> GetMonthlyAttendance(int userID, [FromQuery] int? month, [FromQuery] int? year)
    {
        var result = await _attendanceService.GetMonthlyAttendanceAsync(userID, month, year);
        return result.IsSuccess ? Ok(result.Data) : StatusCode(500, result.Message);
    }
}
