namespace React.Core.DTOs.Response;

public class DocumentResponseDto
{
    public int Id { get; set; }
    public string Type { get; set; } = string.Empty;
    public DateTime PostDate { get; set; }
    public string Title { get; set; } = string.Empty;
    public string? DocContent { get; set; }
    public string? FileType { get; set; }
    public int PostBy { get; set; }
    public int DepartmentId { get; set; }
    public byte[]? DocUpload { get; set; }
}
