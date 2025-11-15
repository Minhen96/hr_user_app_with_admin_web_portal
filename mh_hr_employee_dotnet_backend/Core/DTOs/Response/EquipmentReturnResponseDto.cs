namespace React.Core.DTOs.Response;

public class EquipmentReturnListResponseDto
{
    public int Id { get; set; }
    public string ReturnerName { get; set; } = string.Empty;
    public string Department { get; set; } = string.Empty;
    public DateTime DateReturn { get; set; }
    public string Status { get; set; } = string.Empty;
}

public class EquipmentReturnDetailsResponseDto
{
    public int Id { get; set; }
    public string ReturnerName { get; set; } = string.Empty;
    public string Department { get; set; } = string.Empty;
    public DateTime DateReturn { get; set; }
    public string Status { get; set; } = string.Empty;
    public List<ReturnedItemDto> EquipmentItems { get; set; } = new();
    public SignatureDto Signature { get; set; } = new();
}

public class ReturnedItemDto
{
    public int Id { get; set; }
    public string Title { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public int Quantity { get; set; }
    public string Justification { get; set; } = string.Empty;
}

public class SignatureDto
{
    public string Points { get; set; } = string.Empty;
    public float BoundaryWidth { get; set; }
    public float BoundaryHeight { get; set; }
}
