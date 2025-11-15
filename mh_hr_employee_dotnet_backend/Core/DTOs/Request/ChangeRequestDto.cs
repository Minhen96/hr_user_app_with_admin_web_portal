using System.ComponentModel.DataAnnotations;

namespace React.Core.DTOs.Request;

public class UpdateChangeRequestStatusRequestDto
{
    [Required(ErrorMessage = "Status is required")]
    public string Status { get; set; } = string.Empty;

    [Required(ErrorMessage = "Approver ID is required")]
    public int ApproverId { get; set; }

    public DateTime? DateApproved { get; set; }
    public SignatureRequestDto? ApprovalSignature { get; set; }
    public int? FixedAssetTypeId { get; set; }

    [Required(ErrorMessage = "Running code is required")]
    public string RunningCode { get; set; } = string.Empty;
}

public class ChangeStatusRequestDto
{
    [Required(ErrorMessage = "Status is required")]
    public string Status { get; set; } = string.Empty;

    [Required(ErrorMessage = "Approver ID is required")]
    public int ApproverId { get; set; }
}

public class SignatureRequestDto
{
    public string Points { get; set; } = string.Empty;
    public float BoundaryWidth { get; set; }
    public float BoundaryHeight { get; set; }
}
