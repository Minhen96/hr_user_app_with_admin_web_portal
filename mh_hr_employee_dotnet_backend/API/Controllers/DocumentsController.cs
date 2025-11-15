using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using React.Core.DTOs.Request;
using React.Core.Interfaces.Services;
using React.Data;

namespace React.API.Controllers;

[Route("admin/api/[controller]")]
[ApiController]
public class DocumentsController : ControllerBase
{
    private readonly IDocumentService _documentService;
    private readonly ApplicationDbContext _context;

    public DocumentsController(IDocumentService documentService, ApplicationDbContext context)
    {
        _documentService = documentService ?? throw new ArgumentNullException(nameof(documentService));
        _context = context ?? throw new ArgumentNullException(nameof(context));
    }

    [HttpPost("create")]
    public async Task<IActionResult> CreateDocument([FromForm] CreateDocumentRequestDto request)
    {
        if (!ModelState.IsValid)
            return BadRequest(new { success = false, message = "Invalid request data" });

        var result = await _documentService.CreateDocumentAsync(request);
        return result.IsSuccess
            ? Ok(new { success = true, documentId = result.Data, message = result.Message })
            : BadRequest(new { success = false, message = result.Message });
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetDocument(int id)
    {
        var result = await _documentService.GetDocumentByIdAsync(id);
        if (!result.IsSuccess)
            return NotFound(new { success = false, message = result.Message });

        if (result.Data?.DocUpload != null && result.Data.FileType != null)
            return File(result.Data.DocUpload, result.Data.FileType);

        return Ok(result.Data);
    }

    [HttpGet]
    public async Task<IActionResult> GetAllDocuments()
    {
        var result = await _documentService.GetAllDocumentsAsync();
        return result.IsSuccess ? Ok(result.Data) : StatusCode(500, new { message = result.Message });
    }

    [HttpGet("departments")]
    public async Task<IActionResult> GetDepartments()
    {
        try
        {
            var departments = await _context.Departments
                .Select(d => new { d.Id, d.Name })
                .ToListAsync();
            return Ok(departments);
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "Error fetching departments", error = ex.Message });
        }
    }
}
