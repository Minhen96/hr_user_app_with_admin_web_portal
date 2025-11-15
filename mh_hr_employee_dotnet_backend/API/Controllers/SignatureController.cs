using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using React.Data;
using React.Models;
using System.Text.Json;

namespace React.API.Controllers;

[Route("admin/api/[controller]")]
[ApiController]
public class SignatureController : ControllerBase
{
    private readonly ApplicationDbContext _context;
    private readonly ILogger<SignatureController> _logger;

    public SignatureController(ApplicationDbContext context, ILogger<SignatureController> logger)
    {
        _context = context ?? throw new ArgumentNullException(nameof(context));
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));
    }

    /// <summary>
    /// Create a new signature
    /// POST: /admin/api/signatures
    /// </summary>
    [HttpPost]
    public async Task<IActionResult> CreateSignature([FromBody] CreateSignatureDto dto)
    {
        try
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var signature = new Signature
            {
                UserId = dto.UserId,
                Points = JsonSerializer.Serialize(dto.Points),
                BoundaryWidth = dto.BoundaryWidth,
                BoundaryHeight = dto.BoundaryHeight,
                CreatedAt = DateTime.UtcNow
            };

            _context.Signatures.Add(signature);
            await _context.SaveChangesAsync();

            return Ok(new { id = signature.Id, message = "Signature created successfully" });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error creating signature");
            return StatusCode(500, new { message = "Error creating signature", error = ex.Message });
        }
    }

    /// <summary>
    /// Get signature by ID
    /// GET: /admin/api/signatures/{id}
    /// </summary>
    [HttpGet("{id}")]
    public async Task<IActionResult> GetSignature(int id)
    {
        try
        {
            var signature = await _context.Signatures.FindAsync(id);
            if (signature == null)
            {
                return NotFound(new { message = "Signature not found" });
            }

            return Ok(new
            {
                id = signature.Id,
                userId = signature.UserId,
                points = JsonSerializer.Deserialize<List<object>>(signature.Points),
                boundaryWidth = signature.BoundaryWidth,
                boundaryHeight = signature.BoundaryHeight,
                createdAt = signature.CreatedAt
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving signature");
            return StatusCode(500, new { message = "Error retrieving signature", error = ex.Message });
        }
    }
}

/// <summary>
/// DTO for creating a signature
/// </summary>
public class CreateSignatureDto
{
    public int? UserId { get; set; }
    public List<SignaturePoint> Points { get; set; } = new();
    public double BoundaryWidth { get; set; }
    public double BoundaryHeight { get; set; }
}

public class SignaturePoint
{
    public double X { get; set; }
    public double Y { get; set; }
}
