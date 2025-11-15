namespace React.DTOs
{
    public class CreateEquipmentRequestDto
    {
        public List<CreateEquipmentItemDto> Items { get; set; } = new();
        public SignatureDto Signature { get; set; } = null!;
    }

    public class CreateEquipmentItemDto
    {
        public string Title { get; set; } = string.Empty;
        public string? Description { get; set; }
        public int Quantity { get; set; } = 1;
        public string Justification { get; set; }
    }

    public class SignatureDto
    {
        public List<UserPointDto> Points { get; set; } = new();
        public float BoundaryWidth { get; set; }
        public float BoundaryHeight { get; set; }
    }

    public class UserPointDto
    {
        public float x { get; set; }
        public float y { get; set; }
    }

    public class UpdateReceivedDetailsDto
    {
        public string ReceivedDetails { get; set; } = string.Empty;
    }

    public class UpdateStatusDto
    {
        public string Status { get; set; } = string.Empty;
        public int? ApproverId { get; set; }
    }

    public class EquipmentRequestListDto
    {
        public int Id { get; set; }
        public int RequesterId { get; set; }
        public string RequesterName { get; set; } = string.Empty;
        public string Department { get; set; } = string.Empty;
        public DateTime DateRequested { get; set; }
        public string Status { get; set; } = "pending";
        public int? ApproverId { get; set; }
        public string? ApproverName { get; set; }
        public DateTime? DateApproved { get; set; }
        public int ItemCount { get; set; }
    }

    public class EquipmentRequestDetailsDto
    {
        public int Id { get; set; }
        public int RequesterId { get; set; }
        public string RequesterName { get; set; } = string.Empty;
        public string Department { get; set; } = string.Empty;
        public DateTime DateRequested { get; set; }
        public string Status { get; set; } = "pending";
        public int? ApproverId { get; set; }
        public string? ApproverName { get; set; }
        public DateTime? DateApproved { get; set; }
        public string? ReceivedDetails { get; set; }
        public List<EquipmentItemDetailsDto> Items { get; set; } = new();
        public SignatureDetailsDto? Signature { get; set; }
        public SignatureDetailsDto? ApprovalSignature { get; set; }
    }

    public class EquipmentItemDetailsDto
    {
        public int Id { get; set; }
        public string Title { get; set; } = string.Empty;
        public string? Description { get; set; }
        public int Quantity { get; set; }
        public string Justification { get; set; } = "New";
    }

    public class SignatureDetailsDto
    {
        public int Id { get; set; }
        public string Points { get; set; } = string.Empty;
        public double BoundaryWidth { get; set; }
        public double BoundaryHeight { get; set; }
    }
}