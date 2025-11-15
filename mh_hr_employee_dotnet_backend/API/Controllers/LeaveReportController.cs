using Microsoft.AspNetCore.Mvc;
using React.Core.Interfaces.Services;

namespace React.API.Controllers;

[Route("admin/api/[controller]")]
[ApiController]
public class LeaveReportController : ControllerBase
{
    private readonly ILeaveReportService _leaveReportService;

    public LeaveReportController(ILeaveReportService leaveReportService)
    {
        _leaveReportService = leaveReportService ?? throw new ArgumentNullException(nameof(leaveReportService));
    }

    [HttpGet("report/annual")]
    public async Task<IActionResult> GenerateAnnualLeaveReport()
    {
        var result = await _leaveReportService.GenerateAnnualLeaveReportPdfAsync();

        if (!result.IsSuccess)
            return StatusCode(500, new { message = result.Message });

        return File(result.Data, "application/pdf", $"annual_leave_report_{DateTime.Now.Year}.pdf");
    }

    [HttpGet("report/medical")]
    public async Task<IActionResult> GenerateMedicalLeaveReport()
    {
        var result = await _leaveReportService.GenerateMedicalLeaveReportPdfAsync();

        if (!result.IsSuccess)
            return StatusCode(500, new { message = result.Message });

        return File(result.Data, "application/pdf", $"medical_leave_report_{DateTime.Now.Year}.pdf");
    }
}
