using System.ComponentModel.DataAnnotations;

namespace React.Core.DTOs.Request;

public class UpdateFCMTokenRequestDto
{
    [Required(ErrorMessage = "FCM token is required")]
    public string FCMToken { get; set; } = string.Empty;
}
