using System.ComponentModel.DataAnnotations;

namespace React.Core.DTOs.Request;

public class UpdateChangeReturnStatusRequestDto
{
    [Required(ErrorMessage = "Return status is required")]
    public string ReturnStatus { get; set; } = string.Empty;

    [Required(ErrorMessage = "Approver ID is required")]
    public int ApproverId { get; set; }
}
