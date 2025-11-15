using Microsoft.AspNetCore.Mvc;
using React.Core.DTOs.Request;
using React.Core.Interfaces.Services;

namespace React.API.Controllers;

/// <summary>
/// Controller for medical certificate leave submission
/// </summary>
[ApiController]
[Route("api/[controller]")]
public class McController : ControllerBase
{
    private readonly IMedicalCertificateService _medicalCertificateService;
    private readonly ILogger<McController> _logger;

    public McController(
        IMedicalCertificateService medicalCertificateService,
        ILogger<McController> logger)
    {
        _medicalCertificateService = medicalCertificateService ?? throw new ArgumentNullException(nameof(medicalCertificateService));
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));
    }

    /// <summary>
    /// Submit medical certificate leave request
    /// POST: api/Mc/submit
    /// </summary>
    [HttpPost("submit")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> SubmitLeaveRequest([FromForm] McLeaveRequestDto request)
    {
        if (!ModelState.IsValid)
            return BadRequest(new { message = "Invalid input", errors = ModelState });

        var result = await _medicalCertificateService.SubmitLeaveRequestAsync(request);

        if (!result.IsSuccess)
            return BadRequest(new { message = result.Message });

        return Ok(new { message = "Leave request submitted successfully" });
    }

}
