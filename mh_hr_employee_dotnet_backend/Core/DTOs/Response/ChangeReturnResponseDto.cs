namespace React.Core.DTOs.Response;

public class ChangeReturnListResponseDto
{
    public int Id { get; set; }
    public string RequesterName { get; set; } = string.Empty;
    public string Department { get; set; } = string.Empty;
    public DateTime DateReturned { get; set; }
    public string ReturnStatus { get; set; } = string.Empty;
    public string? Reason { get; set; }
}

public class ChangeReturnDetailsResponseDto
{
    public int Id { get; set; }
    public string RequesterName { get; set; } = string.Empty;
    public string Department { get; set; } = string.Empty;
    public DateTime DateReturned { get; set; }
    public string ReturnStatus { get; set; } = string.Empty;
    public string? ReceivedDetails { get; set; }
    public string? Reason { get; set; }
    public string? ProductCode { get; set; }
}
