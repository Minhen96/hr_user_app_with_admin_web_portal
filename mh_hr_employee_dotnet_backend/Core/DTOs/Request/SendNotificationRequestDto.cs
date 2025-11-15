using System.ComponentModel.DataAnnotations;

namespace React.Core.DTOs.Request;

public class SendNotificationRequestDto
{
    [Required]
    public int UserId { get; set; }

    [Required(ErrorMessage = "Title is required")]
    public string Title { get; set; } = string.Empty;

    [Required(ErrorMessage = "Body is required")]
    public string Body { get; set; } = string.Empty;

    public Dictionary<string, string>? Data { get; set; }

    public int BadgeCount { get; set; }
}
