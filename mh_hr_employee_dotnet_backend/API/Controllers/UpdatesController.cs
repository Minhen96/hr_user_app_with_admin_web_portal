using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using React.Data;
using React.Models;

namespace React.API.Controllers;

[Route("admin/api/[controller]")]
[ApiController]
public class UpdatesController : ControllerBase
{
    private readonly ApplicationDbContext _context;

    public UpdatesController(ApplicationDbContext context)
    {
        _context = context ?? throw new ArgumentNullException(nameof(context));
    }

    [HttpGet]
    public async Task<IActionResult> GetAllUpdates()
    {
        try
        {
            var updates = await _context.Documents
                .Where(d => d.Type == "UPDATES")
                .OrderByDescending(d => d.PostDate)
                .ToListAsync();
            return Ok(updates);
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "Error fetching updates", error = ex.Message });
        }
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetUpdate(int id)
    {
        try
        {
            var update = await _context.Documents.FindAsync(id);
            if (update == null || update.Type != "UPDATES")
                return NotFound(new { message = "Update not found" });

            return Ok(update);
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "Error fetching update", error = ex.Message });
        }
    }

    [HttpPost]
    public async Task<IActionResult> CreateUpdate([FromForm] CreateMemoDto request)
    {
        try
        {
            var update = new Document
            {
                Type = "UPDATES",
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
                update.DocumentUpload = memoryStream.ToArray();
                update.FileType = Path.GetExtension(request.File.FileName).TrimStart('.');
            }

            _context.Documents.Add(update);
            await _context.SaveChangesAsync();

            return Ok(new { success = true, documentId = update.Id, message = "Update created successfully" });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "Error creating update", error = ex.Message });
        }
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> UpdateUpdate(int id, [FromForm] CreateMemoDto request)
    {
        try
        {
            var update = await _context.Documents.FindAsync(id);
            if (update == null || update.Type != "UPDATES")
                return NotFound(new { message = "Update not found" });

            update.Title = request.Title;
            update.Content = request.Content;
            update.DepartmentId = request.DepartmentId;

            if (request.File != null)
            {
                using var memoryStream = new MemoryStream();
                await request.File.CopyToAsync(memoryStream);
                update.DocumentUpload = memoryStream.ToArray();
                update.FileType = Path.GetExtension(request.File.FileName).TrimStart('.');
            }

            await _context.SaveChangesAsync();

            return Ok(new { success = true, message = "Update updated successfully" });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "Error updating update", error = ex.Message });
        }
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteUpdate(int id)
    {
        try
        {
            var update = await _context.Documents.FindAsync(id);
            if (update == null || update.Type != "UPDATES")
                return NotFound(new { message = "Update not found" });

            _context.Documents.Remove(update);
            await _context.SaveChangesAsync();

            return Ok(new { success = true, message = "Update deleted successfully" });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "Error deleting update", error = ex.Message });
        }
    }

    [HttpGet("{id}/download")]
    public async Task<IActionResult> DownloadUpdate(int id)
    {
        try
        {
            var update = await _context.Documents.FindAsync(id);
            if (update == null || update.Type != "UPDATES")
                return NotFound(new { message = "Update not found" });

            if (update.DocumentUpload == null || string.IsNullOrEmpty(update.FileType))
                return NotFound(new { message = "File not found" });

            var contentType = GetContentType(update.FileType);
            var fileName = $"{update.Title}.{update.FileType}";
            return File(update.DocumentUpload, contentType, fileName);
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "Error downloading update", error = ex.Message });
        }
    }

    [HttpPost("{id}/mark-read")]
    public async Task<IActionResult> MarkUpdateAsRead(int id, [FromBody] MarkReadDto request)
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

            return Ok(new { success = true, message = "Update marked as read" });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "Error marking update as read", error = ex.Message });
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
