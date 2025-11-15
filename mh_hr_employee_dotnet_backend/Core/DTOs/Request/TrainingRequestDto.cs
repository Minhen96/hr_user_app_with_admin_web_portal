using System.ComponentModel.DataAnnotations;

namespace React.Core.DTOs.Request;

public class TrainingStatusUpdateDto
{
    [Required]
    public string Status { get; set; } = string.Empty;

    [Required]
    public int ApproverId { get; set; }

    [Required]
    public DateTime DateApproved { get; set; }
}
