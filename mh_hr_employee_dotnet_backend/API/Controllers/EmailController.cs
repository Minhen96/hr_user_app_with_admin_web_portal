using Microsoft.AspNetCore.Mvc;
using React.Services;

namespace React.API.Controllers;

/// <summary>
/// Controller for email operations (testing email functionality)
/// </summary>
[ApiController]
[Route("api/[controller]")]
public class EmailController : ControllerBase
{
    private readonly EmailService _emailService;
    private readonly ILogger<EmailController> _logger;

    public EmailController(EmailService emailService, ILogger<EmailController> logger)
    {
        _emailService = emailService ?? throw new ArgumentNullException(nameof(emailService));
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));
    }

    /// <summary>
    /// Send a test email
    /// POST: api/Email/send-test
    /// </summary>
    [HttpPost("send-test")]
    [ProducesResponseType(typeof(object), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(object), StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> SendTestEmail()
    {
        try
        {
            _logger.LogInformation("Sending test email");

            await _emailService.SendEmailAsync(
                "yapmh-wp21@student.tarc.edu.my",
                "Test Email from SmarterMail",
                "This is a test email sent using SmarterMail SMTP server."
            );

            _logger.LogInformation("Test email sent successfully");
            return Ok(new { message = "Test email sent successfully." });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to send test email");
            return BadRequest(new { message = $"Failed to send test email: {ex.Message}" });
        }
    }
}
