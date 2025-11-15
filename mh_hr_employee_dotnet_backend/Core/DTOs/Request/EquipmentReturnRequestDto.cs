using System.ComponentModel.DataAnnotations;

namespace React.Core.DTOs.Request;

public class UpdateEquipmentReturnStatusRequestDto
{
    [Required(ErrorMessage = "Status is required")]
    public string Status { get; set; } = string.Empty;

    [Required(ErrorMessage = "Approver ID is required")]
    public int ApproverId { get; set; }

    [Required(ErrorMessage = "Date approved is required")]
    public DateTime DateApproved { get; set; }
}
