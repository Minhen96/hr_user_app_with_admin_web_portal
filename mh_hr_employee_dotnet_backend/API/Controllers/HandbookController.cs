using Microsoft.AspNetCore.Mvc;
using React.Core.Interfaces.Services;

namespace React.API.Controllers;

[Route("admin/api/[controller]")]
[ApiController]
public class HandbookController : ControllerBase
{
    private readonly IHandbookService _handbookService;

    public HandbookController(IHandbookService handbookService)
    {
        _handbookService = handbookService ?? throw new ArgumentNullException(nameof(handbookService));
    }

    [HttpGet]
    public async Task<IActionResult> GetSections()
    {
        var result = await _handbookService.GetAllSectionsAsync();
        return result.IsSuccess
            ? Ok(result.Data)
            : StatusCode(500, new { error = result.Message });
    }

    [HttpGet("userguide")]
    public async Task<IActionResult> GetUserGuide()
    {
        var result = await _handbookService.GetUserGuidePdfAsync();
        return result.IsSuccess
            ? File(result.Data, "application/pdf", "Mobile User Guide.pdf")
            : NotFound(new { error = result.Message });
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetSection(int id)
    {
        var result = await _handbookService.GetSectionByIdAsync(id);
        return result.IsSuccess
            ? Ok(result.Data)
            : NotFound(new { error = result.Message });
    }

    [HttpGet("content/{sectionId}")]
    public async Task<IActionResult> GetSectionContent(int sectionId)
    {
        var result = await _handbookService.GetSectionContentsAsync(sectionId);
        return result.IsSuccess
            ? Ok(result.Data)
            : StatusCode(500, new { error = result.Message });
    }

}
