using System.ComponentModel.DataAnnotations;

namespace React.Core.DTOs.Request;

public class LeaveStatusUpdateDto
{
    [Required]
    public string Status { get; set; } = string.Empty;

    [Required]
    public int ApprovedBy { get; set; }

    public int? ApprovalSignatureId { get; set; }
}
