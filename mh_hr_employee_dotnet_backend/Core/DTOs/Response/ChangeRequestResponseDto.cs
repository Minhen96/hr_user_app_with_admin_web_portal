namespace React.Core.DTOs.Response;

public class ChangeRequestListResponseDto
{
    public int Id { get; set; }
    public string RequesterName { get; set; } = string.Empty;
    public string Department { get; set; } = string.Empty;
    public DateTime DateRequested { get; set; }
    public string Status { get; set; } = string.Empty;
    public string? ProductCode { get; set; }
    public string? Reason { get; set; }
}

public class ChangeRequestDetailsResponseDto
{
    public int Id { get; set; }
    public string RequesterName { get; set; } = string.Empty;
    public string Department { get; set; } = string.Empty;
    public DateTime DateRequested { get; set; }
    public string Status { get; set; } = string.Empty;
    public string? Description { get; set; }
    public string? Reason { get; set; }
    public string? Risk { get; set; }
    public string? Instruction { get; set; }
    public DateTime? CompleteDate { get; set; }
    public string? PostReview { get; set; }
    public SignatureResponseDto Signature { get; set; } = new();
    public string? ApproverName { get; set; }
    public DateTime? DateApproved { get; set; }
    public SignatureResponseDto? ApprovalSignature { get; set; }
}

public class SignatureResponseDto
{
    public string Points { get; set; } = string.Empty;
    public float BoundaryWidth { get; set; }
    public float BoundaryHeight { get; set; }
}

public class FixedAssetTypeResponseDto
{
    public int Id { get; set; }
    public string Code { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
}
