using Microsoft.AspNetCore.Http;
using System.ComponentModel.DataAnnotations;

namespace React.Core.DTOs.Request;

public class CreateDocumentRequestDto
{
    [Required]
    public string Type { get; set; } = string.Empty;

    [Required]
    public string Title { get; set; } = string.Empty;

    public string? DocContent { get; set; }

    [Required]
    public int PostBy { get; set; }

    [Required]
    public int DepartmentId { get; set; }

    public IFormFile? File { get; set; }
}
