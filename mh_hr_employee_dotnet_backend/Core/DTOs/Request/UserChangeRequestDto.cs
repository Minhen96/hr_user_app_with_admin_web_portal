namespace React.Core.DTOs.Request;

public class CreateSignatureRequestDto
{
    public List<PointDto> Points { get; set; } = new();
    public float BoundaryWidth { get; set; }
    public float BoundaryHeight { get; set; }
}

public class PointDto
{
    public float x { get; set; }
    public float y { get; set; }
}

public class CreateUserChangeRequestDto
{
    public int RequesterId { get; set; }
    public string Reason { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public string Risk { get; set; } = string.Empty;
    public string Instruction { get; set; } = string.Empty;
    public string PostReview { get; set; } = string.Empty;
    public int SignatureId { get; set; }
    public DateTime? CompleteDate { get; set; }
}
