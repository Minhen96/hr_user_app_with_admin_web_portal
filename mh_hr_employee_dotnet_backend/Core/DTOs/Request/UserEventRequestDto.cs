namespace React.Core.DTOs.Request;

public class CreateEventRequestDto
{
    public string Title { get; set; } = string.Empty;
    public string? Description { get; set; }
    public DateTime Date { get; set; }
    // UserId will be extracted from JWT token, not from request body
}

public class UpdateEventRequestDto
{
    public int Id { get; set; }
    public string Title { get; set; } = string.Empty;
    public string? Description { get; set; }
    public DateTime Date { get; set; }
}

public class MarkEventReadRequestDto
{
    public int EventId { get; set; }
    public int UserId { get; set; }
}
