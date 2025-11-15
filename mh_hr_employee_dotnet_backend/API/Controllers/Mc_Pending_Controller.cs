using Microsoft.AspNetCore.Mvc;
using React.Core.Interfaces.Services;

namespace React.API.Controllers;

/// <summary>
/// Controller for viewing pending and approved medical certificate leaves
/// </summary>
[ApiController]
[Route("api/[controller]")]
public class Mc_Pending_Controller : ControllerBase
{
    private readonly IMedicalCertificateService _medicalCertificateService;
    private readonly ILogger<Mc_Pending_Controller> _logger;

    public Mc_Pending_Controller(
        IMedicalCertificateService medicalCertificateService,
        ILogger<Mc_Pending_Controller> logger)
    {
        _medicalCertificateService = medicalCertificateService ?? throw new ArgumentNullException(nameof(medicalCertificateService));
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));
    }

    /// <summary>
    /// Get all leaves (approved, rejected, pending)
    /// GET: api/Mc_Pending_/approved-leaves
    /// </summary>
    [HttpGet("approved-leaves")]
    [ProducesResponseType(typeof(object), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> GetApprovedWithoutIdLeaves()
    {
        var result = await _medicalCertificateService.GetAllLeavesAsync();

        if (!result.IsSuccess)
        {
            return NotFound(new { message = result.Message });
        }

        return Ok(result.Data);
    }

    /// <summary>
    /// Get pending leaves for a specific user
    /// GET: api/Mc_Pending_/pending-leaves/{id}
    /// </summary>
    [HttpGet("pending-leaves/{id}")]
    [ProducesResponseType(typeof(object), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> GetPendingLeaves(int id)
    {
        var result = await _medicalCertificateService.GetPendingLeavesByUserIdAsync(id);

        if (!result.IsSuccess)
        {
            return NotFound(new { message = result.Message });
        }

        return Ok(result.Data);
    }

    /// <summary>
    /// Get approved/rejected leaves for a specific user
    /// GET: api/Mc_Pending_/approved-leaves/{id}
    /// </summary>
    [HttpGet("approved-leaves/{id}")]
    [ProducesResponseType(typeof(object), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> GetApprovedLeaves(int id)
    {
        var result = await _medicalCertificateService.GetApprovedLeavesByUserIdAsync(id);

        if (!result.IsSuccess)
        {
            return NotFound(new { message = result.Message });
        }

        return Ok(result.Data);
    }
}
