using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using React.Data;
using React.Models;

namespace React.API.Controllers;

[Route("admin/api/[controller]")]
[ApiController]
public class PolicyController : ControllerBase
{
    private readonly ApplicationDbContext _context;

    public PolicyController(ApplicationDbContext context)
    {
        _context = context ?? throw new ArgumentNullException(nameof(context));
    }

    [HttpGet]
    public async Task<IActionResult> GetAllPolicies()
    {
        try
        {
            var policies = await _context.Documents
                .Where(d => d.Type == "POLICY")
                .OrderByDescending(d => d.PostDate)
                .ToListAsync();
            return Ok(policies);
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "Error fetching policies", error = ex.Message });
        }
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetPolicy(int id)
    {
        try
        {
            var policy = await _context.Documents.FindAsync(id);
            if (policy == null || policy.Type != "POLICY")
                return NotFound(new { message = "Policy not found" });

            return Ok(policy);
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "Error fetching policy", error = ex.Message });
        }
    }

    [HttpPost]
    public async Task<IActionResult> CreatePolicy([FromForm] CreateMemoDto request)
    {
        try
        {
            var policy = new Document
            {
                Type = "POLICY",
                Title = request.Title ?? string.Empty,
                Content = request.Content,
                DepartmentId = request.DepartmentId,
                PostBy = request.PostBy,
                PostDate = DateTime.Now
            };

            if (request.File != null)
            {
                using var memoryStream = new MemoryStream();
                await request.File.CopyToAsync(memoryStream);
                policy.DocumentUpload = memoryStream.ToArray();
                policy.FileType = Path.GetExtension(request.File.FileName).TrimStart('.');
            }

            _context.Documents.Add(policy);
            await _context.SaveChangesAsync();

            return Ok(new { success = true, documentId = policy.Id, message = "Policy created successfully" });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "Error creating policy", error = ex.Message });
        }
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> UpdatePolicy(int id, [FromForm] CreateMemoDto request)
    {
        try
        {
            var policy = await _context.Documents.FindAsync(id);
            if (policy == null || policy.Type != "POLICY")
                return NotFound(new { message = "Policy not found" });

            policy.Title = request.Title;
            policy.Content = request.Content;
            policy.DepartmentId = request.DepartmentId;

            if (request.File != null)
            {
                using var memoryStream = new MemoryStream();
                await request.File.CopyToAsync(memoryStream);
                policy.DocumentUpload = memoryStream.ToArray();
                policy.FileType = Path.GetExtension(request.File.FileName).TrimStart('.');
            }

            await _context.SaveChangesAsync();

            return Ok(new { success = true, message = "Policy updated successfully" });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "Error updating policy", error = ex.Message });
        }
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> DeletePolicy(int id)
    {
        try
        {
            var policy = await _context.Documents.FindAsync(id);
            if (policy == null || policy.Type != "POLICY")
                return NotFound(new { message = "Policy not found" });

            _context.Documents.Remove(policy);
            await _context.SaveChangesAsync();

            return Ok(new { success = true, message = "Policy deleted successfully" });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "Error deleting policy", error = ex.Message });
        }
    }

    [HttpGet("{id}/download")]
    public async Task<IActionResult> DownloadPolicy(int id)
    {
        try
        {
            var policy = await _context.Documents.FindAsync(id);
            if (policy == null || policy.Type != "POLICY")
                return NotFound(new { message = "Policy not found" });

            if (policy.DocumentUpload == null || string.IsNullOrEmpty(policy.FileType))
                return NotFound(new { message = "File not found" });

            var contentType = GetContentType(policy.FileType);
            var fileName = $"{policy.Title}.{policy.FileType}";
            return File(policy.DocumentUpload, contentType, fileName);
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "Error downloading policy", error = ex.Message });
        }
    }

    [HttpPost("{id}/mark-read")]
    public async Task<IActionResult> MarkPolicyAsRead(int id, [FromBody] MarkReadDto request)
    {
        try
        {
            var existingRead = await _context.DocumentReads
                .FirstOrDefaultAsync(dr => dr.DocId == id && dr.UserId == request.UserId);

            if (existingRead == null)
            {
                var documentRead = new DocumentRead
                {
                    DocId = id,
                    UserId = request.UserId,
                    ReadDate = DateTime.Now
                };

                _context.DocumentReads.Add(documentRead);
                await _context.SaveChangesAsync();
            }

            return Ok(new { success = true, message = "Policy marked as read" });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "Error marking policy as read", error = ex.Message });
        }
    }

    private string GetContentType(string fileType)
    {
        return fileType.ToLower() switch
        {
            "pdf" => "application/pdf",
            "jpg" or "jpeg" => "image/jpeg",
            "png" => "image/png",
            "doc" => "application/msword",
            "docx" => "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
            _ => "application/octet-stream"
        };
    }
}

