namespace React.Core.DTOs.Response;

public class UserEventResponseDto
{
    public int Id { get; set; }
    public string Title { get; set; } = string.Empty;
    public string? Description { get; set; }
    public DateTime Date { get; set; }
    public int UserId { get; set; }
    public string? UserName { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
    public bool IsRead { get; set; }
}

public class EventReadStatusResponseDto
{
    public bool IsRead { get; set; }
}
