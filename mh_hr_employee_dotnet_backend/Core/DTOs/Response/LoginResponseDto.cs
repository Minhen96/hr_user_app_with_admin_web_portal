namespace React.Core.DTOs.Response;

/// <summary>
/// DTO for login response with user information
/// </summary>
public class LoginResponseDto
{
    public int Id { get; set; }
    public string FullName { get; set; } = string.Empty;
    public string Nric { get; set; } = string.Empty;
    public string? Tin { get; set; }
    public string? EpfNo { get; set; }
    public string Email { get; set; } = string.Empty;
    public int DepartmentId { get; set; }
    public string DepartmentName { get; set; } = string.Empty;
    public string Role { get; set; } = string.Empty;
    public string Status { get; set; } = string.Empty;
    public string? Token { get; set; }
}
