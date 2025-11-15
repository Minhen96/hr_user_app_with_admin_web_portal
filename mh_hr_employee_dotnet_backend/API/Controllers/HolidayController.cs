using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using React.Core.Interfaces.Services;
using React.Data;
using React.Models;

namespace React.API.Controllers;

[Route("admin/api/[controller]")]
[ApiController]
public class HolidayController : ControllerBase
{
    private readonly IHolidayService _holidayService;
    private readonly ApplicationDbContext _context;

    public HolidayController(IHolidayService holidayService, ApplicationDbContext context)
    {
        _holidayService = holidayService ?? throw new ArgumentNullException(nameof(holidayService));
        _context = context ?? throw new ArgumentNullException(nameof(context));
    }

    [HttpGet]
    public async Task<IActionResult> GetHolidays([FromQuery] int? year, [FromQuery] int? month)
    {
        // If no year/month provided, get current year
        int targetYear = year ?? DateTime.Now.Year;
        int targetMonth = month ?? DateTime.Now.Month;

        var result = await _holidayService.GetHolidaysByYearAndMonthAsync(targetYear, targetMonth);
        return result.IsSuccess
            ? Ok(result.Data)
            : BadRequest(new { message = result.Message });
    }

    [HttpGet("all")]
    public async Task<IActionResult> GetAllHolidays()
    {
        // Get holidays for current year and next year
        int currentYear = DateTime.Now.Year;
        var currentYearTask = _holidayService.GetHolidaysByYearAndMonthAsync(currentYear, 0);
        var nextYearTask = _holidayService.GetHolidaysByYearAndMonthAsync(currentYear + 1, 0);

        var results = await Task.WhenAll(currentYearTask, nextYearTask);

        var allHolidays = new List<object>();
        if (results[0].IsSuccess && results[0].Data != null)
            allHolidays.AddRange(results[0].Data);
        if (results[1].IsSuccess && results[1].Data != null)
            allHolidays.AddRange(results[1].Data);

        return Ok(allHolidays);
    }

    [HttpPost]
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

    [HttpPut("{id}")]
    public async Task<IActionResult> UpdateHoliday(int id, [FromBody] AddHolidayDto request)
    {
        try
        {
            var holiday = await _context.Holidays.FindAsync(id);
            if (holiday == null)
                return NotFound(new { message = "Holiday not found" });

            holiday.HolidayName = request.HolidayName ?? holiday.HolidayName;
            holiday.HolidayDate = request.HolidayDate != default ? request.HolidayDate : holiday.HolidayDate;

            await _context.SaveChangesAsync();

            return Ok(new { success = true, message = "Holiday updated successfully", holiday });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "Error updating holiday", error = ex.Message });
        }
    }

    [HttpDelete("{id}")]
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
