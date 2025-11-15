namespace React.Core.DTOs.Response;

public class TrainingResponseDto
{
    public int Id { get; set; }
    public string UserName { get; set; } = string.Empty;
    public string Department { get; set; } = string.Empty;
    public string Title { get; set; } = string.Empty;
    public string? Description { get; set; }
    public DateTime CourseDate { get; set; }
    public string Status { get; set; } = string.Empty;
    public string? RejectedReason { get; set; }
}
