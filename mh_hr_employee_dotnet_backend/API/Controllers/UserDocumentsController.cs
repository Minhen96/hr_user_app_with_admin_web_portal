using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using React.Core.Interfaces.Services;
using React.DTOs;
using System.Security.Claims;

namespace React.API.Controllers;

[ApiController]
[Route("api/Document")]
[Authorize]
public class UserDocumentsController : ControllerBase
{
    private readonly IUserDocumentService _userDocumentService;
    private readonly ILogger<UserDocumentsController> _logger;

    public UserDocumentsController(IUserDocumentService userDocumentService, ILogger<UserDocumentsController> logger)
    {
        _userDocumentService = userDocumentService ?? throw new ArgumentNullException(nameof(userDocumentService));
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));
    }

    private int GetCurrentUserId()
    {
        var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier);
        if (userIdClaim == null)
        {
            throw new UnauthorizedAccessException("User ID not found in token");
        }
        return int.Parse(userIdClaim.Value);
    }

    [HttpGet("updates/unread-count")]
    public async Task<IActionResult> GetUnreadCount()
    {
        try
        {
            var userId = GetCurrentUserId();
            var result = await _userDocumentService.GetUnreadCountAsync(userId);

            return result.IsSuccess
                ? Ok(result.Data)
                : StatusCode(500, "Internal server error");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting unread count");
            return StatusCode(500, "Internal server error");
        }
    }

    [HttpPost("updates/{id}/mark-read")]
    public async Task<IActionResult> MarkAsRead(int id)
    {
        try
        {
            var userId = GetCurrentUserId();
            var result = await _userDocumentService.MarkAsReadAsync(id, userId);

            return result.IsSuccess
                ? Ok()
                : NotFound(result.Message);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error marking document as read");
            return StatusCode(500, "Internal server error");
        }
    }

    [HttpGet("unread-counts")]
    public async Task<IActionResult> GetUnreadCounts()
    {
        try
        {
            var userId = GetCurrentUserId();
            var result = await _userDocumentService.GetUnreadCountsByTypeAsync(userId);

            return result.IsSuccess
                ? Ok(result.Data)
                : StatusCode(500, result.Message);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting document unread counts");
            return StatusCode(500, "Internal server error");
        }
    }

    [HttpPost("{id}/mark-read")]
    public async Task<IActionResult> MarkDocumentAsRead(int id)
    {
        try
        {
            var userId = GetCurrentUserId();
            var result = await _userDocumentService.MarkAsReadAsync(id, userId);

            return result.IsSuccess
                ? Ok()
                : NotFound(result.Message);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error marking document as read");
            return StatusCode(500, "Internal server error");
        }
    }

    [HttpGet("updates/{id}/get-reads")]
    public async Task<IActionResult> GetDocumentRead(int id)
    {
        try
        {
            var userId = GetCurrentUserId();
            var result = await _userDocumentService.GetDocumentReadInfoAsync(id, userId);

            return result.IsSuccess
                ? Ok(result.Data)
                : NotFound(result.Message);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving document read information");
            return StatusCode(500, "Internal server error");
        }
    }

    [HttpGet]
    public async Task<IActionResult> GetDocuments([FromQuery] string? type, [FromQuery] int page = 1)
    {
        try
        {
            var userId = GetCurrentUserId();
            var result = await _userDocumentService.GetDocumentsAsync(type, page, userId);

            return result.IsSuccess
                ? Ok(result.Data)
                : StatusCode(500, result.Message);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error fetching documents");
            return StatusCode(500, "Internal server error occurred while fetching documents");
        }
    }

    [HttpGet("updates")]
    public async Task<IActionResult> GetUpdatesDocuments([FromQuery] string? type, [FromQuery] int page = 1)
    {
        try
        {
            var userId = GetCurrentUserId();
            var result = await _userDocumentService.GetUpdatesDocumentsAsync(page, userId);

            return result.IsSuccess
                ? Ok(result.Data)
                : StatusCode(500, result.Message);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error fetching documents");
            return StatusCode(500, "Internal server error occurred while fetching documents");
        }
    }

    [HttpPost("updates")]
    public async Task<IActionResult> AddUpdateDocument([FromBody] DocumentDto documentDto)
    {
        try
        {
            var userId = GetCurrentUserId();
            var result = await _userDocumentService.AddUpdateDocumentAsync(documentDto, userId);

            return result.IsSuccess
                ? CreatedAtAction(nameof(GetUpdatesDocuments), new { id = result.Data!.Id }, result.Data)
                : BadRequest(result.Message);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error adding update document");
            return StatusCode(500, "Internal server error occurred while adding document");
        }
    }

    [HttpPut("updates/{id}")]
    public async Task<IActionResult> EditUpdateDocument(int id, [FromBody] DocumentDto documentDto)
    {
        try
        {
            var result = await _userDocumentService.EditUpdateDocumentAsync(id, documentDto);

            return result.IsSuccess
                ? Ok(result.Data)
                : NotFound(result.Message);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error editing update document");
            return StatusCode(500, "Internal server error occurred while editing document");
        }
    }

    [HttpDelete("updates/{id}")]
    public async Task<IActionResult> DeleteUpdateDocument(int id)
    {
        try
        {
            var result = await _userDocumentService.DeleteUpdateDocumentAsync(id);

            return result.IsSuccess
                ? Ok()
                : NotFound(result.Message);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error deleting update document");
            return StatusCode(500, "Internal server error occurred while deleting document");
        }
    }

    [HttpGet("updates/history")]
    public async Task<IActionResult> GetHistoryDocuments([FromQuery] int year, [FromQuery] int month, [FromQuery] int page = 1)
    {
        try
        {
            var result = await _userDocumentService.GetHistoryDocumentsAsync(year, month, page);

            return result.IsSuccess
                ? Ok(result.Data)
                : StatusCode(500, result.Message);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error fetching history documents");
            return StatusCode(500, "Internal server error occurred while fetching documents");
        }
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetDocument(int id)
    {
        try
        {
            var result = await _userDocumentService.GetDocumentByIdAsync(id);

            return result.IsSuccess
                ? Ok(result.Data)
                : NotFound(result.Message);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error fetching document");
            return StatusCode(500, "Internal server error occurred while fetching document");
        }
    }

    [HttpGet("{id}/preview")]
    public async Task<IActionResult> PreviewDocument(int id)
    {
        try
        {
            var result = await _userDocumentService.GetDocumentFileAsync(id);

            if (!result.IsSuccess)
            {
                return NotFound(result.Message);
            }

            var file = result.Data!;
            var contentType = GetContentType(file.FileType);

            if (IsSupportedPreviewType(file.FileType))
            {
                return File(file.FileData, contentType);
            }

            return File(file.FileData, contentType, $"{file.Title}{GetFileExtension(file.FileType)}");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error previewing document");
            return StatusCode(500, "Internal server error occurred while previewing document");
        }
    }

    [HttpGet("{id}/download")]
    public async Task<IActionResult> DownloadDocument(int id)
    {
        try
        {
            var result = await _userDocumentService.GetDocumentFileAsync(id);

            if (!result.IsSuccess)
            {
                return NotFound(result.Message);
            }

            var file = result.Data!;
            var contentType = GetContentType(file.FileType);
            var fileExtension = GetFileExtension(file.FileType);
            var filename = $"{file.Title}{fileExtension}";

            Response.Headers["Content-Disposition"] = $"attachment; filename=\"{filename}\"";

            return File(file.FileData, contentType, filename);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error downloading document");
            return StatusCode(500, "Internal server error occurred while downloading document");
        }
    }

    private string GetContentType(string fileType)
    {
        return fileType.ToLower() switch
        {
            "pdf" => "application/pdf",
            "jpg" or "jpeg" => "image/jpeg",
            "png" => "image/png",
            "doc" or "docx" => "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
            "xls" or "xlsx" => "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
            _ => "application/octet-stream"
        };
    }

    private string GetFileExtension(string fileType)
    {
        return fileType.ToLower() switch
        {
            "pdf" => ".pdf",
            "jpg" or "jpeg" => ".jpg",
            "png" => ".png",
            "doc" => ".doc",
            "docx" => ".docx",
            "xls" => ".xls",
            "xlsx" => ".xlsx",
            _ => ""
        };
    }

    private bool IsSupportedPreviewType(string fileType)
    {
        var supportedTypes = new[] { "pdf", "jpg", "jpeg", "png" };
        return supportedTypes.Contains(fileType.ToLower());
    }
}
