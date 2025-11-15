namespace React.Core.DTOs.Response;

public class McLeaveResponseDto
{
    public int Id { get; set; }
    public string FullName { get; set; } = string.Empty;
    public DateTime StartDate { get; set; }
    public DateTime EndDate { get; set; }
    public DateTime DateSubmission { get; set; }
    public int TotalDay { get; set; }
    public string Status { get; set; } = string.Empty;
    public string Reason { get; set; } = string.Empty;
    public string? AttachmentUrl { get; set; }
}
