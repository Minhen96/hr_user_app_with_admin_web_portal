using System.ComponentModel.DataAnnotations;

namespace React.Core.DTOs.Request;

/// <summary>
/// DTO for changing user password
/// </summary>
public class ChangePasswordRequestDto
{
    [Required]
    public int UserId { get; set; }

    [Required]
    [MinLength(6)]
    public string OldPassword { get; set; } = string.Empty;

    [Required]
    [MinLength(6)]
    public string NewPassword { get; set; } = string.Empty;

    [Required]
    [Compare(nameof(NewPassword), ErrorMessage = "Passwords do not match")]
    public string ConfirmPassword { get; set; } = string.Empty;
}
