namespace React.Core.DTOs.Response;

/// <summary>
/// DTO for password change request information
/// </summary>
public class PasswordChangeResponseDto
{
    public int Id { get; set; }
    public string FullName { get; set; } = string.Empty;
    public string Department { get; set; } = string.Empty;
    public DateTime? ChangePasswordDate { get; set; }
    public string Status { get; set; } = string.Empty;
}
