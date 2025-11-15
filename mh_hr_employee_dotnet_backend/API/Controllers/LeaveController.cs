using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using React.Data;
using React.Models;

namespace React.API.Controllers;

public class AddHolidayDto
{
    public string HolidayName { get; set; } = string.Empty;
    public DateTime HolidayDate { get; set; }
}

[ApiController]
[Route("admin/api/[controller]")]
public class LeaveController : ControllerBase
{
    private readonly ApplicationDbContext _context;

    public LeaveController(ApplicationDbContext context)
    {
        _context = context ?? throw new ArgumentNullException(nameof(context));
    }

    [HttpGet("holidays")]
    public async Task<IActionResult> GetHolidays([FromQuery] int? year, [FromQuery] int? month)
    {
        try
        {
            int targetYear = year ?? DateTime.Now.Year;

            var query = _context.Holidays.AsQueryable();

            if (month.HasValue && month.Value > 0)
            {
                query = query.Where(h => h.HolidayDate.Year == targetYear && h.HolidayDate.Month == month.Value);
            }
            else
            {
                query = query.Where(h => h.HolidayDate.Year == targetYear);
            }

            var holidays = await query
                .OrderBy(h => h.HolidayDate)
                .ToListAsync();

            return Ok(holidays);
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "Error fetching holidays", error = ex.Message });
        }
    }

    [HttpPost("holidays")]
    public async Task<IActionResult> AddHoliday([FromBody] AddHolidayDto request)
    {
        try
        {
            if (string.IsNullOrEmpty(request.HolidayName) || request.HolidayDate == default)
                return BadRequest(new { message = "HolidayName and HolidayDate are required" });

            var holiday = new Holiday
            {
                HolidayName = request.HolidayName,
                HolidayDate = request.HolidayDate
            };

            _context.Holidays.Add(holiday);
            await _context.SaveChangesAsync();

            return Ok(new { success = true, message = "Holiday added successfully", holiday });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "Error adding holiday", error = ex.Message });
        }
    }

    [HttpPut("holidays/{id}")]
    public async Task<IActionResult> UpdateHoliday(int id, [FromBody] AddHolidayDto request)
    {
        try
        {
            var holiday = await _context.Holidays.FindAsync(id);
            if (holiday == null)
                return NotFound(new { message = "Holiday not found" });

            if (!string.IsNullOrEmpty(request.HolidayName))
                holiday.HolidayName = request.HolidayName;
            if (request.HolidayDate != default)
                holiday.HolidayDate = request.HolidayDate;

            await _context.SaveChangesAsync();

            return Ok(new { success = true, message = "Holiday updated successfully", holiday });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "Error updating holiday", error = ex.Message });
        }
    }

    [HttpDelete("holidays/{id}")]
    public async Task<IActionResult> DeleteHoliday(int id)
    {
        try
        {
            var holiday = await _context.Holidays.FindAsync(id);
            if (holiday == null)
                return NotFound(new { message = "Holiday not found" });

            _context.Holidays.Remove(holiday);
            await _context.SaveChangesAsync();

            return Ok(new { success = true, message = "Holiday deleted successfully" });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "Error deleting holiday", error = ex.Message });
        }
    }
}
