using System.ComponentModel.DataAnnotations;

namespace React.Core.DTOs.Request;

/// <summary>
/// DTO for updating password change status (approve/reject)
/// </summary>
public class UpdatePasswordStatusRequestDto
{
    [Required]
    public string Status { get; set; } = string.Empty;

    [Required]
    public int ApproverId { get; set; }

    [Required]
    public DateTime DateApproved { get; set; }
}
