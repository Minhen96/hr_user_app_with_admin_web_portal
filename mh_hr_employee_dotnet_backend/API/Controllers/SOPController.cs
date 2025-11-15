using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using React.Data;
using React.Models;

namespace React.API.Controllers;

[Route("admin/api/[controller]")]
[ApiController]
public class SOPController : ControllerBase
{
    private readonly ApplicationDbContext _context;

    public SOPController(ApplicationDbContext context)
    {
        _context = context ?? throw new ArgumentNullException(nameof(context));
    }

    [HttpGet]
    public async Task<IActionResult> GetAllSOPs()
    {
        try
        {
            var sops = await _context.Documents
                .Where(d => d.Type == "SOP")
                .OrderByDescending(d => d.PostDate)
                .ToListAsync();
            return Ok(sops);
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "Error fetching SOPs", error = ex.Message });
        }
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetSOP(int id)
    {
        try
        {
            var sop = await _context.Documents.FindAsync(id);
            if (sop == null || sop.Type != "SOP")
                return NotFound(new { message = "SOP not found" });

            return Ok(sop);
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "Error fetching SOP", error = ex.Message });
        }
    }

    [HttpPost]
    public async Task<IActionResult> CreateSOP([FromForm] CreateMemoDto request)
    {
        try
        {
            var sop = new Document
            {
                Type = "SOP",
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
                sop.DocumentUpload = memoryStream.ToArray();
                sop.FileType = Path.GetExtension(request.File.FileName).TrimStart('.');
            }

            _context.Documents.Add(sop);
            await _context.SaveChangesAsync();

            return Ok(new { success = true, documentId = sop.Id, message = "SOP created successfully" });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "Error creating SOP", error = ex.Message });
        }
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> UpdateSOP(int id, [FromForm] CreateMemoDto request)
    {
        try
        {
            var sop = await _context.Documents.FindAsync(id);
            if (sop == null || sop.Type != "SOP")
                return NotFound(new { message = "SOP not found" });

            sop.Title = request.Title;
            sop.Content = request.Content;
            sop.DepartmentId = request.DepartmentId;

            if (request.File != null)
            {
                using var memoryStream = new MemoryStream();
                await request.File.CopyToAsync(memoryStream);
                sop.DocumentUpload = memoryStream.ToArray();
                sop.FileType = Path.GetExtension(request.File.FileName).TrimStart('.');
            }

            await _context.SaveChangesAsync();

            return Ok(new { success = true, message = "SOP updated successfully" });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "Error updating SOP", error = ex.Message });
        }
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteSOP(int id)
    {
        try
        {
            var sop = await _context.Documents.FindAsync(id);
            if (sop == null || sop.Type != "SOP")
                return NotFound(new { message = "SOP not found" });

            _context.Documents.Remove(sop);
            await _context.SaveChangesAsync();

            return Ok(new { success = true, message = "SOP deleted successfully" });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "Error deleting SOP", error = ex.Message });
        }
    }

    [HttpGet("{id}/download")]
    public async Task<IActionResult> DownloadSOP(int id)
    {
        try
        {
            var sop = await _context.Documents.FindAsync(id);
            if (sop == null || sop.Type != "SOP")
                return NotFound(new { message = "SOP not found" });

            if (sop.DocumentUpload == null || string.IsNullOrEmpty(sop.FileType))
                return NotFound(new { message = "File not found" });

            var contentType = GetContentType(sop.FileType);
            var fileName = $"{sop.Title}.{sop.FileType}";
            return File(sop.DocumentUpload, contentType, fileName);
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "Error downloading SOP", error = ex.Message });
        }
    }

    [HttpPost("{id}/mark-read")]
    public async Task<IActionResult> MarkSOPAsRead(int id, [FromBody] MarkReadDto request)
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

            return Ok(new { success = true, message = "SOP marked as read" });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "Error marking SOP as read", error = ex.Message });
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
