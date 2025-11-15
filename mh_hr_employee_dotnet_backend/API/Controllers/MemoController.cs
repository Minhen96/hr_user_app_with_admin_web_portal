using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using React.Data;
using React.Models;

namespace React.API.Controllers;

[Route("admin/api/[controller]")]
[ApiController]
public class MemoController : ControllerBase
{
    private readonly ApplicationDbContext _context;

    public MemoController(ApplicationDbContext context)
    {
        _context = context ?? throw new ArgumentNullException(nameof(context));
    }

    [HttpGet]
    public async Task<IActionResult> GetAllMemos()
    {
        try
        {
            var memos = await _context.Documents
                .Where(d => d.Type == "MEMO")
                .OrderByDescending(d => d.PostDate)
                .ToListAsync();
            return Ok(memos);
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "Error fetching memos", error = ex.Message });
        }
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetMemo(int id)
    {
        try
        {
            var memo = await _context.Documents.FindAsync(id);
            if (memo == null || memo.Type != "MEMO")
                return NotFound(new { message = "Memo not found" });

            return Ok(memo);
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "Error fetching memo", error = ex.Message });
        }
    }

    [HttpPost]
    public async Task<IActionResult> CreateMemo([FromForm] CreateMemoDto request)
    {
        try
        {
            var memo = new Document
            {
                Type = "MEMO",
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
                memo.DocumentUpload = memoryStream.ToArray();
                memo.FileType = Path.GetExtension(request.File.FileName).TrimStart('.');
            }

            _context.Documents.Add(memo);
            await _context.SaveChangesAsync();

            return Ok(new { success = true, documentId = memo.Id, message = "Memo created successfully" });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "Error creating memo", error = ex.Message });
        }
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> UpdateMemo(int id, [FromForm] CreateMemoDto request)
    {
        try
        {
            var memo = await _context.Documents.FindAsync(id);
            if (memo == null || memo.Type != "MEMO")
                return NotFound(new { message = "Memo not found" });

            memo.Title = request.Title;
            memo.Content = request.Content;
            memo.DepartmentId = request.DepartmentId;

            if (request.File != null)
            {
                using var memoryStream = new MemoryStream();
                await request.File.CopyToAsync(memoryStream);
                memo.DocumentUpload = memoryStream.ToArray();
                memo.FileType = Path.GetExtension(request.File.FileName).TrimStart('.');
            }

            await _context.SaveChangesAsync();

            return Ok(new { success = true, message = "Memo updated successfully" });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "Error updating memo", error = ex.Message });
        }
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteMemo(int id)
    {
        try
        {
            var memo = await _context.Documents.FindAsync(id);
            if (memo == null || memo.Type != "MEMO")
                return NotFound(new { message = "Memo not found" });

            _context.Documents.Remove(memo);
            await _context.SaveChangesAsync();

            return Ok(new { success = true, message = "Memo deleted successfully" });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "Error deleting memo", error = ex.Message });
        }
    }

    [HttpGet("{id}/download")]
    public async Task<IActionResult> DownloadMemo(int id)
    {
        try
        {
            var memo = await _context.Documents.FindAsync(id);
            if (memo == null || memo.Type != "MEMO")
                return NotFound(new { message = "Memo not found" });

            if (memo.DocumentUpload == null || string.IsNullOrEmpty(memo.FileType))
                return NotFound(new { message = "File not found" });

            var contentType = GetContentType(memo.FileType);
            var fileName = $"{memo.Title}.{memo.FileType}";
            return File(memo.DocumentUpload, contentType, fileName);
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "Error downloading memo", error = ex.Message });
        }
    }

    [HttpPost("{id}/mark-read")]
    public async Task<IActionResult> MarkMemoAsRead(int id, [FromBody] MarkReadDto request)
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

            return Ok(new { success = true, message = "Memo marked as read" });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "Error marking memo as read", error = ex.Message });
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

public class CreateMemoDto
{
    public string Title { get; set; } = string.Empty;
    public string? Content { get; set; }
    public int DepartmentId { get; set; }
    public int PostBy { get; set; }
    public IFormFile? File { get; set; }
}

public class MarkReadDto
{
    public int UserId { get; set; }
}
