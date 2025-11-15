namespace React.Core.DTOs.Response;

public class HandbookSectionResponseDto
{
    public int Id { get; set; }
    public string Title { get; set; } = string.Empty;
    public List<HandbookContentResponseDto> Contents { get; set; } = new();
}

public class HandbookContentResponseDto
{
    public int Id { get; set; }
    public int HandbookSectionId { get; set; }
    public string Subtitle { get; set; } = string.Empty;
    public string Content { get; set; } = string.Empty;
}
