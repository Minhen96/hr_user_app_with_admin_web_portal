using MailKit.Net.Smtp;
using MimeKit;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;

namespace React.Services;

/// <summary>
/// Email service using SMTP with configuration from appsettings
/// </summary>
public class EmailService
{
    private readonly string _smtpServer;
    private readonly int _smtpPort;
    private readonly string _smtpUsername;
    private readonly string _smtpPassword;
    private readonly string _fromName;
    private readonly ILogger<EmailService> _logger;

    public EmailService(IConfiguration configuration, ILogger<EmailService> logger)
    {
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));

        // Read SMTP settings from configuration
        _smtpServer = configuration["Email:SmtpServer"]
            ?? throw new InvalidOperationException("Email:SmtpServer not configured");

        _smtpPort = int.Parse(configuration["Email:SmtpPort"] ?? "587");

        _smtpUsername = configuration["Email:Username"]
            ?? throw new InvalidOperationException("Email:Username not configured");

        _smtpPassword = configuration["Email:Password"]
            ?? throw new InvalidOperationException("Email:Password not configured");

        _fromName = configuration["Email:FromName"] ?? "MH HR System";
    }

    /// <summary>
    /// Send an email asynchronously
    /// </summary>
    public async Task SendEmailAsync(string toEmail, string subject, string body)
    {
        try
        {
            var message = new MimeMessage();
            message.From.Add(new MailboxAddress(_fromName, _smtpUsername));
            message.To.Add(new MailboxAddress("", toEmail));
            message.Subject = subject;
            message.Body = new TextPart("html")
            {
                Text = body
            };

            using var client = new SmtpClient();
            await client.ConnectAsync(_smtpServer, _smtpPort, MailKit.Security.SecureSocketOptions.StartTls);
            await client.AuthenticateAsync(_smtpUsername, _smtpPassword);
            await client.SendAsync(message);
            await client.DisconnectAsync(true);

            _logger.LogInformation("Email sent successfully to {Email}", toEmail);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to send email to {Email}", toEmail);
            throw new Exception("Failed to send email. Please check the email service configuration.", ex);
        }
    }

    /// <summary>
    /// Validate email configuration by attempting to connect
    /// </summary>
    public async Task<bool> ValidateEmailConfigurationAsync()
    {
        try
        {
            using var client = new SmtpClient();
            await client.ConnectAsync(_smtpServer, _smtpPort, MailKit.Security.SecureSocketOptions.StartTls);
            await client.AuthenticateAsync(_smtpUsername, _smtpPassword);
            await client.DisconnectAsync(true);
            return true;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Email configuration validation failed");
            return false;
        }
    }
}
