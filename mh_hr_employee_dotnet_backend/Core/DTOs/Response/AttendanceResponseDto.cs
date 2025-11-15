namespace React.Core.DTOs.Response;

public class AttendanceResponseDto
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public DateTime TimeIn { get; set; }
    public DateTime? TimeOut { get; set; }
    public DateTime DateSubmission { get; set; }
    public string PlaceName { get; set; } = string.Empty;
    public int UserId { get; set; }
    public string? TimeInPhoto { get; set; }
    public string? TimeOutPhoto { get; set; }
}
