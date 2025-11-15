namespace React.Core.DTOs.Response;

public class UserChangeRequestBriefResponseDto
{
    public int? Id { get; set; }
    public DateTime? DateRequested { get; set; }
    public string? Status { get; set; }
    public string? Reason { get; set; }
    public string? ReturnStatus { get; set; }
    public string? ProductCode { get; set; }
}

public class UserChangeRequestDetailResponseDto
{
    public int? Id { get; set; }
    public string RequesterName { get; set; } = string.Empty;
    public DateTime? DateRequested { get; set; }
    public string? Status { get; set; }
    public string? Reason { get; set; }
    public string? Description { get; set; }
    public string? Risk { get; set; }
    public string? Instruction { get; set; }
    public string? PostReview { get; set; }
    public DateTime? CompleteDate { get; set; }
    public SignatureDataDto SignatureData { get; set; } = null!;
    public string? ApproverName { get; set; }
    public DateTime? DateApproved { get; set; }
    public SignatureDataDto? ApprovalSignatureData { get; set; }
    public string? FixedAssetTypeName { get; set; }
    public List<string> ProductCodes { get; set; } = new();
}

public class SignatureDataDto
{
    public string Points { get; set; } = string.Empty;
    public double BoundaryWidth { get; set; }
    public double BoundaryHeight { get; set; }
}

public class UserChangeRequestFullResponseDto
{
    public int? Id { get; set; }
    public DateTime? DateRequested { get; set; }
    public string? Status { get; set; }
    public string? Reason { get; set; }
    public string? Description { get; set; }
    public string? Risk { get; set; }
    public string? Instruction { get; set; }
    public DateTime? CompleteDate { get; set; }
    public string? ReturnStatus { get; set; }
    public string? PostReview { get; set; }
    public string? ProductCode { get; set; }
}
