using Microsoft.Extensions.Logging;
using React.Core.DTOs.Request;
using React.Core.DTOs.Response;
using React.Core.Interfaces.Repositories;
using React.Core.Interfaces.Services;
using React.Shared.Results;

namespace React.Application.Services;

public class NotificationService : INotificationService
{
    private readonly INotificationRepository _repository;
    private readonly ILogger<NotificationService> _logger;

    public NotificationService(
        INotificationRepository repository,
        ILogger<NotificationService> logger)
    {
        _repository = repository ?? throw new ArgumentNullException(nameof(repository));
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));
    }

    public async Task<ServiceResult<bool>> UpdateFcmTokenAsync(int userId, UpdateFCMTokenRequestDto request)
    {
        try
        {
            _logger.LogInformation("Updating FCM token for user {UserId}", userId);

            var user = await _repository.GetUserByIdAsync(userId);
            if (user == null)
            {
                _logger.LogWarning("User {UserId} not found", userId);
                return ServiceResult<bool>.Failure($"User not found: {userId}");
            }

            await _repository.UpdateUserFcmTokenAsync(userId, request.FCMToken);

            _logger.LogInformation("Successfully updated FCM token for user {UserId}", userId);
            return ServiceResult<bool>.Success(true);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error updating FCM token for user {UserId}", userId);
            return ServiceResult<bool>.Failure($"Error updating FCM token: {ex.Message}");
        }
    }

    public async Task<ServiceResult<string>> SendNotificationAsync(SendNotificationRequestDto request)
    {
        try
        {
            _logger.LogInformation(
                "Sending notification to user {UserId}: {Title}",
                request.UserId,
                request.Title);

            var user = await _repository.GetUserByIdAsync(request.UserId);
            if (user == null || string.IsNullOrEmpty(user.FcmToken))
            {
                _logger.LogWarning("User {UserId} or FCM token not found", request.UserId);
                return ServiceResult<string>.Failure("User or FCM token not found");
            }

            // Firebase has been removed - push notifications are disabled
            // TODO: Implement alternative push notification service if needed
            _logger.LogWarning(
                "Push notifications are disabled. Firebase has been removed. UserId: {UserId}, Title: {Title}",
                request.UserId,
                request.Title);

            return ServiceResult<string>.Success("Notification queued (push notifications disabled)");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error sending notification to user {UserId}", request.UserId);
            return ServiceResult<string>.Failure($"Error sending notification: {ex.Message}");
        }
    }

    public async Task<ServiceResult<IEnumerable<UserFcmTokenResponseDto>>> GetAllUserFcmTokensAsync()
    {
        try
        {
            _logger.LogInformation("Retrieving all user FCM tokens");

            var tokens = await _repository.GetAllUserFcmTokensAsync();

            _logger.LogInformation("Retrieved {Count} FCM tokens", tokens.Count());
            return ServiceResult<IEnumerable<UserFcmTokenResponseDto>>.Success(tokens);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving FCM tokens");
            return ServiceResult<IEnumerable<UserFcmTokenResponseDto>>.Failure(
                $"Error retrieving FCM tokens: {ex.Message}");
        }
    }
}
